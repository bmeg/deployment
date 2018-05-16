// required for all components
import React, { Component } from 'react'
import { render } from 'react-dom'
import { connect } from "react-redux";
import { push } from 'react-router-redux'

import { withStyles } from 'material-ui/styles';

import Button from 'material-ui/Button';
import IconButton from 'material-ui/IconButton';
import { CircularProgress } from 'material-ui/Progress';
import Card, { CardContent, CardHeader, CardActions } from 'material-ui/Card';
import Collapse from 'material-ui/transitions/Collapse';
import ExpandMoreIcon from 'material-ui-icons/ExpandMore';
import ExpandLessIcon from 'material-ui-icons/ExpandLess';
import ChevronLeftIcon from 'material-ui-icons/ChevronLeft';
import ChevronRightIcon from 'material-ui-icons/ChevronRight';
import AddCircleOutlineIcon from 'material-ui-icons/AddCircleOutline';
import FolderOpenIcon from 'material-ui-icons/FolderOpen';
import SaveIcon from 'material-ui-icons/Save';
import Heart from 'mui-icons/cmdi/heart';
import Dna from 'mui-icons/cmdi/dna';



export class Plot extends Component {
  constructor(props) {
    super(props)
    this.state = {
      open: props.open,
    };
    this.toggleOpen = this.toggleOpen.bind(this);
  }

  toggleOpen() {
    this.setState({ open: !this.state.open });
  }


  componentDidMount() {
    this.drawPlot()
  }

  drawPlot() {
    console.log('drawPlot', this.props)
    // Plotly needs writable objects, so deep clone
    // to a local variable
    let data =  JSON.parse(JSON.stringify(this.props.data));
    let layout = JSON.parse(JSON.stringify(this.props.layout));
    Plotly.plot('plotly-div', {
      data: data,
      layout: layout
    });
  }

  componentDidUpdate() {
    this.drawPlot()
  }

  render() {
    //
    const _self = this ;
    let icon
    if (_self.state.open) {
      icon = (<ExpandLessIcon />)
    } else {
      icon = (<ExpandMoreIcon />)
    }
    const plotContent = (
      <Card raised>
        <CardActions disableActionSpacing
          onClick={_self.toggleOpen}
          >
          <CardHeader title={'Sample Plot'} />
          <div style={{flex: '1 1 auto'}} />
          <IconButton
            onClick={_self.toggleOpen}
            aria-expanded={_self.state.open}
            aria-label="Show plot"
          >
            {icon}
          </IconButton>
        </CardActions>
        <Collapse in={_self.state.open} transitionDuration="auto" unmountOnExit>
          <CardContent>
            <div id="plotly-div"></div>
          </CardContent>
        </Collapse>
      </Card>
    )
    console.log('Plot render')

    return plotContent
  }


}

const styles = {
  root: {
    marginTop: 4,
    width: '100%',
  },
  flex: {
    flex: 1,
  },
};


function mapStateToProps(state, own) {
  return {
    data: state.plot.data,
    layout: state.plot.layout,
  }
}

export default connect(mapStateToProps)(withStyles(styles)(Plot));
