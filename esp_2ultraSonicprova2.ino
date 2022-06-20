#include <WiFi.h>
#include <PubSubClient.h>

#define mqtt_server "test.mosquitto.org" 
#define mqtt_topik_pianoT "pw2k22/1.0/0/1"
#define mqtt_topik_piano1 "pw2k22/1.0/1/1"

#define PARK1_TRIG_PIN 22 // Pin connesso al TRIG pin del sensore ad ultrasuoni del parcheggio n.1
#define PARK1_ECHO_PIN 23 // Pin connesso al ECHO pin del sensore ad ultrasuoni del parcheggio n.1
#define PARK2_TRIG_PIN 32 // Pin connesso al TRIN pin del sensore ad ultrasuoni del parcheggio n.2
#define PARK2_ECHO_PIN 33 // Pin connesso al ECHO pin del sensore ad ultrasuoni del parcheggio n.2

#define RED_PIN 5 
#define GREEN_PIN 17
#define BLU_PIN 16

float durataPark1, distanzaPark1, durataPark2, distanzaPark2;

const char* ssid     = "ciao"; // ESP32 and ESP8266 uses 2.4GHZ wifi only
const char* password = "Vmware1!"; 

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  // begin serial port
  Serial.begin (9600);

  // configure the trigger pin to output mode
  pinMode(PARK1_TRIG_PIN, OUTPUT);
  // configure the echo pin to input mode
  pinMode(PARK1_ECHO_PIN, INPUT);
  // configure the trigger pin to output mode
  pinMode(PARK2_TRIG_PIN, OUTPUT);
  // configure the echo pin to input mode
  pinMode(PARK2_ECHO_PIN, INPUT);

  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLU_PIN, OUTPUT);

  digitalWrite(RED_PIN, LOW);
  digitalWrite(GREEN_PIN, LOW);
  digitalWrite(BLU_PIN, LOW);

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
  
  client.setServer(mqtt_server, 1883);
}

void reconnect() {
  // Loop until we're reconnected
  int counter = 0;
  while (!client.connected()) {
    if (counter==5){
      ESP.restart();
    }
    counter+=1;
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
  if (!client.connected()){
    reconnect();
  }
  
  // Generazione impulso sensore 1
  digitalWrite(PARK1_TRIG_PIN, LOW);
  digitalWrite(PARK1_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(PARK1_TRIG_PIN, LOW);
  
  // Calcolo del tempo attraverso il pin di echo
  long durata1 = pulseIn(PARK1_ECHO_PIN, HIGH);
  long distanza1 = durata1/58.31;
  Serial.print("Distanza 1: ");
  Serial.println(distanza1);
  
  // Generazione impulso sensore 2
  digitalWrite(PARK2_TRIG_PIN, LOW);
  digitalWrite(PARK2_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(PARK2_TRIG_PIN, LOW);
  
  // Calcolo del tempo attraverso il pin di echo
  long durata2 = pulseIn(PARK2_ECHO_PIN, HIGH);
  long distanza2 = durata2/58.31;
  Serial.print("Distanza 2: ");
  Serial.println(distanza2);

// Gestione del LED e Invio MQTT
  if(distanza1<30){
    client.publish(mqtt_topik_pianoT,"1",true);
    Serial.println("Park 1 OCCUPATO");
    digitalWrite(RED_PIN, HIGH);
    digitalWrite(GREEN_PIN, LOW);
    digitalWrite(BLU_PIN, LOW);
  }else{
    client.publish(mqtt_topik_pianoT,"0",true);
    Serial.println("Park 1 LIBERO");
    digitalWrite(RED_PIN, LOW);
    digitalWrite(GREEN_PIN, HIGH);
    digitalWrite(BLU_PIN, LOW);
  }
  
  if(distanza2<30){
    client.publish(mqtt_topik_piano1,"1",true);
    Serial.println("Park 2 OCCUPATO");
    digitalWrite(RED_PIN, LOW);
    digitalWrite(GREEN_PIN, LOW);
    digitalWrite(BLU_PIN, HIGH);
  }else{
    client.publish(mqtt_topik_piano1,"0",true);
    Serial.println("Park 2 LIBERO");
    digitalWrite(RED_PIN, LOW);
    digitalWrite(GREEN_PIN, HIGH);
    digitalWrite(BLU_PIN, LOW);
  }
  
  delay(1000);
}
