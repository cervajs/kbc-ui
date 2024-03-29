RoutesStore = require '../stores/RoutesStore'
ApplicationStore = require '../stores/ApplicationStore'

module.exports =
 addLinksToNodes: (nodes) ->
   router = RoutesStore.getRouter()
   for i of nodes
     if nodes[i].type == 'transformation' or nodes[i].type == 'remote-transformation'
       nodes[i].label = nodes[i].label.substring(nodes[i].label.indexOf("] ") + 2)

     if nodes[i].object.type == 'transformation'
       nodes[i].link = router.makeHref('transformationDetail', {
         bucketId: nodes[i].object.bucket,
         transformationId: nodes[i].object.transformation
       })

     if nodes[i].object.type == 'writer' or nodes[i].object.type == 'dataset'
       nodes[i].link = router.makeHref('gooddata-writer-table', {
         config: nodes[i].object.config,
         table: nodes[i].object.table
       })

     if nodes[i].object.type == 'dateDimension'
       nodes[i].link = router.makeHref('gooddata-writer-date-dimensions', {
         config: nodes[i].object.config
       })

     if nodes[i].object.type == 'storage'
       nodes[i].link = ApplicationStore.getSapiTableUrl(nodes[i].object.table)

   nodes