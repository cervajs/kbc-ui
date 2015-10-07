import React, {PropTypes} from 'react';
import {Input, Button} from 'react-bootstrap';
import {Loader} from 'kbc-react-components';

export default React.createClass({
  propTypes: {
    parameters: PropTypes.object.isRequired,
    onChange: PropTypes.func.isRequired,
    onRun: PropTypes.func.isRequired,
    isValid: PropTypes.bool.isRequired,
    isSaving: PropTypes.bool.isRequired,
    savedMessage: PropTypes.object.isRequired
  },

  render() {
    return (
      <div className="form-horizontal">
        {this.input('AWS Access Key ID', 'awsAccessKeyId', '')}
        {this.input('AWS Secret Access Key', '#awsSecretAccessKey', '')}
        {this.input('S3 Bucket', 's3bucket', 'my-bucket')}
        {this.input('S3 path', 's3path')}
        <Input type="checkbox"
           wrapperClassName="col-xs-offset-4 col-xs-8"
           label="Export only project structure"
           help="All buckets and tables metadata and all configurations will be exported."
           checked={this.props.parameters.get('onlyStructure')}
           onChange={this.handleOnlyStructureChange}
        />
        <div className="form-group">
          <div className="col-xs-offset-4 col-xs-8">
            <Button bsStyle="success" onClick={this.props.onRun} disabled={!this.props.isValid || this.props.isSaving}>
              Run Backup
            </Button> {this.loader()} {this.props.savedMessage}
          </div>
        </div>
      </div>
    );
  },

  input(label, field, placeholder) {
    return React.createElement(Input, {
      type: 'text',
      label: label,
      placeholder: placeholder,
      value: this.props.parameters.get(field),
      onChange: this.handleChange.bind(this, field),
      labelClassName: 'col-xs-4',
      wrapperClassName: 'col-xs-8'
    });
  },

  loader() {
    return this.props.isSaving ? React.createElement(Loader) : null;
  },

  handleChange(field, event) {
    this.props.onChange(this.props.parameters.set(field, event.target.value));
  },

  handleOnlyStructureChange(event) {
    this.props.onChange(this.props.parameters.set('onlyStructure', event.target.checked));
  }
});