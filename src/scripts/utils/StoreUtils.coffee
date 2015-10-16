EventEmitter = require('events').EventEmitter
assign = require 'object-assign'

CHANGE_EVENT = 'change'

StoreUtils =

  ###
    Creates new store
  ###
  createStore: (spec) ->

    store = assign {}, EventEmitter.prototype, spec,
      emitChange: ->
        @emit(CHANGE_EVENT)

      addChangeListener: (callback) ->
        @on(CHANGE_EVENT, callback)

      removeChangeListener: (callback) ->
        @removeListener(CHANGE_EVENT, callback)

    store.setMaxListeners(0)
    store




module.exports = StoreUtils
