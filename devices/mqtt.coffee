module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  _ = require 'lodash'
  Color = require 'color'
  BaseLedLight = require('./base')(env)

  class MQTTLedLight extends BaseLedLight

    constructor: (@plugin, @config, lastState) ->
      mqttPlugin = @plugin.framework.pluginManager.getPlugin('mqtt')
      assert(mqttPlugin)
      #assert(mqttPlugin.brokers[@config.brokerId])

      @device = @
      @name = @config.name
      @id = @config.id
      @_dimlevel = lastState?.dimlevel?.value or 0

      @mqttclient = mqttPlugin.brokers[@config.brokerId].client

      if @mqttclient.connected
        @onConnect()

      @mqttclient.on('connect', =>
        @onConnect()
      )

      initState = _.clone lastState
      for key, value of lastState
        initState[key] = value.value

      if @config.onoffStateTopic
        @mqttclient.on('message', (topic, message) =>
          if @config.onoffStateTopic == topic
            switch message.toString()
              when @config.onMessage
                @turnOn()
              when @config.offMessage
                @turnOff()
              else
                env.logger.debug "#{@name} with id:#{@id}: Message is not harmony with onMessage or offMessage in config.json or with default values"
        )

      if @config.colorStateTopic
        @mqttclient.on('message', (topic, message) =>
          if @config.colorStateTopic == topic
            colorString = "rgb(#{message.toString()})"
            setColor(colorString)
        )

      super(initState)
      if @power is true then @turnOn() else @turnOff()

    onConnect: () ->
      if @config.onoffStateTopic
        @mqttclient.subscribe(@config.onoffTopic) #{ qos: @config.qos }

      if @config.colorStateTopic
        @mqttclient.subscribe(@config.colorTopic) #{ qos: @config.qos }

    _updateState: (attr) ->
      state = _.assign @getState(), attr
      super null, state

    turnOn: ->
      @_updateState power: true
      @mqttclient.publish(@config.onoffTopic, @config.onMessage, { qos: @config.qos })
      Promise.resolve()

    turnOff: ->
      @_updateState power: false
      @mqttclient.publish(@config.onoffTopic, @config.offMessage, { qos: @config.qos })
      Promise.resolve()

    setColor: (newColor) ->
      color = Color(newColor).rgb()
      @_updateState
        mode: @COLOR_MODE
        color: color

      message = "#{color.r},#{color.g},#{color.b}"
      @mqttclient.publish(@config.colorTopic, message, { qos: @config.qos })
      Promise.resolve()

    setWhite: ->
      @_updateState mode: @WHITE_MODE

      message = "255,255,255"
      @mqttclient.publish(@config.colorTopic, message, { qos: @config.qos })
      Promise.resolve()

    setBrightness: (newBrightness) ->
      @_updateState brightness: newBrightness

      currentState = @getState()
      message = ""

      if currentState.mode == @WHITE_MODE
        value = 255 * newBrightness / 100
        message = "#{value},#{value},#{value}"
      else
        currentRGBColor = currentState.color
        newR = currentRGBColor.r * newBrightness / 100
        newG = currentRGBColor.g * newBrightness / 100
        newB = currentRGBColor.b * newBrightness / 100
        message = "#{newR},#{newG},#{newB}"

      @mqttclient.publish(@config.colorTopic, message, { qos: @config.qos })

      Promise.resolve()

    destroy: () ->
      if @config.onoffStateTopic
        @mqttclient.unsubscribe(@config.onoffStateTopic)

      if @config.colorStateTopic
        @mqttclient.unsubscribe(@config.colorStateTopic)

      super()

  return MQTTLedLight
