Core = require 'sublime-core'
autobahn = require 'autobahn'
When = require 'when'
_ = require 'lodash'

states =
  disconnected:
    connect: (inst, dfr) ->
      inst.connection.onopen = (session, details) =>
        inst.session = session
        @setMachineState @connected
        dfr.resolve inst
        return

      inst.connection.open()
      return

  connected:
    disconnect: (inst, dfr) ->
      inst.connection.onclose = (reason, details) =>
        inst.session = null
        @setMachineState @disconnected
        dfr.resolve inst
        return

      inst.connection.close()
      return

    subscribe: (inst, ch, fn, dfr) ->
      inst.session.subscribe(ch, fn)
      .then (subscription) ->
        sb =
          subscription: subscription
          fn: fn

        inst.channels[ch] = inst.channels[ch] or []
        inst.channels[ch].push sb
        dfr.resolve inst
        return
      , (error) ->
        dfr.reject error
        return
      return

    unsubscribe: (inst, ch, fn, dfr) ->
      if !inst.channels[ch] then return

      targets = inst.channels[ch].filter (sb) ->
        sb.fn == fn
      .map (sb) -> inst.session.unsubscribe sb.subscription

      When.all targets
      .then () ->
        inst.channels[ch] = inst.channels[ch].filter (sb) -> sb.fn != fn
        if inst.channels[ch].length == 0 then inst.channels[ch] = null

        dfr.resolve inst
        return
      , (error) ->
        dfr.reject error
        return
      return

    publish: (inst, ch, payload, cfg, dfr) ->
      cfg = _.extend({ acknowledge: true, exclude_me: true }, cfg)

      if !Array.isArray payload
        payload = [payload]

      inst.session.publish ch, payload, {}, cfg
      .then () ->
        dfr.resolve inst
        return
      , (error) ->
        dfr.reject error
        return
      return

    register: (inst, ch, fn, cfg, dfr) ->
      inst.session.register ch, fn, cfg
      .then () ->
        dfr.resolve inst
        return
      , (error) ->
        dfr.reject error
        return
      return

    unregister: (inst, ch, dfr) ->
      targets = inst.session.registrations.filter (reg) ->
        reg.procedure == ch
      .map (reg) -> inst.session.unregister reg

      When.all targets
      .then () ->
        dfr.resolve inst
        return
      , (error) ->
        dfr.reject error
        return
      return

    call: (inst, ch, args, cfg, dfr) ->
      if !Array.isArray args
        args = [args]

      inst.session.call ch, args, {}, cfg
      .then (result) ->
        dfr.resolve result
        return
      , (error) ->
        dfr.reject error
        return
      return

# Provides WAMP functionality
class Broker extends Core.Stateful
  # Construct a new Broker
  #
  # @param [String] uri The URI to connect to
  # @param [String] realm The WAMP realm
  constructor: (uri, realm) ->
    super(states)

    @channels = {}
    @uri = uri
    @realm = realm

    @connection = new autobahn.Connection
      url: uri
      realm: realm

  # Connect to the server
  connect: () ->
    dfr = When.defer()
    @apply 'connect', @, dfr
    dfr.promise

  # Disconnect from the server
  disconnect: () ->
    dfr = When.defer()
    @apply 'disconnect', @, dfr
    dfr.promise

  # Subscribe to a channel
  #
  # @param [String] channel The name of the channel
  # @param [Function] fn The function to handle inbound messages
  subscribe: (channel, fn) ->
    dfr = When.defer()
    @apply 'subscribe', @, channel, fn, dfr
    dfr.promise

  # Unsubscribe from a channel
  #
  # @param [String] channel The name of the channel
  # @param [Function] fn The specific handler to unsubscribe
  unsubscribe: (channel, fn) ->
    dfr = When.defer()
    @apply 'unsubscribe', @, channel, fn, dfr
    dfr.promise

  # Publish a message to a channel
  #
  # @param [String] channel The name of the channel
  # @param [Object] payload The message payload
  # @param [Object] cfg Message specific configuration
  publish: (channel, payload, cfg) ->
    dfr = When.defer()
    @apply 'publish', @, channel, payload, cfg, dfr
    dfr.promise

  # Register a function on the channel for RMI
  #
  # @param [String] channel The name of the channel
  # @param [Function] fn The function to expose
  # @param [Object] cfg Function specific configuration
  register: (channel, fn, cfg) ->
    dfr = When.defer()
    @apply 'register', @, channel, fn, cfg, dfr
    dfr.promise

  # Unregister the RMI function
  #
  # @param [String] channel The name of the channel
  unregister: (channel) ->
    dfr = When.defer()
    @apply 'unregister', @, channel, dfr
    dfr.promise

  # Invoke a RMI function
  #
  # @param [String] channel The name of the channel
  # @param [Object] args the arguments to invoke the function
  # @param [Object] cfg Invocation specific configuration
  call: (channel, args, cfg) ->
    dfr = When.defer()
    @apply 'call', @, channel, args, cfg, dfr
    dfr.promise

module.exports = Broker
