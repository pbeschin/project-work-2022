import paho.mqtt.client as mqtt

from display_park import *

parkingSpots = {0: [0]*50,
                1: [0]*50,
                2: [0]*50}


def printParkingSpots(level):
    print(f"Printing level {level} parking spots")
    for i in range(5):
        print(i, parkingSpots[level][i*10:(i+1)*10])

# The callback for when the client receives a CONNACK response from the server.


def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("PW2k22/test/+")

# The callback for when a PUBLISH message is received from the server.


def on_message(client, userdata, msg):
    [root, park, espID] = str(msg.topic).split("/")
    [level, parkID] = [int(espID[-3:-2]), int(espID[-2:])]
    print(f"root:{root}/park:{park}/espID:{espID}")
    print(f"level:{level},parkID:{parkID}")
    print(msg.topic+" "+str(msg.payload))

    parkingSpots[level][parkID - 1] = int(msg.payload)

    printParkingSpots(level)


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("test.mosquitto.org", 1883, 60)

def updateDisplay():
    while True:
        displayPark(0, sum(parkingSpots[0]))

displayThread = Thread(target = updateDisplay)

displayThread.start()

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
client.loop_forever()
