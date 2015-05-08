lib = require '../'

describe 'Broker test suite', ()  ->
  create = () -> new lib.Broker 'ws://27.0.0.1:8080/ws', 'realm1'

  it 'should construct an instance', () ->
    instance = create()
    expect instance
      .not.toBeNull()

  it 'should be able to connect and disconnect', (done) ->
    instance = create()
    expect instance
      .not.toBeNull()

    instance.on 'connected', () ->
      expect instance.state()
        .toBe 'connected'

      instance.disconnect()
      done()

    instance.connect()

  describe 'Broker functionality test suite', ()  ->

    instance = null
    subscription = () -> return

    beforeEach () ->
      instance = create()

    afterEach () ->
      instance = null

    it 'should be able to subscribe', (done) ->
      instance.on 'connected', () ->
        instance.subscribe 'test', subscription
        .then () ->
          expect instance.channels.test
            .not.toBeNull()

          instance.disconnect()

      instance.on 'disconnected', () ->
        done()

      instance.connect()

    it 'should be able to unsubscribe', (done) ->
      instance.on 'connected', () ->
        instance.subscribe 'test', subscription
        .then () ->
          expect instance.channels.test
            .not.toBeNull()

          instance.unsubscribe 'test', subscription
          .then () ->
            expect instance.channels.test
              .toBeNull()

            instance.disconnect()

      instance.on 'disconnected', () ->
        done()

      instance.connect()

    it 'should be able to publish', (done) ->
      sb = (res) ->
        instance.disconnect()

      instance.on 'connected', () ->
        instance.subscribe 'com.example.test', sb
        .then () ->
          expect instance.channels['com.example.test']
            .not.toBeNull()

          instance.publish 'com.example.test',
            { hello: 'world' },
            { exclude_me: false }

          return

      instance.on 'disconnected', () ->
        done()

      instance.connect()

    it 'should be able to register', (done) ->
      key = 'com.example.register'
      fn = (a, b) -> a + b

      instance.on 'connected', () ->
        instance.register key, fn
        .then () ->
          expect instance.session.registrations.length
            .toBe 1

          instance.disconnect()

      instance.on 'disconnected', () ->
        done()

      instance.connect()

    it 'should be able to unregister', (done) ->
      key = 'com.example.unregister'
      fn = (a, b) -> a + b

      instance.on 'connected', () ->
        instance.register key, fn
        .then () ->
          expect instance.session.registrations.length
            .toBe 1

          instance.unregister key
          .then () ->
            expect instance.session.registrations.length
              .toBe 0

            instance.disconnect()

      instance.on 'disconnected', () ->
        done()

      instance.connect()

    it 'should be able to call', (done) ->
      key = 'com.example.call'
      fn = (args) -> args[0] + args[1]

      instance.on 'connected', () ->
        instance.register key, fn
        .then () ->
          expect instance.session.registrations.length
            .toBe 1

          instance.call key, [10, 20]
          .then (res) ->
            expect res
              .toBe 30

            instance.unregister key
            .then () ->
              expect instance.session.registrations.length
                .toBe 0

              instance.disconnect()

      instance.on 'disconnected', () ->
        done()

      instance.connect()
