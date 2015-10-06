request = require '../../utils/request'
ApplicationStore = require '../../stores/ApplicationStore'

createUrl = (path) ->
  baseUrl = ApplicationStore.getSapiUrl()
  "#{baseUrl}/v2/storage/#{path}"

createRequest = (method, path) ->
  request(method, createUrl(path))
  .set('X-StorageApi-Token', ApplicationStore.getSapiTokenString())


installedComponentsApi =

  getComponentConfigData: (componentId, configId) ->
    url = "components/#{componentId}/configs/#{configId}"
    createRequest('GET', url)
    .promise()
    .then((response) ->
      response.body?.configuration
    )

  getComponents: ->
    createRequest('GET', 'components')
    .promise()
    .then((response) ->
      response.body
    )

  updateComponentConfiguration: (componentId, configurationId, data) ->
    createRequest 'PUT', "components/#{componentId}/configs/#{configurationId}"
    .type 'form'
    .send data
    .promise()
    .then (response) ->
      response.body


  createConfiguration: (componentId, data) ->
    createRequest 'POST', "components/#{componentId}/configs"
    .type 'form'
    .send data
    .promise()
    .then (response) ->
      response.body

  deleteConfiguration: (componentId, configurationId) ->
    createRequest 'DELETE', "components/#{componentId}/configs/#{configurationId}"
    .promise()
    .then (response) ->
      response.body

  encryptData: (componentUrl, data) ->
    request('POST', componentUrl + "/encrypt")
    .set('X-StorageApi-Token', ApplicationStore.getSapiTokenString())
    .set('Content-Type', 'application/json')
    .send data
    .promise()
    .then (response) ->
      response.body

module.exports = installedComponentsApi
