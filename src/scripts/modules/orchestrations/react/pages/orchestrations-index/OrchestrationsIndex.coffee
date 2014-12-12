React = require 'react'
Immutable = require 'immutable'

createStoreMixin = require '../../../../../react/mixins/createStoreMixin.coffee'

OrchestrationsActionCreators = require '../../../ActionCreators.coffee'
OrchestrationStore = require '../../../stores/OrchestrationsStore.coffee'

OrchestrationRow = React.createFactory(require './OrchestrationRow.coffee')
SearchRow = React.createFactory(require '../../../../../react/common/SearchRow.coffee')
RefreshIcon = React.createFactory(require '../../../../../react/common/RefreshIcon.coffee')


{div, span, strong} = React.DOM

Index = React.createClass
  displayName: 'OrchestrationsIndex'
  mixins: [createStoreMixin(OrchestrationStore)]

  shouldComponentUpdate: (nextProps, nextState) ->
    !Immutable.is(nextState.orchestrations, @state.orchestrations) ||
      nextState.isLoading != @state.isLoading

  _handleFilterChange: (query) ->
    OrchestrationsActionCreators.setOrchestrationsFilter(query)

  getStateFromStores: ->
    orchestrations: OrchestrationStore.getFiltered()
    isLoading: OrchestrationStore.getIsLoading()
    isLoaded: OrchestrationStore.getIsLoaded()
    filter: OrchestrationStore.getFilter()

  render: ->
    div {className: 'container-fluid'},
      SearchRow(onChange: @_handleFilterChange, query: @state.filter, className: 'row kbc-search-row')
      if @state.orchestrations.count()
        @_renderTable()
      else
        @_renderEmptyState()

  _renderEmptyState: ->
    div null, 'No orchestrations found'

  _renderTable: ->
    childs = @state.orchestrations.map((orchestration) ->
      OrchestrationRow {orchestration: orchestration, key: orchestration.get('id')}
    , @).toArray()

    div className: 'table table-striped table-hover',
      @_renderTableHeader()
      div className: 'tbody',
        childs

  _renderTableHeader: ->
    (div {className: 'thead', key: 'table-header'},
      (div {className: 'tr'},
        (span {className: 'th'},
          (strong null, 'Name')
        ),
        (span {className: 'th'},
          (strong null, 'Last Run')
        ),
        (span {className: 'th'},
          (strong null, 'Duration')
        ),
        (span {className: 'th'},
          (strong null, 'Schedule')
        ),
        (span {className: 'th'})
      )
    )

module.exports = Index