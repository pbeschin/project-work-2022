#include <LiquidCrystal.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <SPI.h>
#include <MFRC522.h>


#define MQTT_BROCKER "test.mosquitto.org"
#define MQTT_TOPIC_BASE "pw2k22/1.1"
#define PARK1_LEVEL 0
#define PARK1_ENTRY "/entry"
#define PARK1_EXIT "/exit"
#define PRIZE "/prize"

const char* ssid = "ciao";
const char* password = "Vmware1!";
char* topicRFID[] = {"entrata", "uscita"};
char* topicPrezzo = "pw2k22/1.0/0/prezzo";
char topic[40];
WiFiClient espClient;
PubSubClient client(espClient);

#define RST_PIN 27          // Configurable, see typical pin layout above
#define SS_1_PIN 16         // Configurable, take a unused pin, only HIGH/LOW required, must be different to SS 2
#define SS_2_PIN 17         // Configurable, take a unused pin, only HIGH/LOW required, must be different to SS 1
#define NR_OF_READERS 2

byte ssPins[] = {SS_1_PIN, SS_2_PIN};
MFRC522 mfrc522[NR_OF_READERS];   // Create MFRC522 instance.

#define LCD_COLS 16
#define LCD_ROWS 2
#define RS 21
#define EN 22
#define D4 26
#define D5 25
#define D6 33
#define D7 32

LiquidCrystal lcd(RS, EN, D4, D5, D6, D7);

#define BUZZER_PIN 4

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
    client.subscribe("pw2k22/1.0/0/prezzo");
    if (client.connect("growTentController")) {
      Serial.println("CONNESSO");
      //client.subscribe(topicPrezzo);
    } else {
      Serial.print("Connssione FALLITA, rc=");
      Serial.print(client.state());
      Serial.println(" Prova di riconnessione fra 5 secondi");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String messageTmp;
  
  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    lcd.print("Prezzo: ");
    lcd.print((char)message[i]);
    messageTmp += (char)message[i];
  }
  if (String(topic) == "pw2k22/1.0/0/prezzo") {
    Serial.print("Changing output to ");
    if(messageTmp == "on"){
      Serial.println("on");
    }
    else if(messageTmp == "off"){
      Serial.println("off");
    }
  }
  Serial.println();
  Serial.println("-----------------------");
}

void setup() {

  Serial.begin(9600); // Initialize serial communications with the PC
  while (!Serial);    // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
  
  SPI.begin();        // Init SPI bus
  lcd.begin(LCD_COLS, LCD_ROWS);
  
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
  client.subscribe("pw2k22/1.0/0/prezzo");
  //client.setCallback(callback);

  for (uint8_t reader = 0; reader < NR_OF_READERS; reader++) {
    mfrc522[reader].PCD_Init(ssPins[reader], RST_PIN); // Init each MFRC522 card
    Serial.print(F("Reader "));
    Serial.print(reader);
    Serial.print(F(": "));
    mfrc522[reader].PCD_DumpVersionToSerial();
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
      if(reader == 0){
        char UID[20];
        dump_byte_array(mfrc522[reader].uid.uidByte, mfrc522[reader].uid.size);
        sprintf(UID, "%X-%X-%X-%X", mfrc522[reader].uid.uidByte[0],mfrc522[reader].uid.uidByte[1],mfrc522[reader].uid.uidByte[2],mfrc522[reader].uid.uidByte[3]);
        Serial.print("\nMQTT-UID: ");
        Serial.println(UID);
        client.publish(topic, UID, false);
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print("Entrata");   
      }else{
        char UID[20];
        dump_byte_array(mfrc522[reader].uid.uidByte, mfrc522[reader].uid.size);
        sprintf(UID, "%X-%X-%X-%X", mfrc522[reader].uid.uidByte[0],mfrc522[reader].uid.uidByte[1],mfrc522[reader].uid.uidByte[2],mfrc522[reader].uid.uidByte[3]);
        Serial.print("\nMQTT-UID: ");
        Serial.println(UID);
        client.publish(topic, UID, false);
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print("Uscita");
      }    
      digitalWrite (BUZZER_PIN, HIGH); //turn buzzer on
      delay(1000);
      digitalWrite (BUZZER_PIN, LOW);  //turn buzzer off
           
      Serial.println();

      // Halt PICC
      mfrc522[reader].PICC_HaltA();
      // Stop encryption on PCD
      mfrc522[reader].PCD_StopCrypto1();
    }
  } 
}

void dump_byte_array(byte *buffer, byte bufferSize) {
  for (byte i = 0; i < bufferSize; i++) {
    Serial.print(buffer[i] < 0x10 ? " 0" : " ");
    Serial.print(buffer[i], HEX);
  }
}
