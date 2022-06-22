import paho.mqtt.client as mqtt
import time
import datetime
import json
import os
#import pyodbc
import requests

from display_park import *

BASE_API_URL = "https://pw2022-apinode.azurewebsites.net/"

MQTT_SERVER = "test.mosquitto.org"
MQTT_PORT = 1883
MQTT_TIMEOUT = 60

TOPIC_ROOT = "pw2k22"
TOPIC_VERSION = "1.1"

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
    client.subscribe(f"{TOPIC_ROOT}/#")

# The callback for when a PUBLISH message is received from the server.

def on_park_update(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint, level, parkID] = str(msg.topic).split("/")
    #print(tail)
    #print(f"level:{level},parkID:{parkID}")

    if parkingSpots[int(level)][int(parkID) - 1] != int(msg.payload):
        parkingSpots[int(level)][int(parkID) - 1] = int(msg.payload)
        #WriteDB(espID[-3:], int(msg.payload));
    printParkingSpots(int(level))

def on_park_entry(client, userdata, msg):
    print("entry")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    RFID = "AAAAAAAAAAAAAAAAAAAA"
    entryUrl = f"{BASE_API_URL}/transizioni/{RFID}"
    postObj = {"DATA_ENTRATA" : str(datetime.datetime.now())}
    response = requests.post(entryUrl, json = postObj)
    print(response)



def on_park_exit(client, userdata, msg):
    print("exit")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    

def on_message(client, userdata, msg):
    try:
        [root, version, endpoint, *more] = str(msg.topic).split("/")
        if version != TOPIC_VERSION:
            raise Exception("Wrong version")
        if endpoint == "parcheggio":
            on_park_update(client, userdata, msg)
        if endpoint == "entrata":
            on_park_entry(client, userdata, msg)
        if endpoint == "uscita":
            on_park_exit(client, userdata, msg)
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

client.connect(MQTT_SERVER, MQTT_PORT, MQTT_TIMEOUT)

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
finally:
    alive = 0
    client.loop_stop()
    closeDisplay()