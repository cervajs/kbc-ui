Promise = require 'bluebird'
React = require 'react'
_ = require 'underscore'
Link = require('react-router').Link
Immutable = require('immutable')

ApplicationActionCreators = require '../../actions/ApplicationActionCreators'
JobsActionCreators = require '../../modules/jobs/ActionCreators'

dispatcher = require '../../Dispatcher'
constants = require './Constants'
componentRunner = require './ComponentRunner'
InstalledComponentsStore = require './stores/InstalledComponentsStore'
installedComponentsApi = require './InstalledComponentsApi'
RoutesStore = require '../../stores/RoutesStore'
ComponentsStore = require './stores/ComponentsStore'

deleteComponentConfiguration = require './utils/deleteComponentConfiguration'

storeEncodedConfig = (componentId, configId, dataToSave) ->
  component = InstalledComponentsStore.getComponent(componentId)
  if component.get('flags').includes('encrypt')
    encoded  = installedComponentsApi
    .encryptData(component.get('uri'), dataToSave)
    encoded.then((result) ->
      dataToSave = {configuration: JSON.stringify(result)}
      installedComponentsApi
      .updateComponentConfiguration(componentId, configId, dataToSave)
    )
  else
    dataToSave = {configuration: JSON.stringify(dataToSave)}
    installedComponentsApi
    .updateComponentConfiguration(componentId, configId, dataToSave)

module.exports =

  loadComponentsForce: ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_LOAD
    )

    installedComponentsApi
    .getComponents()
    .then((components) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_LOAD_SUCCESS
        components: components
      )
    )
    .catch((error) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_LOAD_ERROR
        status: error.status
        response: error.response
      )
      throw error
    )

  loadComponentConfigDataForce: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD
      componentId: componentId
      configId: configId
    )
    installedComponentsApi
    .getComponentConfigData(componentId, configId).then (configData) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD_SUCCESS
        componentId: componentId
        configId: configId
        configData: configData
      )
      return configData
    .catch (error) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD_ERROR
        componentId: componentId
        configId: configId
      )
      throw error

  #loads configuration JSON data of the component and specified configId
  loadComponentConfigData: (componentId, configId) ->
    return Promise.resolve() if InstalledComponentsStore.getIsConfigDataLoaded()
    @loadComponentConfigDataForce(componentId, configId)

  saveComponentRawConfigData: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_START
      componentId: componentId
      configId: configId
    )
    dataToSave = InstalledComponentsStore.getSavingConfigData(componentId, configId)
    dataToSave = dataToSave?.toJS()

    storeEncodedConfig(componentId, configId, dataToSave).then (response) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_SUCCESS
        componentId: componentId
        configId: configId
        configData: response.configuration
      )
    .catch (error) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_ERROR
        componentId: componentId
        configId: configId
      )
      throw error

  saveComponentRawConfigDataParameters: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_START
      componentId: componentId
      configId: configId
    )
    parametersToSave = InstalledComponentsStore.getSavingConfigDataParameters(componentId, configId)
    parametersToSave = parametersToSave?.toJS()
    # rest of the config
    dataToSave = InstalledComponentsStore.getConfigData(componentId, configId)
    dataToSave = dataToSave?.toJS()
    dataToSave.parameters = parametersToSave

    storeEncodedConfig(componentId, configId, dataToSave).then (response) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_SUCCESS
        componentId: componentId
        configId: configId
        configData: response.configuration
      )

    .catch (error) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_ERROR
        componentId: componentId
        configId: configId
      )
      throw error


  saveComponentConfigData: (componentId, configId, forceData) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_START
      componentId: componentId
      configId: configId
      forceData: forceData
    )
    dataToSave = InstalledComponentsStore.getSavingConfigData(componentId, configId)
    dataToSave = dataToSave?.toJS()

    storeEncodedConfig(componentId, configId, dataToSave).then (response) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_SUCCESS
        componentId: componentId
        configId: configId
        configData: response.configuration
      )
    .catch (error) ->
      dispatcher.handleViewAction(
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_ERROR
        componentId: componentId
        configId: configId
      )
      throw error

  updateLocalState: (componentId, configId, data) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_LOCAL_STATE_UPDATE
      componentId: componentId
      configId: configId
      data: data
    )

  startEditComponentConfigData: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_START
      componentId: componentId
      configId: configId
    )

  updateEditComponentConfigData: (componentId, configId, newData) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_UPDATE
      componentId: componentId
      configId: configId
      data: newData
    )

  cancelEditComponentConfigData: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_CANCEL
      componentId: componentId
      configId: configId
    )

  startEditComponentRawConfigData: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_START
      componentId: componentId
      configId: configId
    )

  updateEditComponentRawConfigData: (componentId, configId, newData) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_UPDATE
      componentId: componentId
      configId: configId
      data: newData
    )

  cancelEditComponentRawConfigData: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_CANCEL
      componentId: componentId
      configId: configId
    )

  startEditComponentRawConfigDataParameters: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_START
      componentId: componentId
      configId: configId
    )

  updateEditComponentRawConfigDataParameters: (componentId, configId, newData) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_UPDATE
      componentId: componentId
      configId: configId
      data: newData
    )

  cancelEditComponentRawConfigDataParameters: (componentId, configId) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_CANCEL
      componentId: componentId
      configId: configId
    )

  loadComponents: ->
    return Promise.resolve() if InstalledComponentsStore.getIsLoaded()
    @loadComponentsForce()

  receiveAllComponents: (componentsRaw) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_LOAD_SUCCESS
      components: componentsRaw
    )

  startConfigurationEdit: (componentId, configurationId, field) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_START
      componentId: componentId
      configurationId: configurationId
      field: field

  updateEditingConfiguration: (componentId, configurationId, field, newValue) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_UPDATE
      configurationId: configurationId
      componentId: componentId
      field: field
      value: newValue

  cancelConfigurationEdit: (componentId, configurationId, field) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_CANCEL
      componentId: componentId
      configurationId: configurationId
      field: field

  saveConfigurationEdit: (componentId, configurationId, field) ->
    newValue = InstalledComponentsStore.getEditingConfig(componentId, configurationId, field)

    dispatcher.handleViewAction
      type: constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_START
      componentId: componentId
      configurationId: configurationId
      field: field

    data = {}
    data[field] = newValue

    storeEncodedConfig componentId, configurationId, data
    .then (response) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_SUCCESS
        componentId: componentId
        configurationId: configurationId
        field: field
        data: response
    .catch (e) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_ERROR
        componentId: componentId
        configurationId: configurationId
        field: field
        error: e
      throw e


  deleteConfiguration: (componentId, configurationId) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_START
      componentId: componentId
      configurationId: configurationId

    component = ComponentsStore.getComponent componentId
    configuration = InstalledComponentsStore.getConfig componentId, configurationId
    transitionTo = "#{component.get('type')}s"

    notification = "Configuration #{configuration.get('name')} was deleted."

    RoutesStore.getRouter().transitionTo transitionTo

    deleteComponentConfiguration componentId, configurationId
    .then (response) ->

      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_SUCCESS
        componentId: componentId
        configurationId: configurationId

      ApplicationActionCreators.sendNotification
        message: notification

    .catch (e) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_ERROR
        componentId: componentId
        configurationId: configurationId
        error: e

      throw e


  ###
    params:
      - component - id of component like ex-db
      - data - action parameters hashmap
      - method - default = run
      - message - enqueue message
      - notify - send notification, default true
  ###
  runComponent: (params) ->

    defaultParams =
      method: 'run'
      message: 'Job has been scheduled.'
      notify: true

    params = _.extend {}, defaultParams, params

    componentRunner.run
      component: params.component
      data: params.data
      method: params.method
    .then (job) ->
      JobsActionCreators.recieveJobDetail(job)
      if params.notify
        ApplicationActionCreators.sendNotification(
          message: React.createClass
            render: ->
              React.DOM.span null,
                "#{params.message} You can track the job progress "
                React.createElement Link,
                  to: 'jobDetail'
                  params:
                    jobId: job.id
                  onClick: @props.onClick
                ,
                  'here'
                '.'
      )
      job

  toggleMapping: (componentId, configId, index) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_TOGGLE_MAPPING
      componentId: componentId
      configId: configId
      index: index
    )

  startEditingMapping: (componentId, configId, type, storage, index) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_START
      componentId: componentId
      configId: configId
      mappingType: type
      storage: storage
      index: index
    )

  cancelEditingMapping: (componentId, configId, type, storage, index) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_CANCEL
      componentId: componentId
      configId: configId
      mappingType: type
      storage: storage
      index: index
    )

  changeEditingMapping: (componentId, configId, type, storage, index, value) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_CHANGE
      componentId: componentId
      configId: configId
      mappingType: type
      storage: storage
      index: index
      value: value
    )

  saveEditingMapping: (componentId, configId, type, storage, index) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_START
      componentId: componentId
      configId: configId
      mappingType: type
      storage: storage
      index: index
    )

    dataToSave = InstalledComponentsStore.getConfigData(componentId, configId)
    mappingData = InstalledComponentsStore.getEditingConfigDataObject(componentId, configId)

    pathSource = ['storage', type, storage, index]
    if index == 'new-mapping'
      lastIndex = dataToSave.getIn(['storage', type, storage], Immutable.List()).count()
      pathDestination = ['storage', type, storage, lastIndex]
    else
      pathDestination = pathSource

    data = dataToSave.setIn(pathDestination, mappingData.getIn(pathSource)).toJSON()
    storeEncodedConfig componentId, configId, data
    .then (response) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_SUCCESS
        componentId: componentId
        configId: configId
        mappingType: type
        storage: storage
        index: index
        data: response
    .catch (e) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_ERROR
        componentId: componentId
        configId: configId
        error: e
      throw e

  deleteMapping: (componentId, configId, type, storage, index) ->
    dispatcher.handleViewAction(
      type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_START
      componentId: componentId
      configId: configId
      mappingType: type
      storage: storage
      index: index
    )

    dataToSave = InstalledComponentsStore.getConfigData(componentId, configId)
    path = ['storage', type, storage, index]
    data = dataToSave.deleteIn(path).toJSON()
    storeEncodedConfig componentId, configId, data
    .then (response) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_SUCCESS
        componentId: componentId
        configId: configId
        mappingType: type
        storage: storage
        index: index
        data: response
    .catch (e) ->
      dispatcher.handleViewAction
        type: constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_ERROR
        componentId: componentId
        configId: configId
        error: e
      throw e
