#include <WiFi.h>
#include <PubSubClient.h>

#define mqtt_server "test.mosquitto.org"
#define mqtt_topic_base "pw2k22/1.0"
#define PARK1_LEVEL 0
#define PARK1_SLOT1 1
#define PARK1_SLOT2 2

#define PARK1_TRIG_PIN 22 // Pin connesso al TRIG pin del sensore ad ultrasuoni del parcheggio n.1
#define PARK1_ECHO_PIN 23 // Pin connesso al ECHO pin del sensore ad ultrasuoni del parcheggio n.1
#define PARK2_TRIG_PIN 32 // Pin connesso al TRIN pin del sensore ad ultrasuoni del parcheggio n.2
#define PARK2_ECHO_PIN 33 // Pin connesso al ECHO pin del sensore ad ultrasuoni del parcheggio n.2

#define LED_PARK1_PIN 5
#define LED_BOTH_PIN 17
#define LED_PARK2_PIN 16

float durataPark1, distanzaPark1, durataPark2, distanzaPark2;

char topic[20];

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

  pinMode(LED_PARK1_PIN, OUTPUT);
  pinMode(LED_BOTH_PIN, OUTPUT);
  pinMode(LED_PARK2_PIN, OUTPUT);

  digitalWrite(LED_PARK1_PIN, LOW);
  digitalWrite(LED_BOTH_PIN, LOW);
  digitalWrite(LED_PARK2_PIN, LOW);

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
  if (!client.connected()) {
    reconnect();
  }

  // Generazione impulso sensore 1
  digitalWrite(PARK1_TRIG_PIN, LOW);
  digitalWrite(PARK1_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(PARK1_TRIG_PIN, LOW);

  // Calcolo del tempo attraverso il pin di echo
  long durataPark1 = pulseIn(PARK1_ECHO_PIN, HIGH);
  long distanzaPark1 = durataPark1 / 58.31;
  Serial.print("Distanza 1: ");
  Serial.println(distanzaPark1);

  // Generazione impulso sensore 2
  digitalWrite(PARK2_TRIG_PIN, LOW);
  digitalWrite(PARK2_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(PARK2_TRIG_PIN, LOW);

  // Calcolo del tempo attraverso il pin di echo
  long durataPark2 = pulseIn(PARK2_ECHO_PIN, HIGH);
  long distanzaPark2 = durataPark2 / 58.31;
  Serial.print("Distanza 2: ");
  Serial.println(distanzaPark2);

  bool park1Occupato = distanzaPark1 < 30;
  bool park2Occupato = distanzaPark2 < 30;

  sprintf(topic, "%s/%d/%d", mqtt_topic_base, PARK1_LEVEL, PARK1_SLOT1);

  if (park1Occupato) {
    digitalWrite(LED_PARK1_PIN, HIGH);
    client.publish(topic, "1", true);
  } else {
    digitalWrite(LED_PARK1_PIN, LOW);
    client.publish(topic, "0", true);
  }
  sprintf(topic, "%s/%d/%d", mqtt_topic_base, PARK1_LEVEL, PARK1_SLOT2);

  if (park2Occupato) {
    digitalWrite(LED_PARK2_PIN, HIGH);
    client.publish(topic, "1", true);
  } else {
    digitalWrite(LED_PARK2_PIN, LOW);
    client.publish(topic, "0", true);
  }

  if (!park1Occupato && !park2Occupato) {
    digitalWrite(LED_BOTH_PIN, HIGH);
  } else {
    digitalWrite(LED_BOTH_PIN, LOW);
  }
  delay(1000);
}
