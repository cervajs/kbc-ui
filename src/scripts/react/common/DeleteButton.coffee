###
  Delete button with confirm and loading state
###

React = require 'react'

Tooltip = React.createFactory(require('react-bootstrap').Tooltip)
Loader = React.createFactory(require './Loader')
OverlayTrigger = React.createFactory(require('react-bootstrap').OverlayTrigger)
Confirm = React.createFactory(require './Confirm')

assign = require 'object-assign'

{button, span, i} = React.DOM

module.exports = React.createClass
  displayName: 'DeleteButton'
  propTypes:
    tooltip: React.PropTypes.string
    confirm: React.PropTypes.object # Confirm props
    isPending: React.PropTypes.bool

  getDefaultProps: ->
    tooltip: 'Delete'
    isPending: false

  render: ->
    if @props.isPending
      React.DOM.span className: 'btn btn-link',
        React.createElement Loader
    else
      OverlayTrigger
        overlay: Tooltip null, @props.tooltip
        key: 'delete'
        placement: 'top'
      ,
        Confirm assign({}, @props.confirm,
          buttonLabel: 'Delete'
        ),
          button className: 'btn btn-link',
            i className: 'kbc-icon-cup'