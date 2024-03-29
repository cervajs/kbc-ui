React = require 'react'
OrchestrationActionCreators = require '../../ActionCreators'

ActivateDeactivateButton = require '../../../../react/common/ActivateDeactivateButton'

{button, span, i} = React.DOM

###
  Enabled/Disabled orchestration button with tooltip
###
module.exports = React.createClass
  displayName: 'OrchestrationActiveButton'
  propTypes:
    orchestration: React.PropTypes.object.isRequired
    isPending: React.PropTypes.bool.isRequired
    tooltipPlacement: React.PropTypes.string

  getDefaultProps: ->
    tooltipPlacement: 'top'

  render: ->
    React.createElement ActivateDeactivateButton,
      activateTooltip: 'Enable Orchestration'
      deactivateTooltip: 'Disable Orchestration'
      isActive: @props.orchestration.get('active')
      isPending: @props.isPending
      onChange: @_handleActiveChange
      tooltipPlacement: @props.tooltipPlacement

  _handleActiveChange: (newValue) ->
    if newValue
      OrchestrationActionCreators.activateOrchestration(@props.orchestration.get('id'))
    else
      OrchestrationActionCreators.disableOrchestration(@props.orchestration.get('id'))

