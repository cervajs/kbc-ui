###
  Delete button with confirm and loading state
###

React = require 'react'
classnames = require 'classnames'

Tooltip = React.createFactory(require('react-bootstrap').Tooltip)
Loader = React.createFactory(require('kbc-react-components').Loader)
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
    isEnabled: React.PropTypes.bool
    label: React.PropTypes.string
    fixedWidth: React.PropTypes.bool

  getDefaultProps: ->
    tooltip: 'Delete'
    isPending: false
    isEnabled: true
    label: ''
    fixedWidth: false

  render: ->
    if @props.isPending
      React.DOM.span className: 'btn btn-link',
        Loader()
    else if !@props.isEnabled
      React.DOM.span className: 'btn btn-link disabled',
        React.DOM.em className: 'kbc-icon-cup'
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
            i className: classnames('fa kbc-icon-cup', 'fa-fw': @props.fixedWidth)
            if @props.label then ' ' + @props.label

