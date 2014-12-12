React = require 'react'

ComponentsStore = require '../../../../components/stores/ComponentsStore.coffee'
{span, div, strong, h5} = React.DOM
{Panel, PanelGroup} = require('react-bootstrap')
Panel  = React.createFactory Panel
PanelGroup = React.createFactory PanelGroup

kbCommon = require '../../../../../react/common/common.coffee'
ComponentIcon = React.createFactory(kbCommon.ComponentIcon)
ComponentName = React.createFactory(kbCommon.ComponentName)
Duration = React.createFactory(kbCommon.Duration)
Tree = React.createFactory(kbCommon.Tree)
JobStatusLabel = React.createFactory(kbCommon.JobStatusLabel)

date = require '../../../../../utils/date.coffee'

JobTasks = React.createClass
  displayName: 'JobTasks'
  propTypes:
    tasks: React.PropTypes.object.isRequired

  getInitialState: ->
    components: ComponentsStore.getAll()

  render: ->
    PanelGroup accordion: true, @_renderTasks()

  _renderTasks: ->
    @props.tasks.map(@_renderTask, @).toArray()

  _renderTask: (task) ->
    component = @state.components.get(task.get('component'))
    header = span className: 'row',
      span className: 'col-sm-5',
        ComponentIcon size: '32', component: component
        ' '
        ComponentName component: component
      span className: 'col-sm-3',
        Duration startTime: task.get('startTime'), endTime: task.get('endTime')
      span className: 'col-sm-4',
        JobStatusLabel status: task.get('status') if task.has('status')

    Panel
      header: header
      key: task.get('id')
      eventKey: task.get('id')
    ,
      div(className: 'pull-right', date.format(task.get('startTime'))) if task.get('startTime')
      div(null, strong(null, 'POST'), ' ', task.get('runUrl')) if task.get('runUrl')
      h5 null, 'Parameters'
      Tree data: task.get('runParameters')
      if task.get('response')
        div null,
          h5(null, 'Response'),
          Tree data: task.get('response')


module.exports = JobTasks