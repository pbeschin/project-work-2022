import paho.mqtt.client as mqtt
import time
from datetime import datetime, timezone, timedelta
import json
import os
#import pyodbc
import requests

from display_park import *

# delete retained message:
# mosquitto_pub -h test.mosquitto.org -t pw2k22/1.1/uscita -n -r -d

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
    client.subscribe(f"{TOPIC_ROOT}/{TOPIC_VERSION}/#")

# The callback for when a PUBLISH message is received from the server.

def update_park_api(espID: str, statoEsp: bool):
    parkUrl = f"https://pw2022-apinode.azurewebsites.net/stato/{espID}"
    #PUT /stato/:idEsp `{"statoEsp":Boolean}`
    putObj = {"statoEsp": statoEsp}
    print(parkUrl, putObj)
    response = requests.put(parkUrl, json = putObj)
    print(response.status_code, response.text)

def on_park_update(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint, level, parkID] = str(msg.topic).split("/")
    #print(tail)
    #print(f"level:{level},parkID:{parkID}")
    parkingSpots[int(level)][int(parkID) - 1] = int(msg.payload)
    espID = f"{level}{int(parkID):02d}"

    statoEsp = (bool(msg.payload.decode("utf-8")))

    update_park_api(espID, statoEsp)
        
    printParkingSpots(int(level))

def park_entry_api(RFID: str):
    entryUrl = f"https://pw2022-apinode.azurewebsites.net/transazioni/{RFID}"
    postObj = {"data_entrata" : str(datetime.now(timezone(timedelta(hours = 2))))}
    print(entryUrl, postObj)
    response = requests.post(entryUrl, json = postObj)
    print(response.status_code, response.text)

def on_park_entry(client, userdata, msg):
    print("entry")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    RFID = msg.payload.decode("utf-8")
    park_entry_api(RFID)


def park_exit_api(RFID: str):
    exitUrl = f"https://pw2022-apinode.azurewebsites.net/transazioni/uscita/{RFID}"
    putObj = {"data_uscita" : str(datetime.now(timezone(timedelta(hours = 2))))}
    print(putObj)
    response = requests.put(exitUrl, json = putObj)
    print(response.status_code, response.text)

def on_park_exit(client, userdata, msg):
    print("exit")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    RFID = msg.payload.decode("utf-8")
    park_exit_api(RFID)
    

def on_message(client, userdata, msg):
    matched = false
    try:
        [root, version, endpoint, *more] = str(msg.topic).split("/")
        if version != TOPIC_VERSION:
            raise Exception("Wrong version")
        if endpoint == "parcheggio":
            on_park_update(client, userdata, msg)
            matched = true
        if endpoint == "entrata":
            on_park_entry(client, userdata, msg)
            matched = true
        if endpoint == "uscita":
            on_park_exit(client, userdata, msg)
            matched = true
        
        if matched == false:
            print("on_message: 'endpoint didn't match any value'")
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
    while alive:
        for level in range(2):
            displayPark(level, len(parkingSpots[level]) - sum(parkingSpots[level]), display = level)
            displayPark(level, len(parkingSpots[level]) - sum(parkingSpots[level]), display = level)


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