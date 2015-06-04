React = require 'react'
Immutable = require('immutable')
{span, div, a, p, h2, label, input, form} = React.DOM
_ = require 'underscore'
Input = React.createFactory(require('react-bootstrap').Input)
createStoreMixin = require '../../../../../../../react/mixins/createStoreMixin'
InstalledComponentsStore = require '../../../../../../components/stores/InstalledComponentsStore'
InstalledComponentsActions = require '../../../../../../components/InstalledComponentsActionCreators'
storageActionCreators = require '../../../../../../components/StorageActionCreators'
storageTablesStore = require '../../../../../../components/stores/StorageTablesStore'
Select = React.createFactory(require('react-select'))

fuzzy = require 'fuzzy'

RoutesStore = require '../../../../../../../stores/RoutesStore'
StaticText = React.createFactory(require('react-bootstrap').FormControls.Static)
Autosuggest = React.createFactory(require 'react-autosuggest')

createGetSuggestions = (getOptions) ->
  (input, callback) ->
    suggestions = getOptions()
      .filter (value) -> fuzzy.match(input, value)
      .slice 0, 10
      .toList()
    callback(null, suggestions.toJS())


module.exports = React.createClass

  displayName: 'GeneeaAppDetail'

  mixins: [createStoreMixin(InstalledComponentsStore, storageTablesStore)]
  getStateFromStores: ->
    configId = RoutesStore.getCurrentRouteParam('config')
    configData = InstalledComponentsStore.getConfigData("geneea-topic-detection", configId)
    editingConfigData = InstalledComponentsStore.getEditingConfigData("geneea-topic-detection", configId)

    inputTables = configData?.getIn ['configuration', 'storage', 'input', 'tables']
    intable = inputTables?.get(0)?.get 'source'
    outTables = configData?.getIn ['configuration', 'storage', 'output', 'tables']
    outTable = outTables?.get(0)?.get 'source'
    parameters = configData?.getIn ['configuration','parameters']
    editingData = @_prepareEditingData(editingConfigData)


    data_column: parameters?.get 'data_column'
    primary_key_column: parameters?.get 'primary_key_column'
    intable: intable
    outtable: outTable
    isEditing: true
    editingData: editingData
    configId: configId

  componentWillMount: ->
    storageActionCreators.loadTables()
  componentDidMount: ->
    storageActionCreators.loadTables()

  render: ->
    div {className: 'container-fluid kbc-main-content'},
      form className: 'form-horizontal',
        if @state.isEditing
          @_renderEditorRow()
        else
          div className: 'row',
            @_createInput('Input Table', @state.intable)
            @_createInput('Data Column', @state.data_column)
            @_createInput('Primary Key', @state.primary_key_column)
            @_createInput('Output Table', @state.outtable)


  _renderEditorRow: ->
    div className: 'row',
      div className: 'form-group',
        label className: 'col-xs-2 control-label', 'Source Table'
        div className: 'col-xs-10',
          Select
            key: 'sourcetable'
            name: 'source'
            value: @state.editingData.intable
            placeholder: "Source table"
            onChange: (newValue) =>
              newEditingData = @state.editingData
              newEditingData.intable = newValue
              @setState
                editingData: newEditingData
              @_updateEditingConfig()
            options: @_getTables()
      div className: 'form-group',
        label className: 'col-xs-2 control-label', 'Data Column'
        div className: 'col-xs-10',
          Select
            key: 'datacol'
            name: 'data_column'
            value: @state.editingData.data_column
            placeholder: "Data Column"
            onChange: (newValue) =>
              newEditingData = @state.editingData
              newEditingData.data_column = newValue
              @setState
                editingData: newEditingData
              @_updateEditingConfig()
            options: @_getColumns()
      div className: 'form-group',
        label className: 'col-xs-2 control-label', 'Primary Key'
        div className: 'col-xs-10',
          Select
            key: 'primcol'
            name: 'primary_key_column'
            value: @state.editingData.primary_key_column
            placeholder: "Primary Key Column"
            onChange: (newValue) =>
              newEditingData = @state.editingData
              newEditingData.primary_key_column = newValue
              @setState
                editingData: newEditingData
              @_updateEditingConfig()
            options: @_getColumns()
      div className: 'form-group',
        label className: 'control-label col-xs-2', 'Output Table'
        div className: "col-xs-10",
        Autosuggest
          suggestions: createGetSuggestions(@_getOutTables)
          inputAttributes:
            className: 'form-control'
            placeholder: 'to get hint start typing'
            value: @state.editingData.outtable
            onChange: (newValue) =>
              newEditingData = @state.editingData
              newEditingData.outtable = newValue
              @setState
                editingData: newEditingData
              @_updateEditingConfig()


  _getTables: ->
    tables = storageTablesStore.getAll()
    tables.filter( (table) ->
      table.getIn(['bucket','stage']) != 'sys').map( (value,key) ->
      {
        label: key
        value: key
      }
      ).toList().toJS()

  _getOutTables: ->
    tables = storageTablesStore.getAll()
    tables.filter( (table) ->
      table.getIn(['bucket','stage']) != 'sys').map( (value,key) ->
      return key
      )

  _getColumns: ->
    tableId = @state.editingData?.intable
    tables = storageTablesStore.getAll()
    if !tableId or !tables
      return []
    table = tables.find((table) ->
      table.get("id") == tableId
    )
    return [] if !table
    result = table.get("columns").map( (column) ->
      console.log column
      {
        id: column
        label: column
      }
    ).toList().toJS()
    return result

  _createInput: (caption, value) ->
    pvalue =
    StaticText
      label: caption
      labelClassName: 'col-xs-4'
      wrapperClassName: 'col-xs-8'
    , value or 'N/A'

  _prepareEditingData: (editingData) ->
    console.log "editing data", editingData
    getTables = (source) ->
      editingData?.getIn ['storage', source, 'tables']
    params = editingData?.get 'parameters'

    intable: getTables('input')?.get(0)?.get('source')
    outtable: getTables('output')?.get(0)?.get('source')
    primary_key_column: params?.get 'primary_key_column'
    data_column: params?.get 'data_column'

  _updateEditingConfig: ->
    columns = _.map @_getColumns(), (value, key) ->
      key
    setup = @state.editingData
    template =
      storage:
        input:
          tables: [{source: setup.intable, columns: columns}]
        output:
          tables: [{source: setup.outtable, destination: setup.outtable}]
      parameters:
        'primary_key_column': setup.primary_key_column
        data_column: setup.data_column
        user_key: '9cf1a9a51553e32fda1ecf101fc630d5'
    updateFn = InstalledComponentsActions.updateEditComponentConfigData
    data = Immutable.fromJS template
    updateFn 'geneea-topic-detection', @state.configId, data
