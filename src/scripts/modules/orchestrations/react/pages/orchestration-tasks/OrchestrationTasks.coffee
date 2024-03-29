React = require 'react'

createStoreMixin = require '../../../../../react/mixins/createStoreMixin'

# actions and stores
OrchestrationsActionCreators = require '../../../ActionCreators'
OrchestrationStore = require '../../../stores/OrchestrationsStore'
ComponentsStore = require '../../../../components/stores/ComponentsStore'
RoutesStore = require '../../../../../stores/RoutesStore'

# React components
OrchestrationsNav = React.createFactory(require './../orchestration-detail/OrchestrationsNav')
SearchRow = React.createFactory(require '../../../../../react/common/SearchRow')
TasksTable = React.createFactory(require './TasksTable')
TasksEditor = React.createFactory(require './TasksEditor')

{div, button} = React.DOM

OrchestrationTasks = React.createClass
  displayName: 'OrchestrationTasks'
  mixins: [createStoreMixin(OrchestrationStore, ComponentsStore)]

  getStateFromStores: ->
    orchestrationId = RoutesStore.getCurrentRouteIntParam 'orchestrationId'
    isEditing = OrchestrationStore.isEditing(orchestrationId, 'tasks')
    if isEditing
      tasks = OrchestrationStore.getEditingValue(orchestrationId, 'tasks')
    else
      tasks = OrchestrationStore.getOrchestrationTasks(orchestrationId)
    return {
      orchestration: OrchestrationStore.get orchestrationId
      tasks: tasks
      components: ComponentsStore.getAll()
      filter: OrchestrationStore.getFilter()
      isEditing: isEditing
      isSaving: OrchestrationStore.isSaving(orchestrationId, 'tasks')
      filteredOrchestrations: OrchestrationStore.getFiltered()
    }

  componentDidMount: ->
    # start edit if orchestration is empty
    if !@state.isEditing && @state.tasks.count() == 0
      OrchestrationsActionCreators.startOrchestrationTasksEdit(@state.orchestration.get('id'))

  componentWillReceiveProps: ->
    @setState(@getStateFromStores())

  _handleFilterChange: (query) ->
    OrchestrationsActionCreators.setOrchestrationsFilter(query)

  _handleTasksChange: (newTasks) ->
    OrchestrationsActionCreators.updateOrchestrationsTasksEdit(@state.orchestration.get('id'), newTasks)

  _handleTaskRun: (task) ->
    if @state.tasks.count()
      tasks = @state.tasks.map((item) ->
        if item.get('id') is task.get('id')
          item.set('active', true)
        else
          item.set('active', false)
      ).toJS()
    else
      tasks = {}

    OrchestrationsActionCreators.runOrchestration(@state.orchestration.get('id'), tasks, true)

  render: ->
    div {className: 'container-fluid kbc-main-content'},
      div {className: 'col-md-3 kb-orchestrations-sidebar kbc-main-nav'},
        div {className: 'kbc-container'},
          SearchRow(onChange: @_handleFilterChange, query: @state.filter)
          OrchestrationsNav
            orchestrations: @state.filteredOrchestrations
            activeOrchestrationId: @state.orchestration.get 'id'
      div {className: 'col-md-9 kb-orchestrations-main kbc-main-content-with-nav'},
        if @state.isEditing
          div null,
            TasksEditor
              tasks: @state.tasks
              isSaving: @state.isSaving
              components: @state.components
              onChange: @_handleTasksChange
        else
          div null,
            TasksTable
              tasks: @state.tasks
              orchestration: @state.orchestration
              components: @state.components
              onRun: @_handleTaskRun



module.exports = OrchestrationTasks
