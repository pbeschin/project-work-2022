#include <WiFi.h>
#include <PubSubClient.h>
#include <SPI.h>
#include <MFRC522.h>

#define MQTT_BROCKER "test.mosquitto.org"
#define MQTT_TOPIC_BASE "pw2k22/1.1"
#define PARK1_LEVEL 0
#define PARK1_ENTRY "/entry"
#define PARK1_EXIT "/exit"

#define RST_PIN 27          // Configurable, see typical pin layout above
#define SS_1_PIN 16         // Configurable, take a unused pin, only HIGH/LOW required, must be different to SS 2
#define SS_2_PIN 17         // Configurable, take a unused pin, only HIGH/LOW required, must be different to SS 1
#define NR_OF_READERS 2

#define BUZZER_PIN 4

byte ssPins[] = {SS_1_PIN, SS_2_PIN};
MFRC522 mfrc522[NR_OF_READERS];   // Create MFRC522 instance.

const char* ssid = "ciao";
const char* password = "Vmware1!";
char* topicRFID[] = {"entrata", "uscita"};
char topic[40];
WiFiClient espClient;
PubSubClient client(espClient);

void setup() {

  Serial.begin(9600); // Initialize serial communications with the PC
  while (!Serial);    // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
  
  SPI.begin();        // Init SPI bus
  pinMode(BUZZER_PIN, OUTPUT);
  
  // begin Wifi connect
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(2000);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connesso");
  Serial.println("Indirizzo IP : ");
  Serial.println(WiFi.localIP());

  client.setServer(MQTT_BROCKER, 1883);

  for (uint8_t reader = 0; reader < NR_OF_READERS; reader++) {
    mfrc522[reader].PCD_Init(ssPins[reader], RST_PIN); // Init each MFRC522 card
    Serial.print(F("Reader "));
    Serial.print(reader);
    Serial.print(F(": "));
    mfrc522[reader].PCD_DumpVersionToSerial();
  }
}

void reconnect() {
  // Loop until we're reconnected
  int counter = 0;
  while (!client.connected()) {
    if (counter == 5) {
      ESP.restart();
    }
    counter += 1;
    Serial.print("In attesa della connessione al Brocker MQTT ...");
    // Attempt to connect

    if (client.connect("growTentController")) {
      Serial.println("CONNESSO");
    } else {
      Serial.print("Connssione FALLITA, rc=");
      Serial.print(client.state());
      Serial.println(" Prova di riconnessione fra 5 secondi");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void loop() {
  if(!client.connected()){
    reconnect();
  }
  digitalWrite(BUZZER_PIN, LOW);
      
  for (uint8_t reader = 0; reader < NR_OF_READERS; reader++) {
  sprintf (topic, "%s/%s", MQTT_TOPIC_BASE, topicRFID[reader] );
    // Look for new cards
    if (mfrc522[reader].PICC_IsNewCardPresent() && mfrc522[reader].PICC_ReadCardSerial()) {
      Serial.print(F("Reader "));
      Serial.print(reader);
      // Show some details of the PICC (that is: the tag/card)
      Serial.print(F(": Card UID:"));
      dump_byte_array(mfrc522[reader].uid.uidByte, mfrc522[reader].uid.size);
      client.publish(topic, "Biglietto 1", true);
      digitalWrite (BUZZER_PIN, HIGH); //turn buzzer on
      delay(1000);
      digitalWrite (BUZZER_PIN, LOW);  //turn buzzer off
           
      Serial.println();
      
      //Serial.print(F("PICC type: "));
      //MFRC522::PICC_Type piccType = mfrc522[reader].PICC_GetType(mfrc522[reader].uid.sak);
      //Serial.println(mfrc522[reader].PICC_GetTypeName(piccType));

      // Halt PICC
      mfrc522[reader].PICC_HaltA();
      // Stop encryption on PCD
      mfrc522[reader].PCD_StopCrypto1();
    } //if (mfrc522[reader].PICC_IsNewC
  } //for(uint8_t reader
}

/**
 * Helper routine to dump a byte array as hex values to Serial.
 */
void dump_byte_array(byte *buffer, byte bufferSize) {
  for (byte i = 0; i < bufferSize; i++) {
    Serial.print(buffer[i] < 0x10 ? " 0" : " ");
    Serial.print(buffer[i], HEX);
  }
}
