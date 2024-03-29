React = require 'react'
_ = require('underscore')
Immutable = require('immutable')
{Input} = require('react-bootstrap')
Input = React.createFactory Input
Select = React.createFactory(require('react-select'))
SnowflakeDataTypesContainer = React.createFactory(require("./input/SnowflakeDataTypesContainer"))

module.exports = React.createClass
  displayName: 'InputMappingRowRedshiftEditor'

  propTypes:
    value: React.PropTypes.object.isRequired
    tables: React.PropTypes.object.isRequired
    onChange: React.PropTypes.func.isRequired
    disabled: React.PropTypes.bool.isRequired
    initialShowDetails: React.PropTypes.bool.isRequired

  getInitialState: ->
    showDetails: @props.initialShowDetails

  shouldComponentUpdate: (nextProps, nextState) ->
    should = @props.value != nextProps.value ||
    @props.tables != nextProps.tables ||
    @props.disabled != nextProps.disabled ||
    @state.showDetails != nextState.showDetails

    should

  _handleToggleShowDetails: (e) ->
    @setState(
      showDetails: e.target.checked
    )

  distStyleOptions: [
      label: "EVEN"
      value: "EVEN"
    ,
      label: "KEY"
      value: "KEY"
    ,
      label: "ALL"
      value: "ALL"
  ]

  _handleChangeSource: (value) ->
    immutable = @props.value.withMutations (mapping) ->
      mapping = mapping.set("source", value)
      mapping = mapping.set("destination", value)
      mapping = mapping.set("datatypes", Immutable.Map())
      mapping = mapping.set("whereColumn", "")
      mapping = mapping.set("whereValues", Immutable.List())
      mapping = mapping.set("whereOperator", "eq")
      mapping = mapping.set("columns", Immutable.List())
    @props.onChange(immutable)

  _handleChangeDestination: (e) ->
    value = @props.value.set("destination", e.target.value)
    @props.onChange(value)

  _handleChangeDays: (e) ->
    value = @props.value.set("days", parseInt(e.target.value))
    @props.onChange(value)

  _handleChangeColumns: (string, array) ->
    component = @
    immutable = @props.value.withMutations (mapping) ->
      mapping = mapping.set("columns", Immutable.fromJS(_.pluck(array, "value")))
      if array.length

        columns = mapping.get("columns").toJS()
        if !_.contains(columns, mapping.get("whereColumn"))
          mapping = mapping.set("whereColumn", "")
          mapping = mapping.set("whereValues", Immutable.List())
          mapping = mapping.set("whereOperator", "eq")

        datatypes = _.pick(mapping.get("datatypes").toJS(), columns)
        mapping = mapping.set("datatypes", Immutable.fromJS(datatypes || Immutable.Map()))

    @props.onChange(immutable)

  _handleChangeWhereColumn: (string) ->
    value = @props.value.set("whereColumn", string)
    @props.onChange(value)

  _handleChangeWhereOperator: (e) ->
    value = @props.value.set("whereOperator", e.target.value)
    @props.onChange(value)

  _handleChangeWhereValues: (e) ->
    parsedValues = _.filter(_.invoke(e.target.value.split(","), "trim"), (value) ->
      value != ''
    )
    value = @props.value.set("whereValues", Immutable.fromJS(parsedValues))
    @props.onChange(value)

  _handleChangeDataTypes: (datatypes) ->
    value = @props.value.set("datatypes", datatypes)
    @props.onChange(value)

  _getWhereValues: ->
    @props.value.get("whereValues", Immutable.List()).join(",")

  _getTables: ->
    props = @props
    inOutTables = @props.tables.filter((table) ->
      table.get("id").substr(0, 3) == "in." || table.get("id").substr(0, 4) == "out."
    )
    map = inOutTables.map((table) ->
      {
        label: table.get("id")
        value: table.get("id")
      }
    )
    map.toList().sort( (valA, valB) ->
      return 1 if valA.label > valB.label
      return -1 if valA.label < valB.label
      return 0
    ).toJS()

  _getColumns: ->
    if !@props.value.get("source")
      return []
    props = @props
    table = @props.tables.find((table) ->
      table.get("id") == props.value.get("source")
    )
    if !table
      return false
    table.get("columns").toJS()

  _getColumnsOptions: ->
    columns = @_getColumns()
    map = _.map(
      columns, (column) ->
        {
          label: column
          value: column
        }
    )

  _getFilteredColumnsOptions: ->
    if @props.value.get("columns", Immutable.List()).count()
      columns = @props.value.get("columns").toJS()
    else
      columns = @_getColumns()
    _.map(
      columns, (column) ->
        {
          label: column
          value: column
        }
    )

  render: ->
    component = @
    React.DOM.div {className: 'form-horizontal clearfix'},
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
        React.DOM.div className: 'form-group',
          React.DOM.label className: 'col-xs-2 control-label', 'Source'
          React.DOM.div className: 'col-xs-10',
            Select
              name: 'source'
              value: @props.value.get("source")
              disabled: @props.disabled
              placeholder: "Source table"
              onChange: @_handleChangeSource
              options: @_getTables()
            if @state.showDetails
              Input
                standalone: true
                type: 'checkbox'
                label: React.DOM.small {}, 'Optional'
                value: @props.value.get("optional")
                disabled: @props.disabled
                onChange: @_handleChangeOptional
                help: React.DOM.small {},
                  "If this table does not exist in Storage, the transformation won't show an error."
      React.DOM.div {className: "row col-md-12"},
        Input
          type: 'text'
          label: 'Destination'
          value: @props.value.get("destination")
          disabled: @props.disabled
          placeholder: "Destination table name in transformation DB"
          onChange: @_handleChangeDestination
          labelClassName: 'col-xs-2'
          wrapperClassName: 'col-xs-10'
      if @state.showDetails
        React.DOM.div {className: "row col-md-12"},
          React.DOM.div className: 'form-group form-group-sm',
            React.DOM.label className: 'col-xs-2 control-label', 'Columns'
            React.DOM.div className: 'col-xs-10',
              Select
                multi: true
                name: 'columns'
                value: @props.value.get("columns", Immutable.List()).toJS()
                disabled: @props.disabled || !@props.value.get("source")
                placeholder: "All columns will be imported"
                onChange: @_handleChangeColumns
                options: @_getColumnsOptions()
              React.DOM.div
                className: "help-block"
              ,
                React.DOM.small {}, "Import only specified columns"
      if @state.showDetails
        Input
          bsSize: 'small'
          type: 'number'
          label: 'Days'
          value: @props.value.get("days")
          disabled: @props.disabled
          placeholder: 0
          help: React.DOM.small {},
            "Data updated in the given period"
          onChange: @_handleChangeDays
          labelClassName: 'col-xs-2'
          wrapperClassName: 'col-xs-4'
      if @state.showDetails
        React.DOM.div {className: "row col-md-12"},
          React.DOM.div className: 'form-group form-group-sm',
            React.DOM.label className: 'col-xs-2 control-label', 'Data filter'
            React.DOM.div className: 'col-xs-4',
              Select
                name: 'whereColumn'
                value: @props.value.get("whereColumn")
                disabled: @props.disabled || !@props.value.get("source")
                placeholder: "Select column"
                onChange: @_handleChangeWhereColumn
                options: @_getColumnsOptions()
            React.DOM.div className: 'col-xs-2',
              Input
                bsSize: 'small'
                type: 'select'
                name: 'whereOperator'
                value: @props.value.get("whereOperator")
                disabled: @props.disabled
                onChange: @_handleChangeWhereOperator
              ,
                React.DOM.option {value: "eq"}, "= (IN)"
                React.DOM.option {value: "ne"}, "!= (NOT IN)"
            React.DOM.div className: 'col-xs-4',
              Input
                bsSize: 'small'
                type: 'text'
                name: 'whereValues'
                value: @_getWhereValues()
                disabled: @props.disabled
                onChange: @_handleChangeWhereValues
                placeholder: "Comma separated values"
      if @state.showDetails
        React.DOM.div {className: "row col-md-12"},
          React.DOM.div className: 'form-group form-group-sm',
            React.DOM.label className: 'col-xs-2 control-label', 'Data Types'
            React.DOM.div className: 'col-xs-10',
              SnowflakeDataTypesContainer
                value: @props.value.get("datatypes", Immutable.Map())
                disabled: @props.disabled || !@props.value.get("source")
                onChange: @_handleChangeDataTypes
                columnsOptions: @_getFilteredColumnsOptions()
