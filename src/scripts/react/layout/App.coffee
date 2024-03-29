React = require 'react'
RouteHandler = React.createFactory(require('react-router').RouteHandler)
ApplicationStore = require '../../stores/ApplicationStore'

Header = React.createFactory(require '././Header')
SidebarNavigation = React.createFactory(require '././SidebarNavigation')
FloatingNotifications = require './FloatingNotifications'
ErrorPage = React.createFactory(require './../pages/ErrorPage')
LoadingPage = React.createFactory(require './../pages/LoadingPage')
ProjectSelect = React.createFactory(require './project-select/ProjectSelect')
PageTitle = React.createFactory(require './PageTitle')

CurrentUser = React.createFactory(require './CurrentUser')
UserLinks = React.createFactory(require './UserLinks')

{div} = React.DOM

require '../../../styles/app.less'

App = React.createClass
  displayName: 'App'
  propTypes:
    isError: React.PropTypes.bool
    isLoading: React.PropTypes.bool
  getInitialState: ->
    organizations: ApplicationStore.getOrganizations()
    maintainers: ApplicationStore.getMaintainers()
    currentProject: ApplicationStore.getCurrentProject()
    currentAdmin: ApplicationStore.getCurrentAdmin()
    urlTemplates: ApplicationStore.getUrlTemplates()
    xsrf: ApplicationStore.getXsrfToken()
    canCreateProject: ApplicationStore.getCanCreateProject()
    canManageApps: ApplicationStore.getKbcVars().get 'canManageApps'
    homeUrl: ApplicationStore.getUrlTemplates().get 'home'
  render: ->
    div null,
      PageTitle()
      Header
        homeUrl: @state.homeUrl
      React.createElement(FloatingNotifications)
      div className: 'container-fluid',
        div className: 'row',
          div className: 'col-xs-3 kbc-sidebar',
            ProjectSelect
              organizations: @state.organizations
              currentProject: @state.currentProject
              urlTemplates: @state.urlTemplates
              xsrf: @state.xsrf
              canCreateProject: @state.canCreateProject
            SidebarNavigation()
            div className: 'kbc-sidebar-footer',
              CurrentUser
                user: @state.currentAdmin
                maintainers: @state.maintainers
                urlTemplates: @state.urlTemplates
                canManageApps: @state.canManageApps
                dropup: true
              UserLinks()
          div className: 'col-xs-9 col-xs-offset-3 kbc-main',
            if @props.isError
              ErrorPage()
            else if @props.isLoading
              LoadingPage()
            else
              RouteHandler()


module.exports = App
