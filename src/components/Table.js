import React, { Component } from 'react'
import { render } from 'react-dom'
import { connect } from "react-redux"
import { push } from 'react-router-redux'
import * as _ from 'underscore'


import PropTypes from 'prop-types';
import { withStyles, createStyleSheet } from 'material-ui/styles';

// tricky import so we don't have a name collision on 'Table'
import { default as TableMD } from 'material-ui/Table';
import { TableBody, TableCell, TableHead, TableRow, TableSortLabel } from 'material-ui/Table';

import Paper from 'material-ui/Paper';


export class Table extends Component {


  constructor(props) {
    super(props);
    /* initial state */
    this.state = {
      order:'asc',
      orderBy: 'gid'
    };
    this.handleRequestSort = this.handleRequestSort.bind(this)
  }

  handleRequestSort(property) {
    const orderBy = property;
    let order = 'desc';
    if (this.state.orderBy === property && this.state.order === 'desc') {
      order = 'asc';
    }
    const data = this.props.data.sort(
      (a, b) => (order === 'desc' ? b[orderBy] > a[orderBy] : a[orderBy] > b[orderBy]),
    );
    this.setState({ data:data , order:order , orderBy:orderBy });
  };


  // render the table
  render() {
    const _self = this ;
    const classes = this.props.classes;
    if (this.props.data) {
      // map the first item to columns TODO - map from facets
      const columns = _.map(this.props.data[0], function(item, key, object) {
        return (
          <TableCell
            key={key}>
            <TableSortLabel
               active={_self.state.orderBy === key}
               direction={_self.state.order}
               onClick= {(evt, clickedProps) => {
                 _self.handleRequestSort(key);
               }}
             >
               {key}
             </TableSortLabel>
          </TableCell>
        )
      });

      const rows = _.map(this.props.data, function(item, index, list) {
        return (
          <TableRow key={item.gid}>
            {
              _.map(item, function(value, key, obj) {
                return (
                  <TableCell key={`${item.gid}.${key}`}>
                    {value}
                  </TableCell>
                );
              })
            }
          </TableRow>
        );
      });

      return (
        <Paper className={classes.paper}>
          <TableMD>
            <TableHead>
              <TableRow>
                {columns}
              </TableRow>
            </TableHead>
            <TableBody>
              {rows}
            </TableBody>
          </TableMD>
        </Paper>
      ) ;
    } else {
      return (
        <div>no results</div>
      )
    }
  }
}

function mapStateToProps(state, own) {
  var data;
  if(state.query && state.query.focus === own.label) {
    data = state.query.results ? state.query.results.map(function(result) {return {...result.properties, gid: result.gid}}) : []
  }
  return {
    data: data,
  }
}

const styleSheet = createStyleSheet(theme => ({
  paper: {
    width: '100%',
    marginTop: theme.spacing.unit * 3,
    overflowX: 'auto',
  },
}));


export default connect(mapStateToProps)(withStyles(styleSheet)(Table));
