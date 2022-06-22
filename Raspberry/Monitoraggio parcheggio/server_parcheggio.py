import paho.mqtt.client as mqtt
import time
import json
import os
#import pyodbc
import requests

from display_park import *

BASE_API_URL = f"http://192.168.43.181:3000"  # ip di pietro

#local variable for counting parking spaces
parkingSpots = {0: [0]*50,
                1: [0]*50,
                2: [0]*50}

#debug per level
def printParkingSpots(level):
    print(f"Printing level {level} parking spots")
    for i in range(5):
        print(i, parkingSpots[level][i*10:(i+1)*10])

# The callback for when the client receives a CONNACK response from the server.


def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    #"{root:PW2k22}/{version:}1.0/{level:0+}/{parkID:1+}"
    #"pw2k22/1.0/0/1"
    client.subscribe("pw2k22/1.0/#")

# The callback for when a PUBLISH message is received from the server.


def on_message(client, userdata, msg):
    try:
        print(msg.topic+" "+str(msg.payload))
        [root, version, level, parkID, *tail] = str(msg.topic).split("/")
        print(tail)
        print(f"level:{level},parkID:{parkID}")

        if parkingSpots[int(level)][int(parkID) - 1] != int(msg.payload):
            parkingSpots[int(level)][int(parkID) - 1] = int(msg.payload)
            #WriteDB(espID[-3:], int(msg.payload));
        printParkingSpots(int(level))
    except Exception as e:
        print(e)
    finally:
        pass


def CallAPI(parkID, payload):  # body PUT /stato/:idEsp
    putData = {"statoEsp": payload}
    req = requests.put(BASE_API_URL+"/stato/"+parkID,
                       headers={'Content-Type': 'application/json'}, data=json.dumps(putData), timeout=10)
    print(payload)
    # print(putData)
    if req.status_code == 200:
        print("PUT eseguita")
    else:
        print("Errore sulla PUT")


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("test.mosquitto.org", 1883, 60)

alive = 1
def updateDisplay():
    start = time.perf_counter()
    level = 0
    while alive:
        now = time.perf_counter()
        if (now - start) > 5:
            start = now
            level = not level
        displayPark(0, len(parkingSpots[0]) - sum(parkingSpots[0]), display = 0)
        displayPark(1, len(parkingSpots[1]) - sum(parkingSpots[1]), display = 1)


displayThread = Thread(target=updateDisplay)

displayThread.start()

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
try:
    client.loop_start()
    input("Enter to stop\n")
    alive = 0
finally:
    client.loop_stop()
    closeDisplay()