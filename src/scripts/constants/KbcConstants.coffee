keyMirror = require('react/lib/keyMirror')

module.exports =

  PayloadSources: keyMirror(
    SERVER_ACTION: null
    VIEW_ACTION: null
  )

  ActionTypes: keyMirror(
    # Components
    COMPONENTS_SET_FILTER: null
    COMPONENTS_LOAD_SUCCESS: null

    # Installed components
    INSTALLED_COMPONENTS_LOAD: null
    INSTALLED_COMPONENTS_LOAD_SUCCESS: null
    INSTALLED_COMPONENTS_LOAD_ERROR: null

    # Orchestrations
    ORCHESTRATIONS_LOAD: null
    ORCHESTRATIONS_LOAD_SUCCESS: null
    ORCHESTRATIONS_LOAD_ERROR: null
    ORCHESTRATIONS_SET_FILTER: null

    ORCHESTRATION_JOBS_LOAD: null
    ORCHESTRATION_JOBS_LOAD_SUCCESS: null
    ORCHESTRATION_JOBS_LOAD_ERROR: null

    ORCHESTRATION_LOAD: null
    ORCHESTRATION_LOAD_SUCCESS: null
    ORCHESTRATION_LOAD_ERROR: null
    ORCHESTRATION_ACTIVATE: null
    ORCHESTRATION_DISABLE: null

    ORCHESTRATION_JOB_LOAD: null
    ORCHESTRATION_JOB_LOAD_SUCCESS: null
    ORCHESTRATION_JOB_LOAD_ERROR: null

    # Application state
    APPLICATION_DATA_RECEIVED: null

    # Router state
    ROUTER_ROUTE_CHANGED: null
  )
