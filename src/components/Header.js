// required for all components
import React, { Component } from 'react'
import { render } from 'react-dom'
import { connect } from "react-redux";
import { push } from 'react-router-redux'
import Search from './Search'


import { withStyles } from 'material-ui/styles';
import AppBar from 'material-ui/AppBar';
import Toolbar from 'material-ui/Toolbar';
import Typography from 'material-ui/Typography';
import Button from 'material-ui/Button';
import IconButton from 'material-ui/IconButton';
import MenuIcon from 'material-ui-icons/Menu';
import Badge from 'material-ui/Badge';
import Avatar from 'material-ui/Avatar';

import { IndexLink, Link, browserHistory } from 'react-router';
import List, { ListItem, ListItemIcon, ListItemText } from 'material-ui/List';
import Divider from 'material-ui/Divider';
import AddCircleOutlineIcon from 'material-ui-icons/AddCircleOutline';
import FolderOpenIcon from 'material-ui-icons/FolderOpen';
import SaveIcon from 'material-ui-icons/Save';
import Heart from 'mui-icons/cmdi/heart';
import Dna from 'mui-icons/cmdi/dna';
import FaceIcon from 'material-ui-icons/Face';

import Drawer from 'material-ui/Drawer';


export class Header extends Component {
  constructor(props) {
    super(props)
    this.state = {
      open: false,
    };
    this.handleToggle = this.handleToggle.bind(this);
    this.handleTitleTouchTap = this.handleTitleTouchTap.bind(this);
  }

  handleToggle() {
    this.setState({ open: !this.state.open });
  }

  handleTitleTouchTap() {
    browserHistory.push('/'); // Navigate home
  }

  render() {
    const { dispatch } = this.props
    const classes = this.props.classes;
    return (
      <div className={classes.root}>
        <AppBar position="static" >
          <Toolbar>
            <IconButton color="contrast" aria-label="Menu"  onClick={event => this.handleToggle()}>
              <MenuIcon />
            </IconButton>
            <img color="contrast" src="/media/bmeg-logo-white.png" height="45" onClick={ () => dispatch(push('/')) }/>
            <Search focus={this.props.focus} />
            <IconButton color="contrast" aria-label="Menu"  onClick={event => alert('//TODO add account details')}>
              <Avatar alt="TODO"  src="/media/avatar.png" />
            </IconButton>
          </Toolbar>
        </AppBar>
        <Drawer
          docked={false}
          width={200}
          open={this.state.open}
          onRequestClose={this.handleToggle}
          onClick={this.handleToggle}
        >
          <List className={classes.listFull} disablePadding>
            <ListItem button onClick={ () => dispatch({type: 'NEW_QUERY'}) }>
              <ListItemIcon><AddCircleOutlineIcon /></ListItemIcon>
              <ListItemText primary="New" />
            </ListItem>
            <ListItem button onClick={ () => dispatch({type: 'OPEN_QUERY'}) }>
              <ListItemIcon><FolderOpenIcon /></ListItemIcon>
              <ListItemText primary="Open" />
            </ListItem>
            <ListItem button onClick={ () => dispatch({type: 'SAVE_QUERY'}) }>
              <ListItemIcon><SaveIcon /></ListItemIcon>
              <ListItemText primary="Save" />
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemIcon><Dna /></ListItemIcon>
              <ListItemText primary="About" />
            </ListItem>
          </List>
        </Drawer>
      </div>
    );
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
  options: {},
};

export default connect() (withStyles(styles) (Header));
