React = require 'react'
{Map, fromJS} = require 'immutable'
moment = require 'moment'
classnames = require 'classnames'

LatestJobsStore = require '../../../../jobs/stores/LatestJobsStore'
LatestJobs = require '../../../../components/react/components/SidebarJobs'

Link = React.createFactory(require('react-router').Link)

InstalledComponentsStore = require '../../../../components/stores/InstalledComponentsStore'
StorageFilesStore = require '../../../../components/stores/StorageFilesStore'
RoutesStore = require '../../../../../stores/RoutesStore'
createStoreMixin = require '../../../../../react/mixins/createStoreMixin'
TableRow = require './TableRow'

{Tooltip, OverlayTrigger, ModalFooter, Modal, ModalHeader, ModalTitle, ModalBody} = require('react-bootstrap')

RunButtonModal = React.createFactory(require('../../../../components/react/components/RunComponentButton'))

ComponentDescription = require '../../../../components/react/components/ComponentDescription'
ComponentDescription = React.createFactory(ComponentDescription)
ComponentMetadata = require '../../../../components/react/components/ComponentMetadata'
DeleteConfigurationButton = require '../../../../components/react/components/DeleteConfigurationButton'
TablesByBucketsPanel = React.createFactory require('../../../../components/react/components/TablesByBucketsPanel')
InstalledComponentsActions = require '../../../../components/InstalledComponentsActionCreators'

AddNewTableModal = require './AddNewTableModal'

componentId = 'tde-exporter'
{a, p, ul, li, span, button, strong, div, i} = React.DOM

module.exports = React.createClass
  displayName: 'tdeindex'
  mixins: [createStoreMixin(InstalledComponentsStore, LatestJobsStore)]

  getStateFromStores: ->
    configId = RoutesStore.getCurrentRouteParam('config')
    configData = InstalledComponentsStore.getConfigData(componentId, configId)
    localState = InstalledComponentsStore.getLocalState(componentId, configId)
    typedefs = configData.getIn(['parameters', 'typedefs'], Map()) or Map()
    files = StorageFilesStore.getAll()
    isSaving = InstalledComponentsStore.getSavingConfigData(componentId, configId)

    #state
    latestJobs: LatestJobsStore.getJobs(componentId, configId)
    files: files
    configId: configId
    configData: configData
    localState: localState
    typedefs: typedefs
    isSaving: isSaving

  render: ->
    #console.log @state.configData.toJS()
    div {className: 'container-fluid'},
      @_renderMainContent()
      @_renderSideBar()

  _renderMainContent: ->
    div {className: 'col-md-9 kbc-main-content'},
      div className: 'row kbc-header',
        div className: 'col-sm-8',
          ComponentDescription
            componentId: componentId
            configId: @state.configId
        if not @_isEmptyConfig()
          div className: 'col-sm-4 kbc-buttons',
            @_addNewTableButton()
            @_renderAddNewTable()
      if not @_isEmptyConfig()
        @_renderTables()
      else
        div className: 'row component-empty-state text-center',
          div null,
            p null, 'No tables configured.'
            @_addNewTableButton()
            @_renderAddNewTable()


  _renderTables: ->
    TablesByBucketsPanel
      renderTableRowFn: @_renderTableRow
      renderHeaderRowFn: @_renderHeaderRow
      filterFn: @_filterBuckets
      isTableExportedFn: (tableId) =>
        @state.typedefs?.has tableId
      onToggleBucketFn: @_handleToggleBucket
      isBucketToggledFn: @_isBucketToggled
      showAllTables: false
      toggleShowAllFn: null
      configuredTables: @state.typedefs?.keySeq().toJS()
      #renderDeletedTableRowFn: (table) =>
      #  @_renderTableRow(table, true)


  _renderSideBar: ->
    div {className: 'col-md-3 kbc-main-sidebar'},
      div className: 'kbc-buttons kbc-text-light',
        React.createElement ComponentMetadata,
          componentId: componentId
          configId: @state.configId
      ul className: 'nav nav-stacked',
        li className: classnames(disabled: !!@_disabledToRun()),
          RunButtonModal
            disabled: !!@_disabledToRun()
            disabledReason: @_disabledToRun()
            title: "Export tables to TDE"
            tooltip: "Export all configured tables to TDE files"
            mode: 'link'
            component: componentId
            runParams: =>
              config: @state.configId
          ,
           "You are about to run export of all configured tables to TDE"
        li null,
          @_renderSetupDestinationLink()
        li null,
          React.createElement DeleteConfigurationButton,
            componentId: componentId
            configId: @state.configId

      React.createElement LatestJobs,
        jobs: @state.latestJobs


  _renderSetupDestinationLink: ->
    Link
      to: 'tde-exporter-destination'
      className: 'btn btn-link '
      params:
        config: @state.configId
    ,
      i className: 'fa fa-fw fa-gear'
      ' Setup Upload Destinations'


  _renderTableRow: (table, isDeleted = false) ->
    tableId = table.get 'id'
    React.createElement TableRow,
      table: table
      configId: @state.configId
      tdeFile: @_getLastTdeFile(tableId)
      prepareRunDataFn: =>
        @_prepareRunTableData(tableId)
      deleteRowFn: =>
        @_deleteTable(tableId)
      configData: @state.configData
      uploadComponentId: @state.localState.get('uploadComponentId')
      uploadComponentIdSetFn: (uploadComponentId) =>
        @_updateLocalState(['uploadComponentId'], uploadComponentId)



  _filterBuckets: (buckets) ->
    buckets = buckets.filter (bucket) ->
      bucket.get('stage') == 'out' or bucket.get('stage') == 'in'
    return buckets

  _renderAddNewTable: ->
    show = !!@state.localState?.getIn(['newTable','show'])
    return React.createElement AddNewTableModal,
      show: show
      selectedTableId: @state.localState?.getIn(['newTable', 'id'])
      configuredTables: @state.configData.getIn(['parameters', 'typedefs'])
      configId: @state.configId
      onHideFn: =>
        @_updateLocalState(['newTable'], Map())
      onSetTableIdFn: (value) =>
        @_updateLocalState(['newTable', 'id'], value)
      onSaveFn: (selectedTableId) =>
        RoutesStore.getRouter().transitionTo("tde-exporter-table",
          config: @state.configId
          tableId: selectedTableId
        )




  _addNewTableButton: ->
    button
      className: 'btn btn-success'
      onClick: =>
        @_updateLocalState(['newTable', 'show'], true)
      span className: 'kbc-icon-plus'
      ' Add Table'

  _renderHeaderRow: ->
    div className: 'tr',
      span className: 'th',
        strong null, 'Table name'
      span className: 'th',
        strong null, 'Last TDE File'
      span className: 'th',
        strong null, ''

  _getLastTdeFile: (tableId) ->
    idReplaced = tableId.replace(/-/g,"_")
    filename = "#{idReplaced}.tde"
    files = @state.files.filter (file) ->
      file.get('name') == filename
    latestFile = files.max (a, b) ->
      adate = moment(a.get('created'))
      bdate = moment(b.get('created'))
      if adate == bdate
        return 0
      if adate > bdate
        return 1
      else
        return -1
    return latestFile

  _deleteTable: (tableId) ->
    configData = @state.configData
    intables = configData.getIn ['storage', 'input', 'tables']
    if intables
      intables = intables.filter (intable) ->
        intable.get('source') != tableId
      configData = configData.setIn ['storage', 'input', 'tables'], intables
    configData = configData.deleteIn ['parameters', 'typedefs', tableId]

    updateFn = InstalledComponentsActions.saveComponentConfigData
    tableId = @state.tableId
    updateFn(componentId, @state.configId, configData)

  _prepareRunTableData: (tableId) ->
    configData = @state.configData
    intables = configData.getIn ['storage', 'input', 'tables']
    intables = intables.filter (intable) ->
      intable.get('source') == tableId
    configData = configData.setIn ['storage', 'input', 'tables'], intables
    typedefs = configData.getIn ['parameters', 'typedefs', tableId]
    configData = configData.setIn ['parameters', 'typedefs'], Map()
    configData = configData.setIn ['parameters', 'typedefs', tableId], typedefs
    tags = ["config-#{@state.configId}"]
    configData = configData.setIn ['parameters', 'tags'], fromJS(tags)
    data =
      configData: configData.toJS()
      config: @state.configId
    console.log 'RUN', data
    return data


  _disabledToRun: ->
    if @_isEmptyConfig()
      return "No tables configured"
    return null

  _isEmptyConfig: ->
    tables = @state.configData.getIn ['storage', 'input', 'tables']
    not (tables and tables.count() > 0)

  _handleToggleBucket: (bucketId) ->
    newValue = !@_isBucketToggled(bucketId)
    bucketToggles = @state.localState.get 'bucketToggles', Map()
    newToggles = bucketToggles.set(bucketId, newValue)
    @_updateLocalState(['bucketToggles'], newToggles)

  _isBucketToggled: (bucketId) ->
    bucketToggles = @state.localState.get 'bucketToggles', Map()
    !!bucketToggles.get(bucketId)

  _updateLocalState: (path, data) ->
    newLocalState = @state.localState.setIn(path, data)
    InstalledComponentsActions.updateLocalState(componentId, @state.configId, newLocalState)
