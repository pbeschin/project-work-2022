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

API_URL = "https://pw2022-apinode.azurewebsites.net"

MQTT_SERVER = "test.mosquitto.org"
MQTT_PORT = 1883
MQTT_TIMEOUT = 60

TOPIC_ROOT = "pw2k22"
TOPIC_VERSION = "1.1"

#local variable for counting parking spaces
parkingSpots = {0: [0]*50,
                1: [0]*50,
                2: [0]*50}

#paying RFID
payRFID = ""

#debug per level
def printParkingSpots(level):
    print(f"Printing level {level} parking spots")
    for i in range(5):
        print(i, parkingSpots[level][i*10:(i+1)*10])

# The callback for when the client receives a CONNACK response from the server.


def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe(f"{TOPIC_ROOT}/+/#")

# The callback for when a PUBLISH message is received from the server.

def update_park_api(espID: str, statoEsp: bool):
    parkUrl = f"{API_URL}/stato/{espID}"
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

    statoEsp = (int(msg.payload.decode("utf-8")))

    parkingSpots[int(level)][int(parkID) - 1] = statoEsp
    espID = f"{level}{int(parkID):02d}"

    update_park_api(espID, statoEsp)
        
    printParkingSpots(int(level))

def park_entry_api(RFID: str) -> bool:
    entryUrl = f"{API_URL}/transazioni/{RFID}"
    postObj = {"data_entrata" : str(datetime.now(timezone(timedelta(hours = 2)))  + timedelta(hours = 2))}
    print("DEBUG\n",
    "\tnow", str(datetime.now()),
    "\n\ttd", str(datetime.now()  + timedelta(hours = 2)),
    "\n\ttz", str(datetime.now(timezone(timedelta(hours = 2)))),
    "\n\ttdz", str(datetime.now(timezone(timedelta(hours = 2)))  + timedelta(hours = 2))
    )
    print(entryUrl, postObj)
    response = requests.post(entryUrl, json = postObj)
    print(response.status_code, response.text)
    if 200 <= response.status_code <=204:
        client.publish(f"{TOPIC_ROOT}/{TOPIC_VERSION}/barraentrata", payload="1", qos=2)

def on_park_entry(client, userdata, msg):
    print("entry")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    RFID = msg.payload.decode("utf-8")
    park_entry_api(RFID)


def park_exit_api(RFID: str):
    global payRFID
    exitUrl = f"{API_URL}/transazioni/{RFID}/uscita"
    putObj = {"data_uscita" : str(datetime.now(timezone(timedelta(hours = 2))) + timedelta(hours = 2))}
    print(putObj)
    response = requests.put(exitUrl, json = putObj)
    prezzo = response.json()["prezzo"]
    print(response.status_code, response.json())
    if (response.status_code == 200):
        payRFID = RFID
        client.publish(f"{TOPIC_ROOT}/{TOPIC_VERSION}/pagamento", payload=f"EURO {prezzo:.2f}", qos=2)


def on_park_exit(client, userdata, msg):
    print("exit")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    RFID = msg.payload.decode("utf-8")
    park_exit_api(RFID)

def park_paid_api(RFID: str):
    payUrl = f"{API_URL}/transazioni/{RFID}/pagamento"
    putObj = {}
    print(putObj)
    response = requests.put(payUrl, json = putObj)
    print(response.status_code, response.text)
    if 200 <= response.status_code <=204:
        client.publish(f"{TOPIC_ROOT}/{TOPIC_VERSION}/barrauscita", payload="1", qos=2)

def on_park_paid(client, userdata, msg):
    print("paid")
    print(msg.topic+" "+str(msg.payload))
    [root, version, endpoint] = str(msg.topic).split("/")
    paid = msg.payload.decode("utf-8")
    if int(paid) == 1:
        park_paid_api(payRFID)
    else:
        print("Payment failed")

def on_message(client, userdata, msg):
    matched = 0
    try:
        [root, version, endpoint, *more] = str(msg.topic).split("/")
        if version != TOPIC_VERSION:
            raise Exception(f"Wrong version [{msg.topic}]")
        if endpoint == "parcheggio":
            on_park_update(client, userdata, msg)
            matched = 1
        if endpoint == "entrata":
            on_park_entry(client, userdata, msg)
            matched = 1
        if endpoint == "uscita":
            on_park_exit(client, userdata, msg)
            matched = 1
        if endpoint == "pagato":
            on_park_paid(client, userdata, msg)
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