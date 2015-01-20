#include "Smalrubot.h"
#include <Servo.h>
Smalrubot smalrubot;

// Smalrubot.h doesn't handle TXRX. Setup a function to tell it to write to Serial.
void writeResponse(char *response) { Serial.print(response); Serial.print("\n"); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  Serial.begin(115200);
  smalrubot.setupWrite(writeCallback);
}

void loop() {
  while(Serial.available() > 0) smalrubot.parse(Serial.read());
  smalrubot.updateListeners();
  Serial.flush();
}
