IntalledComponentsStore = require '../components/stores/InstalledComponentsStore'

ExGanalIndex = require './react/pages/index/Index'
ExGanalActionCreators = require './exGanalActionCreators'
#authorizePage = require './react/pages/authorize/authorize'
#ExGanalSheetHeaderButtons = require './react/components/SheetHeaderButtons'


module.exports =
  name: 'ex-google-analytics'
  path: 'ex-google-analytics/:config'
  defaultRouteHandler: ExGanalIndex
  requireData: [
    (params) ->
      ExGanalActionCreators.loadConfiguration params.config
  ]

  title: (routerState) ->
    configId = routerState.getIn ['params', 'config']
    'Google Analytics extractor - ' + IntalledComponentsStore.getConfig('ex-google-analytics', configId).get 'name'

  childRoutes: [
    name: 'ex-google-analytics-select-profiles'
    path: 'profiles'
    title: 'Select Profiles'
  ,
    name: 'ex-google-analytics-query'
    path: 'query/:name'
    title: 'Query'
  ,
    name: 'ex-google-analytics-authorize'
    path: 'Authorize'
    title: 'Authorize'
  ,
    name: 'ex-google-analytics-new-query'
    path: 'Query'
    title: 'New Query'

  ]
