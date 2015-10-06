Dispatcher = require('../../../Dispatcher')
constants = require '../Constants'
Immutable = require('immutable')
Map = Immutable.Map
StoreUtils = require '../../../utils/StoreUtils'

_store = Map(
  configData: Map() #componentId #configId
  configDataLoading: Map() #componentId #configId - configuration detail JSON
  configDataEditing: Map() #componentId #configId - configuration
  configDataEditingObject: Map() #componentId #configId - configuration
  configDataParametersEditing: Map() #componentId #configId - configuration
  rawConfigDataEditing: Map() #componentId #configId - configuration stringified JSON
  rawConfigDataParametersEditing: Map() #componentId #configId - configuration stringified JSON
  #detail JSON
  configDataSaving: Map()
  configDataParametersSaving: Map()
  localState: Map()

  components: Map()
  editingConfigurations: Map()
  savingConfigurations: Map()
  deletingConfigurations: Map()
  isLoaded: false
  isLoading: false
  pendingActions: Map()
  openMappings: Map()
)

InstalledComponentsStore = StoreUtils.createStore

  getLocalState: (componentId, configId) ->
    _store.getIn ['localState', componentId, configId], Map()

  getAll: ->
    _store
    .get 'components'
    .sortBy (component) -> component.get 'name'

  getAllForType: (type) ->
    @getAll().filter (component) ->
      component.get('type') == type

  getComponent: (componentId) ->
    _store.getIn ['components', componentId]

  getIsConfigDataLoaded: (componentId, configId) ->
    _store.hasIn ['configData', componentId, configId]

  getEditingConfigData: (componentId, configId, defaultValue) ->
    _store.getIn ['configDataEditing', componentId, configId], defaultValue

  getEditingRawConfigData: (componentId, configId, defaultValue) ->
    _store.getIn ['rawConfigDataEditing', componentId, configId], defaultValue

  getEditingRawConfigDataParameters: (componentId, configId, defaultValue) ->
    _store.getIn ['rawConfigDataParametersEditing', componentId, configId], defaultValue

  getSavingConfigData: (componentId, configId) ->
    _store.getIn ['configDataSaving', componentId, configId]

  getSavingConfigDataParameters: (componentId, configId) ->
    _store.getIn ['configDataParametersSaving', componentId, configId]

  getConfigData: (componentId, configId) ->
    _store.getIn ['configData', componentId, configId]

  getEditingConfigDataObject: (componentId, configId) ->
    _store.getIn ['configDataEditingObject', componentId, configId], Map()

  getConfigDataParameters: (componentId, configId) ->
    _store.getIn(['configData', componentId, configId, 'parameters'], Map())

  getConfig: (componentId, configId) ->
    _store.getIn ['components', componentId, 'configurations', configId]

  isEditingConfig: (componentId, configId, field) ->
    _store.hasIn ['editingConfigurations', componentId, configId, field]

  isEditingConfigData: (componentId, configId) ->
    _store.hasIn ['editingConfigData', componentId, configId]

  isEditingRawConfigData: (componentId, configId) ->
    _store.hasIn ['rawConfigDataEditing', componentId, configId]

  isEditingRawConfigDataParameters: (componentId, configId) ->
    _store.hasIn ['rawConfigDataParametersEditing', componentId, configId]

  getEditingConfig: (componentId, configId, field) ->
    _store.getIn ['editingConfigurations', componentId, configId, field]

  isValidEditingConfig: (componentId, configId, field) ->
    value = @getEditingConfig(componentId, configId, field)
    return true if value == undefined
    switch field
      when 'description' then true
      when 'name' then value.trim().length > 0

  isValidEditingConfigData: (componentId, configId) ->
    value = @getEditingRawConfigData(componentId, configId)
    try
      JSON.parse(value)
      return true
    return false

  isValidEditingConfigDataParameters: (componentId, configId) ->
    value = @getEditingRawConfigDataParameters(componentId, configId)
    try
      JSON.parse(value)
      return true
    return false

  getDeletingConfigurations: ->
    _store.get 'deletingConfigurations'

  isDeletingConfig: (componentId, configId) ->
    _store.hasIn ['deletingConfigurations', componentId, configId]

  isSavingConfig: (componentId, configId, field) ->
    _store.hasIn ['savingConfigurations', componentId, configId, field]

  isSavingConfigData: (componentId, configId) ->
    _store.hasIn ['configDataSaving', componentId, configId]

  isSavingConfigDataParameters: (componentId, configId) ->
    _store.hasIn ['configDataParametersSaving', componentId, configId]

  getIsLoading: ->
    _store.get 'isLoading'

  getIsLoaded: ->
    _store.get 'isLoaded'

  getPendingActions: (componentId, configId) ->
    _store.getIn ['pendingActions', componentId, configId], Map()

  getOpenMappings: (componentId, configId) ->
    _store.getIn ['openMappings', componentId, configId], Map()

Dispatcher.register (payload) ->
  action = payload.action

  switch action.type
    when constants.ActionTypes.INSTALLED_COMPONENTS_LOCAL_STATE_UPDATE
      data = action.data
      path = ['localState', action.componentId, action.configId]
      _store = _store.setIn path, data
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_START
      path = ['configDataEditing', action.componentId, action.configId]
      configData = InstalledComponentsStore.getConfigData(action.componentId, action.configId)
      _store = _store.setIn path, configData
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_UPDATE
      path = ['configDataEditing', action.componentId, action.configId]
      configData = action.data
      _store = _store.setIn path, configData
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_EDIT_CANCEL
      path = ['configDataEditing', action.componentId, action.configId]
      _store = _store.deleteIn path
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_START
      path = ['rawConfigDataEditing', action.componentId, action.configId]
      configData = InstalledComponentsStore.getConfigData(action.componentId, action.configId)
      _store = _store.setIn path, JSON.stringify(configData, null, '  ')
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_UPDATE
      path = ['rawConfigDataEditing', action.componentId, action.configId]
      configData = action.data
      _store = _store.setIn path, configData
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_EDIT_CANCEL
      path = ['rawConfigDataEditing', action.componentId, action.configId]
      _store = _store.deleteIn path
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_START
      path = ['rawConfigDataParametersEditing', action.componentId, action.configId]
      configData = InstalledComponentsStore.getConfigDataParameters(action.componentId, action.configId)
      _store = _store.setIn path, JSON.stringify(configData, null, '  ')
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_UPDATE
      path = ['rawConfigDataParametersEditing', action.componentId, action.configId]
      configData = action.data
      _store = _store.setIn path, configData
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_EDIT_CANCEL
      path = ['rawConfigDataParametersEditing', action.componentId, action.configId]
      _store = _store.deleteIn path
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD
      _store = _store.setIn ['configDataLoading', action.componentId, action.configId], true
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD_SUCCESS
      _store = _store.deleteIn ['configDataLoading', action.componentId, action.configId]
      storePath = ['configData', action.componentId, action.configId]
      _store = _store.setIn storePath, Immutable.fromJS(action.configData)
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_LOAD_ERROR
      _store = _store.deleteIn ['configDataLoading', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_START
      componentId = action.componentId
      configId = action.configId
      editingDataJson = JSON.parse(InstalledComponentsStore.getEditingRawConfigData(componentId, configId))
      editingData = Immutable.fromJS(editingDataJson)
      dataToSave = editingData
      _store = _store.setIn ['configDataSaving', componentId, configId], dataToSave

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_SUCCESS
      configDataObject = Immutable.fromJS(action.configData)
      _store = _store.setIn ['configData', action.componentId, action.configId], configDataObject
      _store = _store.deleteIn ['configDataSaving', action.componentId, action.configId]
      _store = _store.deleteIn ['rawConfigDataEditing', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATA_SAVE_ERROR
      _store = _store.deleteIn ['configDataSaving', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_START
      componentId = action.componentId
      configId = action.configId
      editingDataJson = JSON.parse(InstalledComponentsStore.getEditingRawConfigDataParameters(componentId, configId))
      editingData = Immutable.fromJS(editingDataJson)
      dataToSave = editingData
      _store = _store.setIn ['configDataParametersSaving', componentId, configId], dataToSave

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_SUCCESS
      configData = _store.getIn ['rawConfigDataParametersEditing', action.componentId, action.configId]
      configDataObject = Immutable.fromJS(JSON.parse(configData))
      path = ['configData', action.componentId, action.configId, 'parameters']
      _store = _store.setIn path, configDataObject
      _store = _store.deleteIn ['configDataParametersSaving', action.componentId, action.configId]
      _store = _store.deleteIn ['rawConfigDataParametersEditing', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_RAWCONFIGDATAPARAMETERS_SAVE_ERROR
      _store = _store.deleteIn ['configDataParametersSaving', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_START
      componentId = action.componentId
      configId = action.configId
      forceData = action.forceData
      editingData = InstalledComponentsStore.getEditingConfigData(componentId, configId)
      dataToSave = forceData or editingData
      _store = _store.setIn ['configDataSaving', componentId, configId], dataToSave

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_SUCCESS
      _store = _store.setIn ['configData', action.componentId, action.configId], Immutable.fromJS(action.configData)
      _store = _store.deleteIn ['configDataSaving', action.componentId, action.configId]
      _store = _store.deleteIn ['configDataEditing', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGDATA_SAVE_ERROR
      _store = _store.deleteIn ['configDataSaving', action.componentId, action.configId]
      InstalledComponentsStore.emitChange()


    when constants.ActionTypes.INSTALLED_COMPONENTS_LOAD
      _store = _store.set 'isLoading', true
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_LOAD_ERROR
      _store = _store.set 'isLoading', false
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_START
      _store = _store.withMutations (store) ->
        store.setIn ['editingConfigurations', action.componentId, action.configurationId, action.field],
          InstalledComponentsStore.getConfig(action.componentId, action.configurationId).get action.field
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_UPDATE
      _store = _store.setIn ['editingConfigurations', action.componentId, action.configurationId, action.field],
        action.value
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_EDIT_CANCEL
      _store = _store.deleteIn ['editingConfigurations', action.componentId, action.configurationId, action.field]
      InstalledComponentsStore.emitChange()


    when constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_START
      _store = _store.setIn ['deletingConfigurations', action.componentId, action.configurationId], true
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_SUCCESS
      _store = _store.withMutations (store) ->
        store
        .deleteIn ['components', action.componentId, 'configurations', action.configurationId]
        .deleteIn ['deletingConfigurations', action.componentId, action.configurationId]

        if !store.getIn(['components', action.componentId, 'configurations']).count()
          store = store.deleteIn ['components', action.componentId]

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_DELETE_CONFIGURATION_ERROR
      _store = _store.deleteIn ['deletingConfigurations', action.componentId, action.configurationId]
      InstalledComponentsStore.emitChange()



    when constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_START
      _store = _store.setIn ['savingConfigurations', action.componentId, action.configurationId, action.field], true
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_ERROR
      _store = _store.deleteIn ['savingConfigurations', action.componentId, action.configurationId, action.field]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_UPDATE_CONFIGURATION_SUCCESS
      _store = _store.withMutations (store) ->
        store
          .mergeIn ['components', action.componentId, 'configurations', action.configurationId],
            Immutable.fromJS(action.data)
          .deleteIn ['savingConfigurations', action.componentId, action.configurationId, action.field]
          .deleteIn ['editingConfigurations', action.componentId, action.configurationId, action.field]
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_LOAD_SUCCESS
      _store = _store.withMutations((store) ->
        store
          .set('isLoading', false)
          .set('isLoaded', true)
          .set('components',
            ## convert to by key structure
            Immutable.fromJS(action.components)
            .toMap()
            .map((component) ->
              component.set 'configurations', component.get('configurations').toMap().mapKeys((key, config) ->
                config.get 'id'
              )
            )
            .mapKeys((key, component) ->
              component.get 'id'
            ))
      )
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.COMPONENTS_NEW_CONFIGURATION_SAVE_SUCCESS
      _store = _store.withMutations (store) ->
        if !store.hasIn ['components', action.componentId]
          store = store.setIn(['components', action.componentId], action.component.set('configurations', Map()))

        store.setIn ['components', action.componentId, 'configurations', action.configuration.id],
          Immutable.fromJS action.configuration

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_TOGGLE_MAPPING
      if (_store.getIn(['openMappings', action.componentId, action.configId, action.index], false))
        _store = _store.setIn(['openMappings', action.componentId, action.configId, action.index], false)
      else
        _store = _store.setIn(['openMappings', action.componentId, action.configId, action.index], true)

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_START
      currentMapping = InstalledComponentsStore.getConfigData(action.componentId, action.configId)
      .getIn(['storage', action.mappingType, action.storage, action.index])
      path = [
        'configDataEditingObject', action.componentId,
        action.configId, 'storage', action.mappingType, action.storage, action.index
      ]
      _store = _store.setIn(path, currentMapping)
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_CANCEL
      path = [
        'configDataEditingObject', action.componentId,
        action.configId, 'storage', action.mappingType, action.storage, action.index
      ]
      _store = _store.deleteIn(path)
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_EDITING_CHANGE
      path = [
        'configDataEditingObject', action.componentId,
        action.configId, 'storage', action.mappingType, action.storage, action.index
      ]
      _store = _store.setIn(path, action.value)
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_START
      path = [
        'pendingActions', action.componentId,
        action.configId, action.mappingType, action.storage, action.index, 'save'
      ]
      _store = _store.setIn(path, true)
      InstalledComponentsStore.emitChange()


    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_SUCCESS
      _store = _store.withMutations (store) ->
        path = [
          'pendingActions', action.componentId,
          action.configId, action.mappingType, action.storage, action.index, 'save'
        ]
        store = store.deleteIn(path)

        path = [
          'configDataEditingObject', action.componentId, action.configId,
          'storage', action.mappingType, action.storage, action.index
        ]
        store = store.deleteIn(path)

        storePath = ['configData', action.componentId, action.configId]
        store.setIn storePath, Immutable.fromJS(action.data.configuration)

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_SAVE_ERROR
      _store = _store.withMutations (store) ->
        path = [
          'pendingActions', action.componentId,
          action.configId, action.mappingType, action.storage, action.index, 'save'
        ]
        store = store.deleteIn(path)

        path = [
          'configDataEditingObject', action.componentId,action.configId,
          'storage', action.mappingType, action.storage, action.index
        ]
        store.deleteIn(path)

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_START
      path = [
        'pendingActions', action.componentId,
        action.configId, action.mappingType, action.storage, action.index, 'delete'
      ]
      _store = _store.setIn(path, true)
      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_SUCCESS
      _store = _store.withMutations (store) ->
        path = [
          'pendingActions', action.componentId,
          action.configId, action.mappingType, action.storage, action.index, 'delete'
        ]
        store = store.deleteIn(path)

        storePath = ['configData', action.componentId, action.configId]
        store.setIn storePath, Immutable.fromJS(action.data.configuration)

      InstalledComponentsStore.emitChange()

    when constants.ActionTypes.INSTALLED_COMPONENTS_CONFIGURATION_MAPPING_DELETE_ERROR
      path = [
        'pendingActions', action.componentId,
        action.configId, action.mappingType, action.storage, action.index, 'delete'
      ]
      _store = _store.deleteIn(path)
      InstalledComponentsStore.emitChange()


module.exports = InstalledComponentsStore
