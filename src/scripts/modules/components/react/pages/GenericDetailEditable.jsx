import React from 'react';

import createStoreMixin from '../../../../react/mixins/createStoreMixin';
import RoutesStore from '../../../../stores/RoutesStore';
import InstalledComponentStore from '../../stores/InstalledComponentsStore';
import ComponentStore from '../../stores/ComponentsStore';
import LatestJobsStore from '../../../jobs/stores/LatestJobsStore';

import ComponentDescription from '../components/ComponentDescription';
import ComponentMetadata from '../components/ComponentMetadata';
import RunComponentButton from '../components/RunComponentButton';
import DeleteConfigurationButton from '../components/DeleteConfigurationButton';
import LatestJobs from '../components/SidebarJobs';
import Configuration from '../components/Configuration';
import InstalledComponentsActionCreators from '../../InstalledComponentsActionCreators';

export default React.createClass({
  mixins: [createStoreMixin(InstalledComponentStore, LatestJobsStore, ComponentStore)],

  getStateFromStores() {
    const configId = RoutesStore.getCurrentRouteParam('config'),
      componentId = RoutesStore.getCurrentRouteParam('component');

    return {
      component: ComponentStore.getComponent(componentId),
      componentId: componentId,
      configData: InstalledComponentStore.getConfigData(componentId, configId),
      config: InstalledComponentStore.getConfig(componentId, configId),
      latestJobs: LatestJobsStore.getJobs(componentId, configId),
      isEditing: InstalledComponentStore.isEditingRawConfigData(componentId, configId),
      isSaving: InstalledComponentStore.isSavingConfigData(componentId, configId),
      editingConfigData: InstalledComponentStore.getEditingRawConfigData(componentId, configId, '{}'),
      isValidEditingConfigData: InstalledComponentStore.isValidEditingConfigData(componentId, configId)
    };
  },

  documentationLink() {
    if (this.state.component.get('documentationUrl')) {
      return (
        <span>
          See the <a href={this.state.component.get('documentationUrl')}>documentation</a> for more details about this configuration.
        </span>
      );
    } else {
      return null;
    }
  },

  render() {
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
            <div classNmae="col-xs-4">
              <p className="help-block">This component has to be configured manually. {this.documentationLink()} </p>
              <Configuration
                data={this.getConfigData()}
                isEditing={this.state.isEditing}
                isSaving={this.state.isSaving}
                onEditStart={this.onEditStart}
                onEditCancel={this.onEditCancel}
                onEditChange={this.onEditChange}
                onEditSubmit={this.onEditSubmit}
                isValid={this.state.isValidEditingConfigData}
                />

            </div>
          </div>
        </div>
        <div className="col-md-3 kbc-main-sidebar">
          <div classNmae="kbc-buttons kbc-text-light">
            <ComponentMetadata
              componentId={this.state.componentId}
              configId={this.state.config.get('id')}
              />
          </div>
          <ul className="nav nav-stacked">
            <li>
              <RunComponentButton
                title="Run"
                component={this.state.componentId}
                mode="link"
                runParams={this.runParams()}
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
        </div>
      </div>
    );
  },

  runParams() {
    return () => ({config: this.state.config.get('id')});
  },

  getConfigData() {
    if(this.state.isEditing) {
      return this.state.editingConfigData;
    } else {
      return JSON.stringify(this.state.configData.toJSON(), null, '  ');
    }
  },

  onEditStart() {
    InstalledComponentsActionCreators.startEditComponentRawConfigData(this.state.componentId, this.state.config.get('id'));
  },

  onEditCancel() {
    InstalledComponentsActionCreators.cancelEditComponentRawConfigData(this.state.componentId, this.state.config.get('id'));
  },

  onEditChange(newValue) {
    InstalledComponentsActionCreators.updateEditComponentRawConfigData(this.state.componentId, this.state.config.get('id'), newValue);
  },

  onEditSubmit() {
    InstalledComponentsActionCreators.saveComponentRawConfigData(this.state.componentId, this.state.config.get('id'));
  }
});
