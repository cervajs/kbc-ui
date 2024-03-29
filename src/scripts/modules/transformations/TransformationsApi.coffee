request = require '../../utils/request'

ApplicationStore = require '../../stores/ApplicationStore'
ComponentsStore = require '../components/stores/ComponentsStore'

createUrl = (path) ->
  baseUrl = ComponentsStore.getComponent('transformation').get('uri')
  "#{baseUrl}/#{path}"

createRequest = (method, path) ->
  request(method, createUrl(path))
  .set('X-StorageApi-Token', ApplicationStore.getSapiTokenString())

transformationsApi =

  getTransformationBuckets: ->
    createRequest('GET', 'configs')
    .promise()
    .then((response) ->
      response.body
    )

  createTransformationBucket: (data) ->
    createRequest('POST', 'configs')
    .send(data)
    .promise()
    .then((response) ->
      response.body
    )

  deleteTransformationBucket: (bucketId) ->
    createRequest('DELETE', "configs/#{bucketId}")
    .send()
    .promise()

  getTransformations: (bucketId) ->
    createRequest('GET', "configs/#{bucketId}/items")
    .promise()
    .then((response) ->
      response.body
    )

  deleteTransformation: (bucketId, transformationId) ->
    createRequest('DELETE', "configs/#{bucketId}/items/#{transformationId}")
    .send()
    .promise()

  createTransformation: (bucketId, data) ->
    createRequest('POST', "configs/#{bucketId}/items")
    .send(data)
    .promise()
    .then (response) ->
      response.body

  saveTransformation: (bucketId, transformationId, data) ->
    if data.queriesString
      delete data.queriesString
    createRequest('PUT', "configs/#{bucketId}/items/#{transformationId}")
    .send(data)
    .promise()
    .then (response) ->
      response.body

  updateTransformationProperty: (bucketId, transformationId, propertyName, propertyValue) ->
    createRequest 'PUT', "configs/#{bucketId}/items/#{transformationId}/#{propertyName}"
    .send propertyValue
    .promise()
    .then (response) ->
      response.body

  getGraph: (configuration) ->
    path = "graph?table=#{configuration.tableId}"
    path = path + "&direction=#{configuration.direction}"
    path = path + "&showDisabled=" + (if configuration.showDisabled then '1' else '0')
    path = path + '&limit=' + JSON.stringify(configuration.limit)
    createRequest('GET', path)
    .promise()
    .then((response) ->
      response.body
    )

  getSqlDep: (configuration) ->
    createRequest('POST', 'sqldep')
    .send(configuration)
    .promise()
    .then((response) ->
      response.body
    )

module.exports = transformationsApi
