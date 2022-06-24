/*
  LiquidCrystal Library - display() and noDisplay()

 Demonstrates the use a 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.

 This sketch prints "Hello World!" to the LCD and uses the
 display() and noDisplay() functions to turn on and off
 the display.

 The circuit:
 * LCD RS pin to digital pin 12
 * LCD Enable pin to digital pin 11
 * LCD D4 pin to digital pin 5
 * LCD D5 pin to digital pin 4
 * LCD D6 pin to digital pin 3
 * LCD D7 pin to digital pin 2
 * LCD R/W pin to ground
 * 10K resistor:
 * ends to +5V and ground
 * wiper to LCD VO pin (pin 3)

 Library originally added 18 Apr 2008
 by David A. Mellis
 library modified 5 Jul 2009
 by Limor Fried (http://www.ladyada.net)
 example added 9 Jul 2009
 by Tom Igoe
 modified 22 Nov 2010
 by Tom Igoe
 modified 7 Nov 2016
 by Arturo Guadalupi

 This example code is in the public domain.

 http://www.arduino.cc/en/Tutorial/LiquidCrystalDisplay

*/

// include the library code:
#include <LiquidCrystal.h>

// initialize the library by associating any needed LCD interface pin
// with the arduino pin number it is connected to
const int rs = 21, en = 22, d4 = 26, d5 = 25, d6 = 33, d7 = 32;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

float amount = 0;

const int int_pin = 34;

volatile bool paymentReceived = false;

void parking_paymentReceived(){
  paymentReceived = true;
}

void ShowAmountToPay(float amount){
  // Print the Amount to pay:
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Amount to pay:");
  lcd.setCursor(0,1);
  lcd.print("EURO");
  lcd.setCursor(5,1);
  lcd.print(amount);
}

void BlinkPaymentConfirmed(){
  // Print paymentReceived:
  lcd.noDisplay();
  delay(500);
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Payment");
  lcd.setCursor(0,1);
  lcd.print("Confirmed");
  lcd.display();
  delay(500);
}

void setup() {
  pinMode(int_pin, INPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  attachInterrupt(digitalPinToInterrupt(int_pin), parking_paymentReceived, FALLING);
  ShowAmountToPay(amount);
}

void loop() {
  if(paymentReceived) {
    BlinkPaymentConfirmed();
    paymentReceived = false;
    ShowAmountToPay(amount);   
  }
}
