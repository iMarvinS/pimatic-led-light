# #led-light-plugin configuration options
module.exports = {
  title: "Led light device config schemas"
  IwyMaster: {
    title: "IwyMaster LedLight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
  },
  Milight: {
    title: "Milight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
      zone:
        description: "Zone [0 - 4], 0 = switches all zones"
        type: "number"
  },
  MilightRF24: {
    title: "Milight"
    type: "object"
    properties:
      zones:
        description: "The switch protocols to use."
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            addr:
              description: "Address of light device"
              type: "string"
            port:
              description: "USB port where the gateway is attached"
              type: "string"
            zone:
              description: "Zone [0 - 4], 0 = switches all zones"
              type: "number"
            send:
              description: "Send commands using this address and zone"
              type: "boolean"
              default: true
            receive:
              description: "Respond on received commands using this address and zone"
              type: "boolean"
              default: true
  },
  Wifi370: {
    title: "LedLight"
    type: "object"
    properties:
      addr:
        description: "IP-Address of light device"
        type: "string"
  },
  Blinkstick: {
    title: "BlinkStick"
    type: "object"
    properties:
      serial:
        description: "serial of Blinkstick"
        type: "string"
        default: ""
  },
  DummyLedLight: {
    title: "DummyLedLight"
    type: "object"
    properties: {}
  },
  HyperionLedLight: {
    title: "Hyperion",
    type: "object"
    properties:
      addr:
        description: "IP-Address of hyperion device"
        type: "string"
        default: "localhost"
      port:
        description: "Port of hyperion device"
        type: "string",
        default: "19444"
  },
  MQTTLedLight: {
    title: "MQTT Light",
    type: "object"
    properties:
      brokerId:
        description: "Broker Id of pimatic-mqtt configuration"
        type: "string"
        default: "default"
      onoffTopic:
        description: "Topic used for sending on/off message"
        type: "string"
        required: true
      colorTopic:
        description: "Topic used for sending RGB values in form '255,255,255' "
        type: "string"
        required: true
      onoffStateTopic:
        description: "Topic for receiving on/off messages"
        type: "string"
        default: null
        required: false
      colorStateTopic:
        description: "Topic used for receiving RGB values in form '255,255,255' "
        type: "string"
        default: null
        required: false
      onMessage:
        description: "Payload for sending 'on' command"
        type: "string"
        default: "ON"
      offMessage:
        description: "Payload for sending 'off' command"
        type: "string"
        default: "OFF"
      qos:
        description: "MQTT publish QOS for color and on/off payloads on state and set topics"
        type: "number"
        default: 0
      retain:
        description: "MQTT retain option for color and on/off payloads on the state topics"
        type: "boolean"
        default: false
  }
}
