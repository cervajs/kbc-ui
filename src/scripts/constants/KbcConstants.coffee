keyMirror = require('react/lib/keyMirror')

module.exports =

  PayloadSources: keyMirror(
    SERVER_ACTION: null
    VIEW_ACTION: null
  )

  ActionTypes: keyMirror(
    COMPONENTS_SET_FILTER: null

    ORCHESTRATIONS_LOAD: null
    ORCHESTRATIONS_LOAD_SUCCESS: null
    ORCHESTRATIONS_LOAD_ERROR: null
    ORCHESTRATIONS_SET_FILTER: null

    ORCHESTRATION_LOAD: null
    ORCHESTRATION_LOAD_SUCCESS: null
    ORCHESTRATION_LOAD_ERROR: null
    ORCHESTRATION_ACTIVATE: null
    ORCHESTRATION_DISABLE: null

    APPLICATION_DATA_RECEIVED: null
  )
