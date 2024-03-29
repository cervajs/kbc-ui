React = require 'react'
Link = React.createFactory(require('react-router').Link)
ImmutableRenderMixin = require '../../../../../react/mixins/ImmutableRendererMixin'
TableSizeLabel = React.createFactory(require '../../components/TableSizeLabel')
TableBackendLabel = React.createFactory(require '../../components/TableBackendLabel')
TransformationTableTypeLabel = React.createFactory(require '../../components/TransformationTableTypeLabel')
FileSize = React.createFactory(require '../../../../../react/common/FileSize')
Check = React.createFactory(require('kbc-react-components').Check)
ListGroup = React.createFactory(require('react-bootstrap').ListGroup)
ListGroupItem = React.createFactory(require('react-bootstrap').ListGroupItem)
_ = require('underscore')
TableLinkEx = React.createFactory(require '../../../../components/react/components/StorageApiTableLinkEx')

{span, div, a, button, i, h4, small, em, ul, li, strong} = React.DOM
numeral = require 'numeral'

InputMappingDetail = React.createClass(
  displayName: 'InputMappingDetail'
  mixins: [ImmutableRenderMixin]

  propTypes:
    transformationBackend: React.PropTypes.string.isRequired
    inputMapping: React.PropTypes.object.isRequired
    tables: React.PropTypes.object.isRequired

  _isSourceTableInRedshift: ->
    @props.tables.getIn([@props.inputMapping.get('source'), 'bucket', 'backend']) == 'redshift'

  render: ->
    ListGroupItems = [

      ListGroupItem {key: 'source'},
        strong {className: "col-md-4"},
          'Source table'
        span {className: "col-md-6"},
          TableLinkEx
            tableId: @props.inputMapping.get('source')

      if (@props.transformationBackend == 'mysql' || @props.transformationBackend == 'redshift')
        ListGroupItem {key: 'optional'},
          strong {className: "col-md-4"},
            'Optional'
          span {className: "col-md-6"},
            Check
              isChecked: @props.inputMapping.get('optional')

      if @props.transformationBackend == 'redshift' && @_isSourceTableInRedshift()
        ListGroupItem {key: 'type'},
          strong {className: "col-md-4"},
            'Type'
          span {className: "col-md-6"},
            @props.inputMapping.get('type')


      if @props.transformationBackend == 'redshift' and
      (@props.inputMapping.get('type') != 'view' || !@_isSourceTableInRedshift())
        ListGroupItem {key: 'persistent'},
          strong {className: "col-md-4"},
            'Persistent'
          span {className: "col-md-6"},
            Check
              isChecked: @props.inputMapping.get('persistent')

      ListGroupItem {key: 'columns'},
        strong {className: "col-md-4"},
          'Columns'
        span {className: "col-md-6"},
          if @props.inputMapping.get('columns').count()
            @props.inputMapping.get('columns').join(', ')
          else
            'Use all columns'

      ListGroupItem {key: 'whereColumn'},
        strong {className: "col-md-4"},
          'Filters'
        span {className: "col-md-6"},
          if @props.inputMapping.get('whereColumn')
            span {},
              'Where '
              strong {},
                @props.inputMapping.get('whereColumn')
              ' '
              @props.inputMapping.get('whereOperator')
              ' '
              strong {},
                @props.inputMapping.get('whereValues').join(', ')
          if @props.inputMapping.get('days') != 0 && @props.inputMapping.get('whereColumn')
            ' and '
          if @props.inputMapping.get('days') != 0
            span {},
              if @props.inputMapping.get('whereColumn')
                'changed in last '
              else
                'Changed in last '
              @props.inputMapping.get('days')
              ' days'
          if @props.inputMapping.get('days') == 0 && !@props.inputMapping.get('whereColumn')
            'N/A'

      if @props.transformationBackend == 'mysql'
        ListGroupItem {key: 'indexes'},
          strong {className: "col-md-4"},
            'Indexes'
          span {className: "col-md-6"},
            if @props.inputMapping.get('indexes').count()
              @props.inputMapping.get('indexes').map((index, key) ->
                span {key: index},
                  span {className: 'label label-default'},
                    index.toArray().join(', ')
                  ' '
              , @).toArray()
            else
              'N/A'

      if (@props.transformationBackend == 'mysql' || @props.inputMapping.get('type') == 'table')
        ListGroupItem {key: 'datatypes'},
          div className: 'clearfix',
            strong {className: "col-md-4"},
              'Data types'
            span {className: "col-md-6"},
              if @props.inputMapping.get('datatypes').count()
                ul {},
                  @props.inputMapping.get('datatypes').map((definition, column) ->
                    li {key: column},
                      strong {}, column
                      ' '
                      span {}, definition
                  , @).toArray()
              else
                'No data types set'

      if (@props.transformationBackend == 'redshift' && @props.inputMapping.get('type') == 'table')
        ListGroupItem {key: 'sortKey'},
          strong {className: "col-md-4"},
            'Sort key'
          span {className: "col-md-6"},
            if @props.inputMapping.get('sortKey')
              @props.inputMapping.get('sortKey').split(',').join(', ')
            else
              'No sort key set'

      if (@props.transformationBackend == 'redshift' && @props.inputMapping.get('type') == 'table')
        ListGroupItem {key: 'distKey'},
          strong {className: "col-md-4"},
            'Dist key'
          span {className: "col-md-6"},
            if @props.inputMapping.get('distKey')
              @props.inputMapping.get('distKey').split(',').join(', ')
            else
              'No distribution key set'

      if (@props.transformationBackend == 'redshift' && !@_isSourceTableInRedshift())
        ListGroupItem {key: 'copyOptions'},
          strong {className: "col-md-4"},
            'COPY options'
          span {className: "col-md-6"},
            if @props.inputMapping.get('copyOptions')
              @props.inputMapping.get('copyOptions')
            else
              span {className: 'muted'},
                "NULL AS 'NULL', ACCEPTANYDATE, TRUNCATECOLUMNS"

    ]
    ListGroup {className: "clearfix"}, _.reject(ListGroupItems, (obj) -> obj == undefined)
)

module.exports = InputMappingDetail
