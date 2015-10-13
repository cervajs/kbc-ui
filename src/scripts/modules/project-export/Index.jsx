import React from 'react';
import {Map} from 'immutable';
import {Link} from 'react-router';
import Form from './Form';

import actionCreators from '../components/InstalledComponentsActionCreators';
import createStoreMixin from '../../react/mixins/createStoreMixin';
import InstalledComponentsStore from '../components/stores/InstalledComponentsStore';


const COMPONENT_ID = 'kbc-project-backup',
  CONFIG_ID = '.new-tmp-config';

export default React.createClass({

  mixins: [createStoreMixin(InstalledComponentsStore)],

  getStateFromStores() {
    const defaultParameters = Map({
      awsAccessKeyId: '',
      '#awsSecretAccessKey': '',
      s3bucket: '',
      s3path: '',
      onlyStructure: false
    });
    return {
      parameters: InstalledComponentsStore.getEditingConfigData(COMPONENT_ID, CONFIG_ID, defaultParameters)
    };
  },

  getInitialState() {
    return {
      isSaving: false,
      jobId: null
    };
  },

  render() {
    return (
      <div className="container-fluid">
        <div className="col-md-9 kbc-main-content">
          <div className="row kbc-header">
            <div className="kbc-title">
              <span className="kb-sapi-component-icon pull-left">
                <img src="https://d3iz2gfan5zufq.cloudfront.net/images/cloud-services/cloudsearch32-1.png" />
              </span>
              <h2>AWS S3</h2>
              <p>Cloud storage for the Internet</p>
            </div>
          </div>
          <div className="row">
            <p>
              You can export whole your Keboola Connection project into <a href="http://aws.amazon.com/s3/">AWS S3</a>.
            </p>
            <p>
              <strong>
                Export will contain
              </strong>
            </p>
            <ul>
              <li>All buckets and tables metadata</li>
              <li>Data exported to gzipped CSV files for all tables</li>
              <li>All components configurations</li>
            </ul>
          </div>
          <div className="row">
            <Form
              parameters={this.state.parameters}
              onChange={this.handleParametersChange}
              onRun={this.handleRun}
              isValid={this.isValid()}
              isSaving={this.state.isSaving}
              savedMessage={this.savedMessage()}
              />
          </div>
        </div>
      </div>
    );
  },

  isValid() {
    const requiredFields = [
      'awsAccessKeyId',
      '#awsSecretAccessKey',
      's3bucket'
    ];
    return this.state.parameters
        .filter((value, key) => requiredFields.indexOf(key) >= 0)
        .filter((value) => value === '').count() === 0;
  },

  handleParametersChange(newParameters) {
    actionCreators.updateEditComponentConfigData(COMPONENT_ID, CONFIG_ID, newParameters);
  },

  handleRun() {
    this.setState({
      isSaving: true,
      jobId: null
    });
    actionCreators.runComponent({
      component: COMPONENT_ID,
      notify: false,
      data: {
        configData: {
          parameters: this.state.parameters.toJS()
        }
      }
    }).then((job) => {
      this.setState({
        isSaving: false,
        jobId: job.id
      });
    }).catch((e) => {
      this.setState({
        isSaving: false
      });
      throw e;
    });
  },

  savedMessage() {
    if (!this.state.jobId) {
      return null;
    }
    return (
      <span>
        Export started. You can track progress <Link to="jobDetail" params={{jobId: this.state.jobId}}>here</Link>
      </span>
    );
  }

});