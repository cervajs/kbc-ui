React = require 'react'
ImmutableRenderMixin = require '../../../../../react/mixins/ImmutableRendererMixin'
_ = require('underscore')
Immutable = require('immutable')
Input = React.createFactory require('react-bootstrap').Input
Select = React.createFactory(require('react-select'))
AutosuggestWrapper = require '../../../../transformations/react/components/mapping/AutoSuggestWrapper.jsx'

createGetSuggestions = (getOptions) ->
  (input, callback) ->
    suggestions = getOptions()
    .filter (value) -> value.toLowerCase().search(input.toLowerCase()) >= 0
    .sortBy( (item) ->
      item
    )
    .slice 0, 10
    .toList()
    callback(null, suggestions.toJS())

module.exports = React.createClass
  displayName: 'TableOutputMappingEditor'
  mixins: [ImmutableRenderMixin]

  propTypes:
    value: React.PropTypes.object.isRequired
    tables: React.PropTypes.object.isRequired
    buckets: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired
    disabled: React.PropTypes.bool.isRequired
    backend: React.PropTypes.string.isRequired

  getInitialState: ->
    showDetails: false

  _handleToggleShowDetails: (e) ->
    @setState(
      showDetails: e.target.checked
    )

  _handleChangeSource: (e) ->
    immutable = @props.value.withMutations (mapping) ->
      mapping = mapping.set("source", e.target.value)
    @props.onChange(immutable)

  _handleChangeDestination: (newValue) ->
    value = @props.value.set("destination", newValue)
    @props.onChange(value)

  _handleChangeIncremental: (e) ->
    value = @props.value.set("incremental", e.target.checked)
    @props.onChange(value)

  _handleChangePrimaryKey: (e) ->
    parsedValues = _.filter(_.invoke(e.target.value.split(","), "trim"), (value) ->
      value != ''
    )
    value = @props.value.set("primary_key", Immutable.fromJS(parsedValues))
    @props.onChange(value)

  _handleChangeDeleteWhereColumn: (newValue) ->
    value = @props.value.set("delete_where_column", newValue)
    value = value.set("delete_where_operator", value.get("delete_where_operator", 'eq'))
    @props.onChange(value)

  _handleChangeDeleteWhereOperator: (e) ->
    value = @props.value.set("delete_where_operator", e.target.value)
    @props.onChange(value)

  _handleChangeDeleteWhereValues: (e) ->
    parsedValues = _.filter(_.invoke(e.target.value.split(","), "trim"), (value) ->
      value != ''
    )
    if parsedValues.length == 0
      value = @props.value.set("delete_where_values", Immutable.List())
    else
      value = @props.value.set("delete_where_values", Immutable.fromJS(parsedValues))
    @props.onChange(value)

  _getPrimaryKeyValue: ->
    @props.value.get("primary_key", Immutable.List()).join(",")

  _getDeleteWhereValues: ->
    @props.value.get("delete_where_values", Immutable.List()).join(",")

  _getTablesAndBuckets: ->
    tablesAndBuckets = @props.tables.merge(@props.buckets)

    inOut = tablesAndBuckets.filter((item) ->
      item.get("id").substr(0, 3) == "in." || item.get("id").substr(0, 4) == "out."
    )

    map = inOut.sortBy((item) ->
      item.get("id")
    ).map((item) ->
      item.get("id")
    )

    map.toList()

  _getColumns: ->
    if !@props.value.get("destination")
      return Immutable.List()
    props = @props
    table = @props.tables.find((table) ->
      table.get("id") == props.value.get("destination")
    )
    if !table
      return Immutable.List()
    table.get("columns")

  render: ->
    component = @
    React.DOM.div {className: 'form-horizontal clearfix'},
      React.DOM.div null,
        React.DOM.div {className: "row col-md-12"},
          React.DOM.div className: 'form-group form-group-sm',
            React.DOM.div className: 'col-xs-10 col-xs-offset-2',
              Input
                standalone: true
                type: 'checkbox'
                label: React.DOM.small {}, 'Show details'
                checked: @state.showDetails
                onChange: @_handleToggleShowDetails
        React.DOM.div {className: "row col-md-12"},
          Input
            type: 'text'
            name: 'source'
            label: 'File'
            value: @props.value.get("source")
            disabled: @props.disabled
            placeholder: "File name"
            onChange: @_handleChangeSource
            labelClassName: 'col-xs-2'
            wrapperClassName: 'col-xs-10'
            help: React.DOM.span {},
              "File will be uploaded from"
              React.DOM.code {}, "/data/out/tables"
        React.DOM.div {className: "row col-md-12"},
          React.DOM.div className: 'form-group',
            React.DOM.label className: 'col-xs-2 control-label', 'Destination'
            React.DOM.div className: 'col-xs-10',
              React.createElement AutosuggestWrapper,
                suggestions: createGetSuggestions(@_getTablesAndBuckets)
                value: @props.value.get("destination", "")
                onChange: @_handleChangeDestination
                id: 'output-destination'
                name: 'output-destination'
                placeholder: 'Destination table in Storage'
              if @state.showDetails
                Input
                  standalone: true
                  name: 'incremental'
                  type: 'checkbox'
                  label: React.DOM.small {}, 'Incremental'
                  checked: @props.value.get("incremental")
                  disabled: @props.disabled
                  onChange: @_handleChangeIncremental
                  help: React.DOM.small {},
                    "If the destination table exists in Storage API,
                    output mapping does not overwrite the table, it only appends the data to it.
                    Uses incremental write to Storage API."
        if @state.showDetails
          React.DOM.div {className: "row col-md-12"},
            Input
              bsSize: 'small'
              name: 'primaryKey'
              type: 'text'
              label: 'Primary key'
              value: @_getPrimaryKeyValue()
              disabled: @props.disabled
              placeholder: "Column name(s)"
              onChange: @_handleChangePrimaryKey
              labelClassName: 'col-xs-2'
              wrapperClassName: 'col-xs-10'
              help: React.DOM.small {},
                "Primary key of the table in Storage API. If the table already exists, primary key must match.
                Parts of a composite primary key are separated with a comma."
        if @state.showDetails
          React.DOM.div {className: "row col-md-12"},
            React.DOM.div className: 'form-group form-group-sm',
              React.DOM.label className: 'col-xs-2 control-label', 'Delete rows'
              React.DOM.div className: 'col-xs-4',
                React.createElement AutosuggestWrapper,
                  suggestions: createGetSuggestions(@_getColumns)
                  placeholder: 'Select column'
                  value: @props.value.get("delete_where_column", "")
                  onChange: @_handleChangeDeleteWhereColumn
                  id: 'output-delete-rows'
                  name: 'output-delete-rows'
              React.DOM.div className: 'col-xs-2',
                Input
                  bsSize: 'small'
                  type: 'select'
                  name: 'deleteWhereOperator'
                  value: @props.value.get("delete_where_operator")
                  disabled: @props.disabled
                  onChange: @_handleChangeDeleteWhereOperator
                ,
                  React.DOM.option {value: "eq"}, "= (IN)"
                  React.DOM.option {value: "ne"}, "!= (NOT IN)"
              React.DOM.div className: 'col-xs-4',
                Input
                  bsSize: 'small'
                  type: 'text'
                  name: 'deleteWhereValues'
                  value: @_getDeleteWhereValues()
                  disabled: @props.disabled
                  onChange: @_handleChangeDeleteWhereValues
                  placeholder: "Comma separated values"
