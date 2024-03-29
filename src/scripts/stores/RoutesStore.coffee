Dispatcher = require('../Dispatcher')
Immutable = require 'immutable'
Map = Immutable.Map
List = Immutable.List
Error = require '../utils/Error'
StoreUtils = require '../utils/StoreUtils'
_ = require 'underscore'
JobsStore = require '../modules/jobs/stores/JobsStore'

Immutable = require('immutable')
Constants = require '../constants/KbcConstants'

_store = Map(
  router: null
  isPending: false
  routerState: Map()
  routesByName: Map()
  breadcrumbs: List()
)




###
  Converts nested routes structure to flat Map indexed by route name
###
nestedRoutesToByNameMap = (route) ->
  map = {}
  traverse  = (route) ->
    if route.name
      map[route.name] = route

    if route.childRoutes
      route.childRoutes.forEach traverse

  traverse(route)
  Immutable.fromJS map

getRoute = (store, routeName) ->
  route = store.getIn ['routesByName', routeName]

  if !route
    route = store.get('routesByName').find((route) -> route.get('defaultRouteName') == routeName)

  route

###
 Returns title for route
###
getRouteTitle = (store, routeName) ->
  route = getRoute(store, routeName)
  title = if route then route.get 'title' else ''

  if _.isFunction title
    title(store.get 'routerState')
  else
    title


getRouteIsRunning = (store, routeName) ->
  route = getRoute(store, routeName)
  isRunning = if route then route.get 'isRunning' else false
  if _.isFunction isRunning
    isRunning(store.get 'routerState')
  else
    isRunning

getCurrentRouteName = (store) ->
  routes = store.getIn ['routerState', 'routes'], List()
  route = routes.findLast((route) ->
    !!route.get('name')
  )
  if route
    route.get 'name'
  else
    null

generateBreadcrumbs = (store) ->
  if store.has 'error'
    List.of(
      Map(
        name: 'error'
        title: store.get('error').getTitle()
      )
    )
  else
    currentParams = store.getIn ['routerState', 'params']
    store.getIn(['routerState', 'routes'], List())
      .shift()
      .filter((route) -> !!route.get 'name')
      .map((route) ->
        Map(
          title: getRouteTitle(store, route.get 'name')
          name: route.get 'name'
          link: Map(
            to: route.get 'name'
            params: currentParams
          )
        )
      )


RoutesStore = StoreUtils.createStore

  isError: ->
    _store.has 'error'

  getRouter: ->
    _store.get 'router'

  getBreadcrumbs: ->
    _store.get 'breadcrumbs'

  getCurrentRouteConfig: ->
    _store.getIn ['routesByName', getCurrentRouteName(_store)]

  getRouterState: ->
    _store.get 'routerState'

  getCurrentRouteParam: (paramName) ->
    @getRouterState().getIn ['params', paramName]

  getCurrentRouteIntParam: (paramName) ->
    parseInt(@getCurrentRouteParam paramName)

  getCurrentRouteTitle: ->
    currentRouteName = getCurrentRouteName(_store)
    getRouteTitle(_store, currentRouteName)

  getCurrentRouteIsRunning: ->
    currentRouteName = getCurrentRouteName(_store)
    getRouteIsRunning(_store, currentRouteName)

  ###
    If it'is a component route, component id is returned
    componet is some writer or extractor like wr-db or ex-db
  ###
  getCurrentRouteComponentId: ->
    foundRoute = _store
    .getIn(['routerState', 'routes'], List())
    .find (route) ->
      routeConfig = getRoute _store, route.get('name')
      return false if !routeConfig
      routeConfig.get 'isComponent', false

    return foundRoute.get('name') if foundRoute


  ###
    Returns if route change is pending
  ###
  getIsPending: ->
    _store.get 'isPending'

  ###
    @return Error
  ###
  getError: ->
    _store.get 'error'

  hasRoute: (routeName) ->
    !!getRoute(_store, routeName)

  getRequireDataFunctionsForRouterState: (routes) ->
    Immutable
      .fromJS(routes)
      .map((route) ->
        requireDataFunctions = _store.getIn ['routesByName', route.get('name'), 'requireData']
        if !Immutable.List.isList(requireDataFunctions)
          requireDataFunctions = Immutable.List.of(requireDataFunctions)
        requireDataFunctions
      )
      .flatten()
      .filter((func) -> _.isFunction func)

  getPollersForRoutes: (routes) ->
    route = Immutable
      .fromJS(routes)
      .filter((route) -> !!route.get 'name')
      .last() # use poller only from last route in hiearchy

    pollerFunctions = _store.getIn ['routesByName', route.get('name'), 'poll'], List()
    if !Immutable.List.isList(pollerFunctions)
      pollerFunctions = Immutable.List.of(pollerFunctions)

    pollerFunctions

Dispatcher.register (payload) ->
  action = payload.action

  switch action.type

    when Constants.ActionTypes.ROUTER_ROUTE_CHANGE_START
      # set pending only if path was changed - will not show pending indicator when only query is change
      # like search in jobs
      currentState = RoutesStore.getRouterState()
      if !(currentState && currentState.get('pathname') == action.routerState.pathname)
        _store = _store.set 'isPending', true

    when Constants.ActionTypes.ROUTER_ROUTE_CHANGE_SUCCESS
      # jobs status (playing icon in header) can be changed so wait for it
      Dispatcher.waitFor([JobsStore.dispatchToken])

      _store = _store.withMutations (store) ->
        newState = Immutable.fromJS(action.routerState)
        notFound = newState.get('routes').last().get('name') == 'notFound'

        store = store.set 'isPending', false
        if notFound
          store
            .set 'error', new Error.Error('Page not found', 'Page not found')
            .set 'routerState', newState
        else
          store
            .remove 'error'
            .set 'routerState', newState

        store.set 'breadcrumbs', generateBreadcrumbs(store)

    when Constants.ActionTypes.ROUTER_ROUTE_CHANGE_ERROR
      _store = _store.withMutations (store) ->
        store = store
          .set 'isPending', false
          .set 'error', Error.create(action.error)

        store.set 'breadcrumbs', generateBreadcrumbs(store)

    when Constants.ActionTypes.ROUTER_ROUTES_CONFIGURATION_RECEIVE
      _store = _store.set 'routesByName', nestedRoutesToByNameMap(action.routes)

    when Constants.ActionTypes.ROUTER_ROUTER_CREATED
      _store = _store.set 'router', action.router

  # Emit change on events
  # for example orchestration is loaed asynchronously while breadcrumbs are already rendered so it has to be rendered again
  RoutesStore.emitChange()


module.exports = RoutesStore
