
Dispatcher = require('../Dispatcher')
Immutable = require('immutable')
{Map, List} = Immutable
Constants = require '../constants/KbcConstants'
StoreUtils = require '../utils/StoreUtils'

_store = Map
  notifications: List()

hasNotificationWithId = (id) ->
  return false if !id
  found = _store.get('notifications').find (notification) ->
    notification.get('id') == id
  !! found

NotificationsStore = StoreUtils.createStore

  getNotifications: ->
    _store.get 'notifications'

Dispatcher.register (payload) ->
  action = payload.action

  switch action.type
    when Constants.ActionTypes.APPLICATION_SEND_NOTIFICATION

      # avoid duplication of same message
      if !hasNotificationWithId(action.notification.id)
        _store = _store
          .update 'notifications', (notifications) ->
            notifications.unshift Map(action.notification)
        NotificationsStore.emitChange()

    when Constants.ActionTypes.APPLICATION_DELETE_NOTIFICATION
      index = _store.get('notifications').findIndex (notification) ->
        notification.get('id') == action.notificationId

      console.log 'delete', index, action.notificationId
      if index >= 0
        _store = _store.update 'notifications', (notifications) ->
          notifications.delete index
        NotificationsStore.emitChange()

module.exports = NotificationsStore