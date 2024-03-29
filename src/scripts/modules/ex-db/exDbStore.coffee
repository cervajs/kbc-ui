
Dispatcher = require('../../Dispatcher')
constants = require './exDbConstants'
Immutable = require('immutable')
Map = Immutable.Map
StoreUtils = require '../../utils/StoreUtils'
fuzzy = require 'fuzzy'

_store = Map
  configs: Map()
  editingCredentials: Map() # [configId] - credentials
  savingCredentials: Map() # map of saving credentials ids
  editingQueries: Map() # [configId][queryId] - query
  queryPendingActions: Map() # [configId][queryId][] map of pending actions
  savingQueries: Map() # map of saving query ids
  newQueries: Map() # [configId]['query'] - query [configId]['isSaving'] = true or not set
  newCredentials: Map()
  queriesFilter: Map()



isValidQuery = (query) ->
  query.get('name', '').trim().length > 0

ExDbStore = StoreUtils.createStore

  getConfig: (configId) ->
    _store.getIn ['configs', configId]

  getQueriesFiltered: (configId) ->
    filter = @getQueriesFilter configId
    @getConfig(configId)
    .get('queries')
    .filter (query) ->
      fuzzy.match(filter, query.get('name')) ||
      fuzzy.match(filter, query.get('outputTable'))


  getQueriesFilter: (configId) ->
    _store.getIn ['queriesFilter', configId], ''

  getQueriesPendingActions: (configId) ->
    _store.getIn ['queryPendingActions', configId], Map()

  hasConfig: (configId) ->
    _store.hasIn ['configs', configId]

  getConfigQuery: (configId, queryId) ->
    _store.getIn ['configs', configId, 'queries', queryId]

  isEditingQuery: (configId, queryId) ->
    _store.hasIn ['editingQueries', configId, queryId]

  isEditingQueryValid: (configId, queryId) ->
    editingQuery = @getEditingQuery(configId, queryId)
    return false if !editingQuery
    isValidQuery editingQuery

  isSavingQuery: (configId, queryId) ->
    _store.hasIn ['savingQueries', configId, queryId]

  isSavingNewQuery: (configId) ->
    _store.getIn ['newQueries', configId, 'isSaving']

  getEditingQuery: (configId, queryId) ->
    _store.getIn ['editingQueries', configId, queryId]

  getNewQuery: (configId) ->
    _store.getIn ['newQueries', configId, 'query'], Map(
      incremental: false
      outputTable: ''
      primaryKey: ''
      query: ''
    )

  getNewCredentials: (configId) ->
    _store.getIn ['newCredentials', configId, 'credentials'],
      _store.getIn ['configs', configId, 'credentials']

  isValidNewQuery: (configId) ->
    isValidQuery(@getNewQuery(configId))

  isEditingCredentials: (configId) ->
    _store.hasIn ['editingCredentials', configId]

  isSavingCredentials: (configId) ->
    _store.hasIn ['savingCredentials', configId]

  getEditingCredentials: (configId) ->
    _store.getIn ['editingCredentials', configId]

Dispatcher.register (payload) ->
  action = payload.action

  switch action.type
    when constants.ActionTypes.EX_DB_CONFIGURATION_LOAD_SUCCESS
      configuration = Immutable.fromJS(action.configuration).withMutations (configuration) ->
        configuration.set 'queries', configuration.get('queries').toMap().mapKeys((key, query) ->
          query.get 'id'
        )
      _store = _store.setIn ['configs', action.configuration.id], configuration
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_CHANGE_ENABLED_START
      _store = _store.setIn ['queryPendingActions', action.configurationId, action.queryId, 'enabled'], true
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_CHANGE_ENABLED_ERROR
      _store = _store.deleteIn ['queryPendingActions', action.configurationId, action.queryId, 'enabled']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_CHANGE_ENABLED_SUCCESS
      _store = _store.withMutations (store) ->
        store
        .deleteIn ['queryPendingActions', action.configurationId, action.queryId, 'enabled']
        .setIn ['configs', action.configurationId, 'queries', action.queryId],
          Immutable.fromJS action.query
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_DELETE_START
      _store = _store.withMutations (store) ->
        store.setIn ['queryPendingActions', action.configurationId, action.queryId, 'deleteQuery'], true
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_DELETE_SUCCESS
      _store = _store.withMutations (store) ->
        store
        .deleteIn ['configs', action.configurationId, 'queries', action.queryId]
        .deleteIn ['queryPendingActions', action.configurationId, action.queryId, 'deleteQuery']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_DELETE_ERROR
      _store = _store.deleteIn ['queryPendingActions', action.configurationId, action.queryId, 'deleteQuery']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_START
      _store = _store.withMutations (store) ->
        store.setIn ['editingQueries', action.configurationId, action.queryId],
          ExDbStore.getConfigQuery action.configurationId, action.queryId
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_CANCEL
      _store = _store.deleteIn ['editingQueries', action.configurationId, action.queryId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_UPDATE
      # query is already in ImmutableJS structure
      _store = _store.setIn ['editingQueries', action.configurationId, action.query.get('id')], action.query
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_QUERY_UPDATE
      # query is already in ImmutableJS structure
      _store = _store.setIn ['newQueries', action.configurationId, 'query'], action.query
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_QUERY_RESET
      _store = _store.deleteIn ['newQueries', action.configurationId, 'query']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_QUERY_SAVE_START
      _store = _store.setIn ['newQueries', action.configurationId, 'isSaving'], true
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_QUERY_SAVE_ERROR
      _store = _store.deleteIn ['newQueries', action.configurationId, 'isSaving']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_QUERY_SAVE_SUCCESS
      _store = _store.withMutations (store) ->
        store
          .setIn ['configs', action.configurationId, 'queries', action.query.id], Immutable.fromJS(action.query)
          .deleteIn ['newQueries', action.configurationId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_SAVE_START
      _store = _store.withMutations (store) ->
        store
        .setIn ['savingQueries', action.configurationId, action.queryId], true
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_SAVE_ERROR
      _store = _store.deleteIn ['savingQueries', action.configurationId, action.queryId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_QUERY_EDIT_SAVE_SUCCESS
      _store = _store.withMutations (store) ->
        store
        .setIn ['configs', action.configurationId, 'queries', action.queryId],
          Immutable.fromJS action.query
        .deleteIn ['editingQueries', action.configurationId, action.queryId]
        .deleteIn ['savingQueries', action.configurationId, action.queryId]
      ExDbStore.emitChange()

    ## Credentials edit handling
    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_START
      _store = _store.withMutations (store) ->
        #  set default driver to mysql
        credentials = ExDbStore.getConfig(action.configurationId).get('credentials')
        if !credentials.get 'driver'
          credentials = credentials.set('driver', 'mysql')
        store.setIn ['editingCredentials', action.configurationId],
          credentials
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_CANCEL
      _store = _store.deleteIn ['editingCredentials', action.configurationId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_UPDATE
      # credentials are already in ImmutableJS structure
      _store = _store.setIn ['editingCredentials', action.configurationId], action.credentials
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_SAVE_START
      _store = _store.withMutations (store) ->
        store
        .setIn ['savingCredentials', action.configurationId], true
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_SAVE_SUCCESS
      _store = _store.withMutations (store) ->
        store
        .setIn ['configs', action.configurationId, 'credentials'],
            Immutable.fromJS action.credentials
        .deleteIn ['editingCredentials', action.configurationId]
        .deleteIn ['savingCredentials', action.configurationId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_CREDENTIALS_EDIT_SAVE_ERROR
      _store = _store.deleteIn ['savingCredentials', action.configurationId]
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_CREDENTIALS_UPDATE
      _store = _store.setIn ['newCredentials', action.configurationId, 'credentials'], action.credentials
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_NEW_CREDENTIALS_RESET
      _store = _store.deleteIn ['newCredentials', action.configurationId, 'credentials']
      ExDbStore.emitChange()

    when constants.ActionTypes.EX_DB_SET_QUERY_FILTER
      _store = _store.setIn ['queriesFilter', action.configurationId], action.filter
      ExDbStore.emitChange()


module.exports = ExDbStore