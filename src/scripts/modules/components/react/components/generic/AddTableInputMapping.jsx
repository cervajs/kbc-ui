import React from 'react';
import {ModalTrigger} from 'react-bootstrap';
import Modal from './TableInputMappingModal';
import actionCreators from '../../../InstalledComponentsActionCreators';

export default React.createClass({
  propTypes: {
    tables: React.PropTypes.object.isRequired,
    mapping: React.PropTypes.object.isRequired,
    componentId: React.PropTypes.string.isRequired,
    configId: React.PropTypes.string.isRequired
  },

  render() {
    return (
      <ModalTrigger modal={this.modal()}>
        <button className="btn btn-primary" onClick={this.handleClick}>
          <span className="kbc-icon-plus"></span> Add Table Input
        </button>
      </ModalTrigger>
    );
  },

  modal() {
    return React.createElement(Modal, {
      mode: 'create',
      mapping: this.props.mapping,
      tables: this.props.tables,
      onChange: this.handleChange,
      onCancel: this.handleCancel,
      onSave: this.handleSave
    });
  },

  handleClick(e) {
    e.preventDefault();
    e.stopPropagation();
  },

  /* eslint camelcase: 0 */
  handleChange(newMapping) {
    actionCreators.changeEditingMapping(this.props.componentId,
      this.props.configId,
      'input',
      'tables',
      'new-mapping',
      newMapping
    );
  },

  handleCancel() {
    actionCreators.cancelEditingMapping(this.props.componentId,
      this.props.configId,
      'input',
      'tables',
      'new-mapping'
    );
  },

  handleSave() {
    // returns promise
    return actionCreators.saveEditingMapping(this.props.componentId,
      this.props.configId,
      'input',
      'tables',
      'new-mapping'
    );
  }

});
