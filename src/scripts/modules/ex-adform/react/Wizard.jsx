import React, {PropTypes} from 'react';
import {TabbedArea, TabPane, Button} from 'react-bootstrap';
import {Steps} from '../constants';
import Select from 'react-select';
import CredentialsForm from './CredentialsForm';
import {Loader} from 'kbc-react-components';
import DeleteConfigurationButton from '../../components/react/components/DeleteConfigurationButton';

export default React.createClass({
  propTypes: {
    credentials: PropTypes.object.isRequired,
    onCredentialsChange: PropTypes.func.isRequired,
    template: PropTypes.string.isRequired,
    templates: PropTypes.object.isRequired,
    onTemplateChange: PropTypes.func.isRequired,
    step: PropTypes.string.isRequired,
    onStepChange: PropTypes.func.isRequired,
    isSaving: PropTypes.func.isRequired,
    onSave: PropTypes.func.isRequired,
    componentId: PropTypes.string.isRequired,
    configurationId: PropTypes.string.isRequired
  },

  render() {
    return (
      <TabbedArea activeKey={this.props.step} onSelect={this.goToStep} animation={false}>
        <TabPane eventKey={Steps.STEP_CREDENTIALS} tab="1. Credentials">
          <div className="row">
            <div className="col-md-8">
              <CredentialsForm
                credentials={this.props.credentials}
                onChange={this.props.onCredentialsChange}
                />
            </div>
          </div>
          <div className="row">
            <div className="form-horizontal">
              <div className="form-group">
                  <div className="pull-right">
                    <DeleteConfigurationButton
                      componentId={this.props.componentId}
                      configId={this.props.configurationId}
                      />
                    <Button
                      style={{marginLeft: '20px'}}
                      bsStyle="primary"
                      disabled={!this.isCredentialsValid()}
                      onClick={this.goToTemplate}
                      >
                      Next: Select Template
                    </Button>
                </div>
              </div>
            </div>
          </div>
        </TabPane>
        <TabPane eventKey={Steps.STEP_TEMPLATE} tab="2. Template" disabled={!this.isCredentialsValid()}>
          <div className="row">
            <div className="col-sm-10">
              <p>Please select from predefined templates to initialize the Adform configuration:</p>
              <p>
                <Select
                  name="jobTemplates"
                  value={this.props.template}
                  options={this.props.templates}
                  onChange={this.props.onTemplateChange}
                  placeholder="Select template"
                  />
              </p>
              <p className="help-block">
                You can change it or extend it to fetch more or other data later.
              </p>
            </div>
          </div>
          <div className="row">
            <div className="pull-right">
              {this.props.isSaving ? <Loader/> : null}
              &nbsp;
              &nbsp;
              <DeleteConfigurationButton
                componentId={this.props.componentId}
                configId={this.props.configurationId}
                />
              <Button
                bsStyle="link"
                style={{marginLeft: '10px'}}
                onClick={this.goToCredentials}
                disabled={this.props.isSaving}
                >
                Previous
              </Button>
              <Button
                bsStyle="success"
                disabled={!this.props.template || this.props.isSaving}
                onClick={this.props.onSave}
                >
                Create
              </Button>
            </div>
          </div>
        </TabPane>
      </TabbedArea>
    );
  },

  isCredentialsValid() {
    return this.props.credentials.get('username').trim().length > 0 &&
      this.props.credentials.get('#password').trim().length > 0;
  },

  goToCredentials() {
    this.goToStep(Steps.STEP_CREDENTIALS);
  },

  goToTemplate() {
    this.goToStep(Steps.STEP_TEMPLATE);
  },

  goToStep(step) {
    this.props.onStepChange(step);
  }
});