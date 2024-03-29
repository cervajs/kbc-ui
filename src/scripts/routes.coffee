React = require 'react'
Router = require 'react-router'
App = require './react/layout/App'
ErrorPage = require './react/pages/ErrorPage'
Home = require './modules/home/react/Index'

componentsRoutes = require './modules/components/Routes'
orchestrationsRoutes = require './modules/orchestrations/Routes'
jobsRoutes = require './modules/jobs/Routes'
transformationsRoutes = require './modules/transformations/Routes'
applications = require './modules/applications/Routes'

StorageActionCreators = require './modules/components/StorageActionCreators'

ProjectBackup = require './modules/project-backup/Index'


# Custom routing configuration object
routes =
  handler: App
  path: '/'
  title: 'Overview'
  name: 'app'
  defaultRouteHandler: Home
  defaultRouteName: 'home'
  notFoundRouteHandler: ErrorPage
  childRoutes: [
      orchestrationsRoutes
    ,
      componentsRoutes.extractors
    ,
      componentsRoutes.writers
    ,
      componentsRoutes.applications
    ,
      jobsRoutes
    ,
      transformationsRoutes
    ,
      name: 'project-backup'
      title: 'Project Backup'
      defaultRouteHandler: ProjectBackup

  ]



module.exports = routes
