React = require 'react'

createStoreMixin = require '../../../../../react/mixins/createStoreMixin.coffee'

OrchestrationStore = require '../../../stores/OrchestrationsStore.coffee'
OrchestrationsActionCreators = require '../../../ActionCreators.coffee'

DurationWithIcon = React.createFactory(require '../../../../../react/common/DurationWithIcon.coffee')
FinishedWithIcon = React.createFactory(require '../../../../../react/common/FinishedWithIcon.coffee')
JobStatusCircle = React.createFactory(require '../../../../../react/common/JobStatusCircle.coffee')
Link = React.createFactory(require('react-router').Link)
State = require('react-router').State

{ a, span, div, strong, em} = React.DOM

OrchestrationRow = React.createFactory React.createClass(
  displayName: 'OrchestrationRow'
  propTypes:
    orchestration: React.PropTypes.object
  mixins: [ State ]
  render: ->
    isActive = @isActive('orchestration', id: @props.orchestration.get('id'))
    className = if isActive then 'active' else ''

    if  !@props.orchestration.get('active')
      disabled = (span {className: 'pull-right kb-disabled'}, 'Disabled')
    else
      disabled = ''

    lastExecutedJob = @props.orchestration.get 'lastExecutedJob'
    if lastExecutedJob?.get('startTime')
      duration = (DurationWithIcon {startTime: lastExecutedJob.get('startTime'), endTime: lastExecutedJob.get('endTime')})
    else
      duration = ''

    (Link {className: "list-group-item #{className}", to: 'orchestration', params: {orchestrationId: @props.orchestration.get('id')} },
      (span {className: 'table'},
        (span {className: 'tr'},
          (span {className: 'td kbc-td-status'},
            (JobStatusCircle {status: lastExecutedJob?.get('status')})
          ),
          (span {className: 'td'},
            (em null, disabled),
            (strong null, @props.orchestration.get('name')),
            (span null, duration),
            (span {className: 'kb-info clearfix pull-right'},
              (FinishedWithIcon endTime: lastExecutedJob.get('endTime')) if lastExecutedJob?.get('endTime')
            )
          )
        )
      )
    )
)

getStateFromStores = ->
  orchestrations: OrchestrationStore.getFiltered()

OrchestrationsNav = React.createClass(
  displayName: 'OrchestrationsNavList'
  mixins: [createStoreMixin(OrchestrationStore)]

  getStateFromStores: ->
    orchestrations: OrchestrationStore.getFiltered()

  render: ->
    filtered = @state.orchestrations
    if filtered.size
      childs = filtered.map((orchestration) ->
        OrchestrationRow {orchestration: orchestration, key: orchestration.get('id')}
      , @).toArray()
    else
      childs = (div className: 'list-group-item',
        'No Orchestrations found'
      )

    (div className: 'list-group kb-orchestrations-nav',
      childs
    )
)

module.exports = OrchestrationsNav