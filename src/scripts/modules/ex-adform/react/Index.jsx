import React from 'react';
import {Map, List} from 'immutable';

import createStoreMixin from '../../../react/mixins/createStoreMixin';
import RoutesStore from '../../../stores/RoutesStore';
import InstalledComponentStore from '../../components/stores/InstalledComponentsStore';
import ComponentStore from '../../components/stores/ComponentsStore';
import LatestJobsStore from '../../jobs/stores/LatestJobsStore';

import ComponentDescription from '../../components/react/components/ComponentDescription';
import ComponentMetadata from '../../components/react/components/ComponentMetadata';
import RunComponentButton from '../../components/react/components/RunComponentButton';
import DeleteConfigurationButton from '../../components/react/components/DeleteConfigurationButton';
import LatestJobs from '../../components/react/components/SidebarJobs';
import CredentialsModal from './CredentialsModal';
import TemplateModal from './TemplateModal';
import Configuration from '../../components/react/components/Configuration';
import {saveCredentials,
  cancelCredentialsEdit,
  updateLocalState,
  jobsEditStart,
  jobsEditChange,
  jobsEditCancel,
  jobsEditSubmit,
  changeTemplate,
  initFromWizard,
  prefillFromTemplate,
  changeWizardStep
  } from '../actions';

import templates from '../jobsTemplates';
import {Button} from 'react-bootstrap';
import Wizard from './Wizard';
import {Steps} from '../constants';

function parameterPasswordCompatibility(parameters) {
  const password = parameters.getIn(['config', '#password'], parameters.getIn(['config', 'password'], ''));
  return parameters.setIn(['config', '#password'], password);
}

export default React.createClass({
  mixins: [createStoreMixin(InstalledComponentStore, LatestJobsStore, ComponentStore)],

  getStateFromStores() {
    const configId = RoutesStore.getCurrentRouteParam('config'),
      componentId = 'ex-adform',
      localState = InstalledComponentStore.getLocalState(componentId, configId),
      parameters = parameterPasswordCompatibility(InstalledComponentStore
          .getConfigData(componentId, configId)
          .get('parameters', Map())
      );

    return {
      component: ComponentStore.getComponent(componentId),
      componentId: componentId,
      parameters: parameters,
      config: InstalledComponentStore.getConfig(componentId, configId),
      latestJobs: LatestJobsStore.getJobs(componentId, configId),
      isSaving: InstalledComponentStore.isSavingConfigData(componentId, configId),
      localState: localState,
      isEditingJobs: localState.has('jobsString'),
      isInitialized: parameters.getIn(['config', 'username']) && parameters.getIn(['config', '#password'])
        && parameters.hasIn(['config', 'jobs'])
    };
  },

  getInitialState() {
    return {
      showCredentialsModal: false,
      showTemplateModal: false
    };
  },

  render() {
    if (this.state.isInitialized) {
      return this.renderMain();
    } else {
      return (
        <div className="container-fluid">
          <div className="col-md-12 kbc-main-content">
            <Wizard
              credentials={this.state.localState.get('credentials', Map({
                username: this.state.parameters.getIn(['config', 'username'], ''),
                '#password': this.state.parameters.getIn(['config', '#password'], '')
              }))}
              onCredentialsChange={this.updateCredentials}
              step={this.state.localState.get('wizardStep', Steps.STEP_CREDENTIALS)}
              onStepChange={this.changeWizardStep}
              template={this.state.localState.get('template')}
              templates={this.templatesOptions()}
              onTemplateChange={this.onTemplateChange}
              onSave={this.onInit}
              isSaving={this.state.isSaving}
              componentId={this.state.componentId}
              configurationId={this.state.config.get('id')}
              />
          </div>
        </div>
      );
    }
  },

  renderMain() {
    return (
      <div className="container-fluid">
        <div className="col-md-9 kbc-main-content">
          <div className="row kbc-header">
            <ComponentDescription
              componentId={this.state.componentId}
              configId={this.state.config.get('id')}
              />
          </div>
          <div className="row">
            {this.renderHelp()}
            <Configuration
              data={this.getJobsData()}
              isEditing={this.state.isEditingJobs}
              isSaving={this.state.isSaving}
              onEditStart={this.onJobsEditStart}
              onEditCancel={this.onJobsEditCancel}
              onEditChange={this.onJobsEditChange}
              onEditSubmit={this.onJobsEditSubmit}
              isValid={this.isValidJobsData()}
              headerText="Resources"
              help={this.renderPrefillFromTemplate()}
              />
          </div>
        </div>
        <div className="col-md-3 kbc-main-sidebar">
          <div classNmae="kbc-buttons kbc-text-light">
            <span>Authorized for <strong>{this.state.parameters.getIn(['config', 'username'])}</strong></span>
            <ComponentMetadata
              componentId={this.state.componentId}
              configId={this.state.config.get('id')}
              />
          </div>
          <ul className="nav nav-stacked">
            <li>
              <a onClick={this.openCredentialsModal}>
                <i className="fa fa-fw fa-user"/>
                Credentials
              </a>
            </li>
            <li>
              <RunComponentButton
                title="Run"
                component={this.state.componentId}
                mode="link"
                runParams={this.runParams()}
                disabledReason="Component is not configured yet"
                >
                You are about to run component.
              </RunComponentButton>
            </li>
            <li>
              <DeleteConfigurationButton
                componentId={this.state.componentId}
                configId={this.state.config.get('id')}
                />
            </li>
          </ul>
          <LatestJobs jobs={this.state.latestJobs} />
          <CredentialsModal
            show={this.state.showCredentialsModal}
            onHide={this.closeCredentialsModal}
            credentials={this.state.localState.get('credentials', Map({
                  username: this.state.parameters.getIn(['config', 'username'], ''),
                  '#password': this.state.parameters.getIn(['config', '#password'], '')
                }))}
            isSaving={this.state.isSaving}
            onChange={this.updateCredentials}
            onSave={this.saveCredentials}
            />
        </div>
      </div>
    );
  },

  renderHelp() {
    return (
      <p className="help-block">
        The resource configuration bellow expect <strong>jobs</strong> array configured according to
        <a href="https://github.com/keboola/generic-extractor#jobs" target="_blank"> Generic extractor documentation</a>.

        Details about Adform API are available in <a href="https://api.adform.com/Services/Documentation/Index.htm" target="_blank">
          Adform API documentation
        </a>.
      </p>
    );
  },

  getJobsData() {
    if(this.state.isEditingJobs) {
      return this.state.localState.get('jobsString');
    } else {
      return JSON.stringify(this.state.parameters.getIn(['config', 'jobs'], List()).toJSON(), null, '  ');
    }
  },

  isValidJobsData() {
    try {
      JSON.parse(this.state.localState.get('jobsString'));
      return true;
    } catch (e) {
      return false;
    }
  },

  renderPrefillFromTemplate() {
    if (this.state.isEditingJobs) {
      return (
        <div>
          <p>
            <Button
              bsStyle="link"
              onClick={this.openTemplateModal}
              >
              <span className="fa fa-folder-open"/> Configure from template
            </Button>
            <TemplateModal
              show={this.state.showTemplateModal}
              template={this.state.localState.get('template', '')}
              templates={this.templatesOptions()}
              onChange={this.onTemplateChange}
              onSubmit={this.onPrefillFromTemplate}
              onHide={this.closeTemplateModal}
              />
          </p>
        </div>
      );
    } else {
      return null;
    }
  },

  templatesOptions() {
    return templates.map((template) => {
      return Map({
        label: template.get('name'),
        value: template.get('id')
      });
    }).toJS();
  },

  updateCredentials(newCredentials) {
    this.updateLocalState(['credentials'], newCredentials);
  },

  openCredentialsModal() {
    this.setState({
      showCredentialsModal: true
    });
  },

  closeCredentialsModal() {
    this.setState({
      showCredentialsModal: false
    });
    cancelCredentialsEdit(this.state.config.get('id'));
  },

  openTemplateModal() {
    this.setState({
      showTemplateModal: true
    });
  },

  closeTemplateModal() {
    this.setState({
      showTemplateModal: false
    });
  },


  saveCredentials() {
    return saveCredentials(this.state.config.get('id'));
  },

  updateLocalState(path, value) {
    const newState = this.state.localState.setIn(path, value);
    updateLocalState(this.state.config.get('id'), newState);
  },

  runParams() {
    return () => ({config: this.state.config.get('id')});
  },

  onJobsEditStart() {
    jobsEditStart(this.state.config.get('id'));
  },

  onJobsEditCancel() {
    jobsEditCancel(this.state.config.get('id'));
  },

  onJobsEditChange(newValue) {
    jobsEditChange(this.state.config.get('id'), newValue);
  },

  onJobsEditSubmit() {
    jobsEditSubmit(this.state.config.get('id'));
  },

  onTemplateChange(templateId) {
    changeTemplate(this.state.config.get('id'), templateId);
  },

  onInit() {
    initFromWizard(this.state.config.get('id'));
  },

  onPrefillFromTemplate() {
    prefillFromTemplate(this.state.config.get('id'));
  },

  changeWizardStep(newStep) {
    changeWizardStep(this.state.config.get('id'), newStep);
  }

});
