React = require('react')
Link = React.createFactory(require('react-router').Link)
Immutable = require('immutable')

createStoreMixin = require '../../../../react/mixins/createStoreMixin'
ComponentsStore = require('../../../components/stores/ComponentsStore')
MySqlSandboxCredentialsStore = require('../../../provisioning/stores/MySqlSandboxCredentialsStore')
CredentialsActionCreators = require('../../../provisioning/ActionCreators')
MySqlCredentials = React.createFactory(require('../../../provisioning/react/components/MySqlCredentials'))
ConfigureSandbox = React.createFactory(require '../components/ConfigureSandbox')
ConnectToMySqlSandbox = React.createFactory(require '../components/ConnectToMySqlSandbox')
RunComponentButton = React.createFactory(require '../../../components/react/components/RunComponentButton')
DeleteButton = React.createFactory(require '../../../../react/common/DeleteButton')
Loader = React.createFactory(require('kbc-react-components').Loader)
StorageBucketsStore = require '../../../components/stores/StorageBucketsStore'
StorageTablesStore = require '../../../components/stores/StorageTablesStore'


{div, span, input, strong, form, button, h3, h4, i, button, small, ul, li, a} = React.DOM
MySqlSandbox = React.createClass

  mixins: [createStoreMixin(MySqlSandboxCredentialsStore, StorageTablesStore, StorageBucketsStore)]

  displayName: 'MySqlSandbox'

  getStateFromStores: ->
    credentials: MySqlSandboxCredentialsStore.getCredentials()
    pendingActions: MySqlSandboxCredentialsStore.getPendingActions()
    isLoading: MySqlSandboxCredentialsStore.getIsLoading()
    isLoaded: MySqlSandboxCredentialsStore.getIsLoaded()
    tables: StorageTablesStore.getAll()
    buckets: StorageBucketsStore.getAll()

  _renderCredentials: ->
    span {},
      MySqlCredentials {credentials: @state.credentials, isCreating: @state.pendingActions.get("create")}

  _renderControlButtons: ->
    if @state.credentials.get "id"
      sandboxConfiguration = {}
      div {},
        div {},
          RunComponentButton(
            title: "Load Tables into MySQL sandbox"
            component: 'transformation'
            method: 'create-sandbox'
            mode: 'button'
            label: "Load data"
            runParams: ->
              sandboxConfiguration
          ,
            ConfigureSandbox
              backend: 'mysql'
              tables: @state.tables
              buckets: @state.buckets
              onChange: (params) ->
                sandboxConfiguration = params
          )
        div {},
          ConnectToMySqlSandbox {credentials: @state.credentials},
            button {className: "btn btn-link", title: 'Connect To Sandbox', type: 'submit'},
              span {className: 'fa fa-fw fa-database'}
              " Connect"
        div {},
          DeleteButton
            label: 'Drop credentials'
            tooltip: 'Delete MySQL Sandbox'
            isPending: @state.pendingActions.get 'drop'
            fixedWidth: true
            confirm:
              title: 'Delete MySQL Sandbox'
              text: 'Do you really want to delete MySQL sandbox?'
              onConfirm: @_dropCredentials
    else
      if !@state.pendingActions.get("create")
        button {className: 'btn btn-link', onClick: @_createCredentials},
          i className: 'fa fa-fw fa-plus'
          ' Create credentials'


  render: ->
    div {className: 'row'},
      h4 {}, 'MySQL'
      div {className: 'col-md-9'},
        @_renderCredentials()
      div {className: 'col-md-3'},
         @_renderControlButtons()


  _createCredentials: ->
    CredentialsActionCreators.createMySqlSandboxCredentials()

  _dropCredentials: ->
    CredentialsActionCreators.dropMySqlSandboxCredentials()

module.exports = MySqlSandbox
