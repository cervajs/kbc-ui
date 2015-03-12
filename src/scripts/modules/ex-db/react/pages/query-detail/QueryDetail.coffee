React = require 'react'

createStoreMixin = require '../../../../../react/mixins/createStoreMixin'

ExDbStore = require '../../../exDbStore'
StorageTablesStore = require '../../../../components/stores/StorageTablesStore'
RoutesStore = require '../../../../../stores/RoutesStore'

ExDbActionCreators = require '../../../exDbActionCreators'

QueryEditor = React.createFactory(require '../../components/QueryEditor')
QueryDetailStatic = React.createFactory(require './QueryDetailStatic')


{div, table, tbody, tr, td, ul, li, a, span, h2, p, strong} = React.DOM


module.exports = React.createClass
  displayName: 'ExDbQueryDetail'
  mixins: [createStoreMixin(ExDbStore, StorageTablesStore)]

  componentWillReceiveProps: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    configId = RoutesStore.getCurrentRouteParam 'config'
    queryId = RoutesStore.getCurrentRouteIntParam 'query'
    isEditing = ExDbStore.isEditingQuery configId, queryId
    configId: configId
    query: ExDbStore.getConfigQuery configId, queryId
    editingQuery: ExDbStore.getEditingQuery configId, queryId
    isEditing: isEditing
    tables: StorageTablesStore.getAll()

  _handleQueryChange: (newQuery) ->
    ExDbActionCreators.updateEditingQuery @state.configId, newQuery

  render: ->
    if @state.isEditing
      QueryEditor
        query: @state.editingQuery
        tables: @state.tables
        onChange: @_handleQueryChange
    else
      QueryDetailStatic
        query: @state.query
