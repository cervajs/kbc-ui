React = require 'react'

OrchestrationsActionCreators = require '../actionCreators.coffee'
OrchestrationsStore = require '../stores/OrchestrationsStore.coffee'
RefreshIcon = React.createFactory(require '../../../components/common/RefreshIcon.coffee')

getStateFromStores = ->
  isLoading: OrchestrationsStore.getIsLoading()

OrchestrationsReloaderButton = React.createClass
  displayName: 'OrchestrationsReloaderButton'

  getInitialState: ->
    getStateFromStores()

  componentDidMount: ->
    OrchestrationsStore.addChangeListener(@_onChange)

  componentWillUnmount: ->
    OrchestrationsStore.removeChangeListener(@_onChange)

  _handleRefreshClick: (e) ->
    OrchestrationsActionCreators.loadOrchestrationsForce()

  _onChange: ->
    @setState(getStateFromStores())

  render: ->
    RefreshIcon isLoading: @state.isLoading, onClick: @_handleRefreshClick


module.exports = OrchestrationsReloaderButton