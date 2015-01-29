IntalledComponentsStore = require '../components/stores/InstalledComponentsStore.coffee'

ExGdriveIndex = require './react/pages/index/Index.coffee'
ExGoogleDriveActionCreators = require './exGdriveActionCreators.coffee'

module.exports =
  name: 'ex-google-drive'
  path: 'ex-google-drive/:config'
  defaultRouteHandler: ExGdriveIndex
  requireData: [
    (params) ->
      ExGoogleDriveActionCreators.loadConfiguration params.config
  ]

  title: (routerState) ->
    configId = routerState.getIn ['params', 'config']
    'Google Drive extractor - ' + IntalledComponentsStore.getConfig('ex-google-drive', configId).get 'name'

  childRoutes: [
    name: 'ex-google-drive-new-query'
    path: 'new-query'
  ,
    name: 'ex-google-drive-authorize'
    path: 'authorize'
  ,
    name: 'ex-google-drive-sheet'
    path: 'sheet/:sheetId'
  ]