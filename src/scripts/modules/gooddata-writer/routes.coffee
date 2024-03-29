
actionCreators = require './actionCreators'
InstalledComponentsStore = require '../components/stores/InstalledComponentsStore'
GoodDataWriterStore = require './store'

IndexPage = require './react/pages/index/Index'
TablePage = require './react/pages/table/Table'
WriterReloader = require './react/components/WritersReloaderButton'
TablePageHeaderButtons = require './react/components/TableHeaderButtons'
TablePageHeaderExportStatus = require './react/components/TableHeaderExportStatus'
DateDimensionsPage = require './react/pages/date-dimensions/DateDimensions'
ModelPage = require './react/pages/model/Model'


module.exports =
  name: 'gooddata-writer'
  path: 'gooddata-writer/:config'
  isComponent: true
  requireData: [
    (params) ->
      actionCreators.loadConfiguration params.config
  ]
  title: (routerState) ->
    configId = routerState.getIn ['params', 'config']
    'GoodData - ' + InstalledComponentsStore.getConfig('gooddata-writer', configId).get 'name'
  defaultRouteHandler: IndexPage
  reloaderHandler: WriterReloader
  childRoutes: [
    name: 'gooddata-writer-table'
    path: 'table/:table'
    requireData: [
      (params) ->
        actionCreators.loadTableDetail(params.config, params.table)
    ,
      (params) ->
        actionCreators.loadReferenceableTables(params.config)
    ]
    title: (routerState) ->
      configId = routerState.getIn ['params', 'config']
      tableId = routerState.getIn ['params', 'table']
      table = GoodDataWriterStore.getTable(configId, tableId)
      "table #{table.get('id')}"
    handler: TablePage
    headerButtonsHandler: TablePageHeaderButtons
    reloaderHandler: TablePageHeaderExportStatus
  ,
    name: 'gooddata-writer-date-dimensions'
    path: 'dimensions'
    title: ->
      'Date dimensions'
    requireData: [
      (params) ->
        actionCreators.loadDateDimensions params.config
    ]
    handler: DateDimensionsPage
  ,
    name: 'gooddata-writer-model'
    path: 'model'
    title: 'Model'
    handler: ModelPage
  ]
