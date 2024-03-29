React = require 'react'
{List} = require 'immutable'
createStoreMixin = require '../../../../../react/mixins/createStoreMixin'
RoutesStore = require '../../../../../stores/RoutesStore'
ComponentDescription = require '../../../../components/react/components/ComponentDescription'
ComponentMetadata = require '../../../../components/react/components/ComponentMetadata'

{Panel, PanelGroup, Alert, DropdownButton} = require('react-bootstrap')

SearchRow = require '../../../../../react/common/SearchRow'
TablesList = require './BucketTablesList'
ActiveCountBadge = require './ActiveCountBadge'
{Link} = require('react-router')
{Tooltip, Confirm} = require '../../../../../react/common/common'
{Loader} = require 'kbc-react-components'

goodDataWriterStore = require '../../../store'
actionCreators = require '../../../actionCreators'

{strong, br, ul, li, div, span, i, a, button, p} = React.DOM

module.exports = React.createClass
  displayName: 'GooddDataWriterIndex'
  mixins: [createStoreMixin(goodDataWriterStore)]

  getStateFromStores: ->
    config =  RoutesStore.getCurrentRouteParam('config')
    configId: config
    writer: goodDataWriterStore.getWriter(config)
    tablesByBucket: goodDataWriterStore.getWriterTablesByBucketFiltered(config)
    filter: goodDataWriterStore.getWriterTablesFilter(config)

  _handleFilterChange: (query) ->
    actionCreators.setWriterTablesFilter(@state.writer.getIn(['config', 'id']), query)

  render: ->
    writer = @state.writer.get 'config'
    div className: 'container-fluid',
      div className: 'col-md-9 kbc-main-content',
        div className: 'row',
          div className: 'col-sm-8',
            React.createElement ComponentDescription,
              componentId: 'gooddata-writer'
              configId: writer.get 'id'
        if writer.get('info')
          div className: 'row',
            React.createElement Alert,
              bsStyle: 'warning'
            ,
              writer.get('info')
        React.createElement SearchRow,
          className: 'row kbc-search-row'
          onChange: @_handleFilterChange
          query: @state.filter
        if @state.tablesByBucket.count()
          div
            className: 'kbc-accordion kbc-panel-heading-with-table kbc-panel-heading-with-table'
          ,
            @state.tablesByBucket.map (tables, bucketId) ->
              @_renderBucketPanel bucketId, tables
            , @
            .toArray()
        else
          @_renderNotFound()

      div className: 'col-md-3 kbc-main-sidebar',
        div className: 'kbc-buttons kbc-text-light',
          React.createElement ComponentMetadata,
            componentId: 'gooddata-writer'
            configId: @state.configId
        ul className: 'nav nav-stacked',
          li null,
            React.createElement Link,
              to: 'gooddata-writer-date-dimensions'
              params:
                config: writer.get 'id'
            ,
              span className: 'fa fa-clock-o fa-fw'
              ' Date Dimensions'
          li null,
            React.createElement Link,
              to: 'jobs'
              query:
                q: '+component:gooddata-writer +params.config:' + writer.get('id')
            ,
              span className: 'fa fa-tasks fa-fw'
              ' Jobs Queue'
          if writer.getIn(['gd', 'pid']) && !writer.get('toDelete')
            li null,
              a
                href: "https://secure.gooddata.com/#s=/gdc/projects/#{writer.getIn(['gd', 'pid'])}|dataPage|"
                target: '_blank'
              ,
                span className: 'fa fa-bar-chart-o fa-fw'
                ' GoodData Project'
          li null,
            React.createElement Confirm,
              text: 'Upload project'
              title: 'Are you sure you want to upload all tables to GoodData project?'
              buttonLabel: 'Upload'
              buttonType: 'success'
              onConfirm: @_handleProjectUpload
            ,
              a null,
                if @state.writer.get('pendingActions', List()).contains 'uploadProject'
                  React.createElement Loader, className: 'fa-fw'
                else
                  span className: 'fa fa-upload fa-fw'
                ' Upload project'
          li null,
            React.createElement Link,
              to: 'gooddata-writer-model'
              params:
                config: @state.writer.getIn ['config', 'id']
            ,
              span className: 'fa fa-sitemap fa-fw'
              ' Model'
          li null,
            React.createElement Confirm,
              title: 'Delete Writer'
              text: "Are you sure you want to delete writer with its GoodData project?"
              buttonLabel: 'Delete'
              onConfirm: @_handleProjectDelete
            ,
              a null,
                if @state.writer.get 'isDeleting'
                  React.createElement Loader, className: 'fa-fw'
                else
                  span className: 'kbc-icon-cup fa-fw'
                ' Delete Writer'
          li null,
            if @state.writer.get 'isOptimizingSLI'
              span null,
                ' '
                React.createElement Loader
            React.createElement DropdownButton,
              title: span null,
                span className: 'fa fa-cog fa-fw'
                ' Advanced'
              navItem: true
            ,
              li null,
                React.createElement Confirm,
                  title: 'Optimize SLI hash'
                  text: div null,
                    p null, 'Optimizing SLI hashes is partially disabled sice this is an advanced
                    process which might damage your GD project.
                    We insist on consluting with us before taking any further step. '
                    p null, 'Please contact us on: support@keboola.com'
                  buttonLabel: 'Optimize'
                  buttonType: 'primary'
                  onConfirm: @_handleOptimizeSLI
                ,
                  a null,
                    'Optimize SLI hash'
              li null,
                React.createElement Confirm,
                  title: 'Reset Project'
                  text: div null,
                    p null,
                      "You are about to create new GoodData project for the writer #{writer.get('id')}. "
                      "The current GoodData project (#{writer.getIn(['gd', 'pid'])}) will be discarded. "
                      "Are you sure you want to reset the project?"
                  buttonLabel: 'Reset'
                  onConfirm: @_handleProjectReset
                ,
                  a null,
                    'Reset Project'

  _handleBucketSelect: (bucketId, e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log 'selected', e.selected
    actionCreators.toggleBucket @state.writer.getIn(['config', 'id']), bucketId

  _handleProjectUpload: ->
    actionCreators.uploadToGoodData(@state.writer.getIn ['config', 'id'])

  _handleProjectDelete: ->
    actionCreators.deleteWriter(@state.writer.getIn ['config', 'id'])

  _handleOptimizeSLI: ->
    actionCreators.optimizeSLIHash(@state.writer.getIn ['config', 'id'])

  _handleProjectReset: ->
    actionCreators.resetProject(@state.writer.getIn ['config', 'id'])

  _renderNotFound: ->
    div {className: 'table table-striped'},
      div {className: 'tfoot'},
        div {className: 'tr'},
          div {className: 'td'}, 'No tables found'


  _renderBucketPanel: (bucketId, tables) ->
    activeCount = tables.filter((table) -> table.getIn(['data', 'export'])).count()
    header = span null,
      span className: 'table',
        span className: 'tbody',
          span className: 'tr',
            span className: 'td',
              bucketId
            span className: 'td text-right',
              React.createElement ActiveCountBadge,
                totalCount: tables.size
                activeCount: activeCount

    React.createElement Panel,
      header: header
      key: bucketId
      eventKey: bucketId
      expanded: !!@state.filter.length || @state.writer.getIn(['bucketToggles', bucketId])
      collapsible: true
      onSelect: @_handleBucketSelect.bind(@, bucketId)
    ,
      React.createElement TablesList,
        configId: @state.writer.getIn ['config', 'id']
        tables: tables
