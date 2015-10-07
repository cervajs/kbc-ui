import React, {PropTypes} from 'react';
import {Input} from 'react-bootstrap';

export default React.createClass({
  propTypes: {
    credentials: PropTypes.object.isRequired,
    onChange: PropTypes.func.isRequired
  },
  render() {
    return (
      <div className="form-horizontal">
        <p className="help-block">Please provide your Adform credentials.</p>
        <Input
          type="text"
          label="Username"
          value={this.props.credentials.get('username')}
          onChange={this.handleChange.bind(this, 'username')}
          labelClassName='col-sm-4' wrapperClassName='col-sm-6'
          autoFocus={true}
          />
        <Input
          type="password"
          label="Password"
          value={this.props.credentials.get('#password')}
          onChange={this.handleChange.bind(this, '#password')}
          labelClassName='col-sm-4' wrapperClassName='col-sm-6'
          />
      </div>
    );
  },

  handleChange(field, e) {
    this.props.onChange(this.props.credentials.set(field, e.target.value));
  }
});