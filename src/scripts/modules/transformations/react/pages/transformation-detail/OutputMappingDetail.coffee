React = require 'react'
Link = React.createFactory(require('react-router').Link)
ImmutableRenderMixin = require '../../../../../react/mixins/ImmutableRendererMixin'
TableSizeLabel = React.createFactory(require '../../components/TableSizeLabel')
TableBackendLabel = React.createFactory(require '../../components/TableBackendLabel')
TransformationTableTypeLabel = React.createFactory(require '../../components/TransformationTableTypeLabel')
FileSize = React.createFactory(require '../../../../../react/common/FileSize')
Check = React.createFactory(require('kbc-react-components').Check)
{span, div, a, button, i, h4, small, em, ul, li, strong} = React.DOM
numeral = require 'numeral'
ListGroup = React.createFactory(require('react-bootstrap').ListGroup)
ListGroupItem = React.createFactory(require('react-bootstrap').ListGroupItem)
_ = require('underscore')
TableLinkEx = React.createFactory(require '../../../../components/react/components/StorageApiTableLinkEx')

OutputMappingDetail = React.createClass(
  displayName: 'InputMappingDetail'
  mixins: [ImmutableRenderMixin]

  propTypes:
    transformationBackend: React.PropTypes.string.isRequired
    outputMapping: React.PropTypes.object.isRequired
    tables: React.PropTypes.object.isRequired

  _getTableBackend: (tableId) ->
    table = @props.tables.find((table) ->
      table.getIn(["bucket", "id"]) == tableId.substr(0, tableId.lastIndexOf("."))
    )
    if table
      return table.getIn(['bucket', 'backend'])
    else
      return "N/A"

  render: ->
    ListGroupItems = [

      ListGroupItem {key: 'destination'},
        strong {className: "col-md-4"},
          'Destination table'
        span {className: "col-md-6"},
          TableLinkEx
            tableId: @props.outputMapping.get('destination')

      ListGroupItem {key: 'primaryKey'},
        strong {className: "col-md-4"},
          'Primary key'
        span {className: "col-md-6"},
          if @props.outputMapping.get('primaryKey').count()
            @props.outputMapping.get('primaryKey').join(', ')
          else
            'N/A'

      ListGroupItem {key: 'incremental'},
        strong {className: "col-md-4"},
          'Incremental'
        span {className: "col-md-6"},
          Check
            isChecked: @props.outputMapping.get('incremental')

      ListGroupItem {key: 'deleteWhere'},
        strong {className: "col-md-4"},
          'Delete'
        span {className: "col-md-6"},
          if @props.outputMapping.get('deleteWhereColumn')
            span {},
              'Where '
              strong {},
                @props.outputMapping.get('deleteWhereColumn')
              ' '
              @props.outputMapping.get('deleteWhereOperator')
              ' '
              strong {},
                @props.outputMapping.get('deleteWhereValues').join(', ')
          else
            'N/A'
    ]
    ListGroup {}, _.reject(ListGroupItems, (obj) -> obj == undefined)
)

module.exports = OutputMappingDetail
