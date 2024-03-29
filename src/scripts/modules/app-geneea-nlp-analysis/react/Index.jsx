import React from 'react';
import {List, Map} from 'immutable';
import _ from 'underscore';
import {FormControls} from 'react-bootstrap';

import Select from 'react-select';
import classnames from 'classnames';

import Tooltip from '../../../react/common/Tooltip';
import SapiTableLinkEx from '../../components/react/components/StorageApiTableLinkEx';
import SapiTableSelector from '../../components/react/components/SapiTableSelector';

const StaticText = FormControls.Static;
//import installedComponentsActions from '../../components/InstalledComponentsActionCreators';
import {params,
  getInTable,
  updateLocalState,
  isOutputValid,
  updateEditingValue,
  startEditing,
  getEditingValue} from '../actions';

import createStoreMixin from '../../../react/mixins/createStoreMixin';
import RoutesStore from '../../../stores/RoutesStore';
import InstalledComponentStore from '../../components/stores/InstalledComponentsStore';
import LatestJobsStore from '../../jobs/stores/LatestJobsStore';
import storageTablesStore from '../../components/stores/StorageTablesStore';

//import EmptyState from '../../components/react/components/ComponentEmptyState';
import ComponentDescription from '../../components/react/components/ComponentDescription';
import ComponentMetadata from '../../components/react/components/ComponentMetadata';
import RunComponentButton from '../../components/react/components/RunComponentButton';
import DeleteConfigurationButton from '../../components/react/components/DeleteConfigurationButton';
import LatestJobs from '../../components/react/components/SidebarJobs';

import {analysisTypes, languageOptions} from './templates.coffee';

const componentId = 'geneea-nlp-analysis';


export default React.createClass({
  mixins: [createStoreMixin(storageTablesStore, InstalledComponentStore, LatestJobsStore)],

  getStateFromStores(){
    const configId = RoutesStore.getCurrentRouteParam('config');
    const localState = InstalledComponentStore.getLocalState(componentId, configId);
    const configData = InstalledComponentStore.getConfigData(componentId, configId);

    const intable = getInTable(configId);
    const parameters = configData.get('parameters', Map());

    console.log('CONFIG DATA', localState.toJS(), configData.toJS());
    return {
      configId: configId,
      localState: localState,
      configData: configData,
      intable: intable,
      parameters: parameters,
      editing: !!localState.get('editing'),
      latestJobs: LatestJobsStore.getJobs(componentId, configId)

    };
  },

  componentDidMount(){
    let data = this.state.configData;
    if (data) {
      data = data.toJS();
    }

    if (_.isEmpty(data)){
      startEditing(this.state.configId);
    }

  },

  parameter(key, defaultValue){
    return this.state.parameters.get(key, defaultValue);
  },

  render(){
    return (
      <div className="container-fluid">
        <div className="col-md-9 kbc-main-content">
          <div className="row kbc-header">
            <ComponentDescription
              componentId={componentId}
              configId={this.state.configId}
            />
          </div>
          <div className="row">
            <form className="form-horizontal">
              { this.state.editing ? this.renderEditing() : this.renderStatic()}
            </form>
          </div>
        </div>
        <div className="col-md-3 kbc-main-sidebar">
          <div classNmae="kbc-buttons kbc-text-light">
            <ComponentMetadata
              componentId={componentId}
              configId={this.state.configId}
              />
          </div>
          <ul className="nav nav-stacked">
            <li className={classnames({disabled: this.state.editing})}>
              <RunComponentButton
                title="Run Analysis"
                component={componentId}
                mode="link"
                runParams={ () => ({config: this.state.configId}) }
                disabledReason="Configuration is not saved."
                disabled={this.state.editing}
                >
                You are about to run the analysis job of selected task(s).
              </RunComponentButton>
            </li>
            <li>
              <DeleteConfigurationButton
                componentId={componentId}
                configId={this.state.configId}
                />
            </li>
          </ul>
          <LatestJobs jobs={this.state.latestJobs} />
        </div>
      </div>
    );
  },

  renderEditing(){
    const intableChange = (value) => {
      this.updateEditingValue('intable', value);
      this.updateEditingValue(params.DATACOLUMN, '');
      this.updateEditingValue(params.PRIMARYKEY, '');
    };
    const outputValid = isOutputValid(this.getEditingValue(params.OUTPUT));
    return (
      <div className="row">
        {this.renderFormElement('Input Table',
           <SapiTableSelector
            placeholder="Select..."
            value={this.getEditingValue('intable')}
            onSelectTableFn= {intableChange}
            excludeTableFn= { () => false}/>)
        }
        {this.renderColumnSelect('Data Column', params.DATACOLUMN, 'Column of the input table containing text to analyze.')}
        {this.renderColumnSelect('Primary Key', params.PRIMARYKEY, 'Column of the input table uniquely identifying a row in the table.')}
        {this.renderFormElement('Output Table Prefix',
          <input
            className="form-control"
            value={this.getEditingValue(params.OUTPUT)}
            onChange= {(event) => this.updateEditingValue(params.OUTPUT, event.target.value)}
          placeholder="e.g. out.c-main.result"/>,
         'Prefix of the output table id, if is only a bucket id then it must end with dot \'.\'', !outputValid)
        }
        {this.renderFormElement('Language',
          <Select
            key="language"
            name="language"
            clearable={false}
            value={this.getEditingValue(params.LANGUAGE)}
            onChange= {(newValue) => this.updateEditingValue(params.LANGUAGE, newValue)}
            options= {languageOptions}/>, 'Language of the text of the data column.')
        }
        {this.renderAnalysisTypesSelect()}
      </div>
    );
  },

  renderAnalysisTypesSelect(){
    const selectedTypes = this.getEditingValue(params.ANALYSIS);
    const options = _.map( _.keys(analysisTypes), (value) => {
      const checked = (selectedTypes.contains(value));
      const onChange = (e) => {
        const isChecked = e.target.checked;
        const newSelected = isChecked ? selectedTypes.push(value) : selectedTypes.filter( (t) => t !== value);
        this.updateEditingValue(params.ANALYSIS, newSelected);
      };
      const info = analysisTypes[value];
      return (
        <div className="checkbox">
          <label>
            <input
             type="checkbox"
             checked={checked}
             onChange={onChange}/>
            <span>
              {info.name}
            </span>
            <p className="help-block">{info.description}</p>
          </label>
        </div>
      );
    }
    );

    return this.renderFormElement('Analysis tasks', options);

  },


  renderFormElement(label, element, description = '', hasError){
    let errorClass = 'form-group';
    if (hasError){
      errorClass = 'form-group has-error';
    }

    return (
      <div className={errorClass}>
        <label className="control-label col-sm-3">
          {label}
        </label>
        <div className="col-sm-9">
          {element}
          <span className="help-block">{description}</span>
        </div>
      </div>
    );
  },

  renderColumnSelect(label, column, description){
    const result = this.renderFormElement(label,
      <Select
        clearable={false}
        key={column}
        name={column}
        value={this.getEditingValue(column)}
        onChange= {(newValue) => this.updateEditingValue(column, newValue)}
        options= {this.getColumns()}
      />
    , description);
    return result;

  },

  renderStatic(){
    // {this.renderStaticTasks()}
    return (
      <div className="row">
        {this.renderIntableStatic()}
        {this.RenderStaticInput('Data Column', this.parameter(params.DATACOLUMN) )}
        {this.RenderStaticInput('Primary Key', this.parameter(params.PRIMARYKEY ))}
        {this.RenderStaticInput('Output Table Prefix', this.parameter(params.OUTPUT) )}
        {this.RenderStaticInput('Language', this.parameter(params.LANGUAGE))}

        {this.RenderStaticInput('Analysis tasks', this.renderStaticTasks())}
      </div>
    );
  },

  renderStaticTasks(){
    const tasks = this.parameter(params.ANALYSIS, List());
    const outParam = this.parameter(params.OUTPUT, '');
    let renderedTasks = tasks.map((task) => {
      //const comma = idx === 0 ? '' : ', ';
      const info = analysisTypes[task];
      const outTableId = outParam ? `${outParam}${task}` : '';
      return (
        <li>
          <span className="col-sm-12" style={{ paddingLeft: 0}}>
            <Tooltip tooltip={info.description} placement="top">
              <span className="col-sm-4" style={{ paddingLeft: 0}}>
                <strong className="text-left">
                  {info.name}
                </strong>
              </span>
            </Tooltip> <i style={{ paddingLeft: 0}}
                          className="kbc-icon-arrow-right col-sm-1"></i>
            <SapiTableLinkEx className="col-sm-4" tableId={outTableId}/>
          </span>

        </li>
      );
    }).toArray();
    return (<ul className="nav nav-stacked">{renderedTasks}</ul>);
  },

  renderIntableStatic(){
    const tableId = this.state.intable;
    const link = (<p
        label="Input Table"
        className="form-control-static">
        <SapiTableLinkEx
          tableId={tableId}/></p>
    );
    return this.renderFormElement((<span>Input Table</span>), link);

  },

  RenderStaticInput(label, value){
    return (
      <StaticText
        label={label}
        labelClassName="col-sm-3"
        wrapperClassName="col-sm-9">
        {value || 'n/a'}
      </StaticText>
    );
  },

  getColumns(){
    const tableId = this.getEditingValue('intable');
    const tables = storageTablesStore.getAll();

    if (!tableId || !tables){
      return [];
    }

    const table = tables.find((ptable) => {
      return ptable.get('id') === tableId;
    });

    if (!table){
      return [];
    }
    const result = table.get('columns').map( (column) =>
      {
        return {
          'label': column,
          'value': column
        };
      }
    ).toList().toJS();

    return result;
  },

  updateEditingValue(prop, value){
    updateEditingValue(this.state.configId, prop, value);
  },

  getEditingValue(prop){
    return getEditingValue(this.state.configId, prop);
  },

  updateLocalState(path, data){
    updateLocalState(this.state.configId, path, data);
  }

});
