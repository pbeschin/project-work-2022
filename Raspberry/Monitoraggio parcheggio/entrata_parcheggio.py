import paho.mqtt.client as mqtt
import RPi.GPIO as GPIO
import time

MQTT_SERVER = "test.mosquitto.org"
MQTT_PORT = 1883
MQTT_TIMEOUT = 60

TOPIC_ROOT = "pw2k22"
TOPIC_VERSION = "1.1"

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe(f"{TOPIC_ROOT}/+/#")

def on_bar_entry(client, userdata, msg):
    print("opening bar entry")
    open_entry_bar()
    time.sleep(5)
    close_entry_bar()

def on_bar_exit(client, userdata, msg):
    print("opening bar exit")
    open_exit_bar()
    time.sleep(5)
    close_exit_bar()

def on_message(client, userdata, msg):
    matched = 0
    try:
        [root, version, endpoint, *more] = str(msg.topic).split("/")
        if version != TOPIC_VERSION:
            raise Exception(f"Wrong version [{msg.topic}]")
        if endpoint == "barraentrata":
            on_bar_entry(client, userdata, msg)
            matched = 1
        if endpoint == "barrauscita":
            on_bar_exit(client, userdata, msg)
            matched = 1
        
        if matched == 0:
            print(f"on_message[{msg.topic}]: 'endpoint didn't match any value'")
    except Exception as e:
        print(e)
    finally:
        pass

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(MQTT_SERVER, MQTT_PORT, MQTT_TIMEOUT)


rotation = 90

steps = int(512 * 90 / 360)

GPIO.setmode(GPIO.BOARD)
control_pins = [21,22,23,24]
control2_pins = [35,36,37,3]

for pin in control_pins:
  GPIO.setup(pin, GPIO.OUT)
  GPIO.output(pin, 0)
halfstep_seq = [
  [1,0,0,0],
  [1,1,0,0],
  [0,1,0,0],
  [0,1,1,0],
  [0,0,1,0],
  [0,0,1,1],
  [0,0,0,1],
  [1,0,0,1]
]

halfstep_seq_rev = halfstep_seq[::-1]

for pin in control2_pins:
  GPIO.setup(pin, GPIO.OUT)
  GPIO.output(pin, 0)


def open_entry_bar():
  for i in range(steps):
    for halfstep in range(8):
      for pin in range(4):
        GPIO.output(control_pins[pin], halfstep_seq[halfstep][pin])
      time.sleep(0.001)

def close_entry_bar():
  for i in range(steps):
    for halfstep in range(8):
      for pin in range(4):
        GPIO.output(control_pins[pin], halfstep_seq_rev[halfstep][pin])
      time.sleep(0.001)

def open_exit_bar():
  for i in range(steps):
    for halfstep in range(8):
      for pin in range(4):
        GPIO.output(control2_pins[pin], halfstep_seq[halfstep][pin])
      time.sleep(0.001)

def close_exit_bar():
  for i in range(steps):
    for halfstep in range(8):
      for pin in range(4):
        GPIO.output(control2_pins[pin], halfstep_seq_rev[halfstep][pin])
      time.sleep(0.001)

try:
    client.loop_forever()
except:
    GPIO.cleanup()