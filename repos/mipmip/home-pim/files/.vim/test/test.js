/**
 * Kaftmeister WebClient
 *
 * Copyright © 2017-present Kaftmeister B.V., All rights reserved.
 *
 */
import React from 'react';
import PropTypes from 'prop-types';
import ReactDOM from 'react-dom';

import FormGroup from 'react-bootstrap/lib/FormGroup';
import ControlLabel from 'react-bootstrap/lib/ControlLabel';
import Col from 'react-bootstrap/lib/Col';
import ButtonToolbar from 'react-bootstrap/lib/ButtonToolbar';
import DropdownButton from 'react-bootstrap/lib/DropdownButton';
import MenuItem from 'react-bootstrap/lib/MenuItem';

class Dropdown extends React.Component {

  static contextTypes = { store: PropTypes.object.isRequired };

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  handleOnSelect(e){
    this.props.selectForField(e);
  }

  render() {
    const options = this.props.items.map(item =>
       <MenuItem eventKey={item.key} key={item.key}>{item.title}</MenuItem>
    );

    return (
      <FormGroup controlId="formHorizontalReference">
        <Col componentClass={ControlLabel} sm={this.props.sm1}>{this.props.elementTitle}</Col>
        <Col sm={this.props.sm2}>

          <ButtonToolbar>
            <DropdownButton
              title= { this.props.activeTitle ? this.props.activeTitle : '' }
              id="dropdown-size-medium"
              onSelect={(e) => this.handleOnSelect(e)} >
              {options}
            </DropdownButton>
          </ButtonToolbar>

        </Col>
      </FormGroup>
    )
  }
}

export default Dropdown;
