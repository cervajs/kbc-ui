React = require 'react'


JobStatusCircle = React.createFactory(require '../../../../../react/common/JobStatusCircle.coffee')
FinishedWithIcon = React.createFactory(require '../../../../../react/common/FinishedWithIcon.coffee')
DurationWithIcon = React.createFactory(require '../../../../../react/common/DurationWithIcon.coffee')
ImmutableRendererMixin = require '../../../../../react/mixins/ImmutableRendererMixin.coffee'

Link = React.createFactory(require('react-router').Link)

{div, span, a, em, strong} = React.DOM

JobNavRow = React.createClass
  displayName: 'JobsNavRow'
  mixins: [ImmutableRendererMixin]
  propTypes:
    job: React.PropTypes.object.isRequired
    isActive: React.PropTypes.bool.isRequired

  render: ->
    className = if  @props.isActive then 'active' else ''

    Link {className: "list-group-item #{className}", to: 'orchestrationJob', params: {orchestrationId: @props.job.get('orchestrationId'), jobId: @props.job.get('id')}},
       span className: 'table',
        span className: 'tr',
          span className: 'td kbc-td-status',
            JobStatusCircle status: @props.job.get('status')
          span className: 'td',
            (em({title: @props.job.getIn(['initiatorToken', 'description'])}, 'manually') if @props.job.get('initializedBy') == 'manually')
            strong null,
              @props.job.get('id')
            span null,
              DurationWithIcon startTime: @props.job.get('startTime'), endTime: @props.job.get('endTime') if @props.job.get('startTime')
            span className: 'kb-info clearfix pull-right',
              FinishedWithIcon endTime: @props.job.get('endTime')


module.exports = JobNavRow