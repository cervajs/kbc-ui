

dispatcher = require '../Dispatcher'
constants = require '../constants/KbcConstants'
_ = require 'underscore'


module.exports =

  receiveApplicationData: (data) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.APPLICATION_DATA_RECEIVED
      applicationData: data

  ###
    notification -
      text - (required) notification message string or React element
      type - notification type, default is success
      id - notification id, used for duplicate messages filter
      autoDelete - automatically delete message, default to false
  ###
  sendNotification: (notification) ->
    defaults =
      message: ''
      type: 'success'
      autoDelete: false
      id: _.uniqueId('notification')

    if !notification.id?
      delete notification.id

    notification = _.extend defaults, notification

    dispatcher.handleViewAction
      type: constants.ActionTypes.APPLICATION_SEND_NOTIFICATION
      notification: notification

    if notification.autoDelete
      setTimeout @deleteNotification.bind(@, notification.id), 10000

  deleteNotification: (id) ->
    dispatcher.handleViewAction
      type: constants.ActionTypes.APPLICATION_DELETE_NOTIFICATION
      notificationId: id


