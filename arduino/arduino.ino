#include "TeraRanger_One.h"

TeraRanger_One rangefinder;

void setup() 
{
  Serial.begin(115200); 
  while (!Serial);

  Wire.begin();

  pinMode(A0,INPUT);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void loop() 
{
  uint16_t distance = rangefinder.distance();
  if (distance > 0) {
    Serial.print('{');
    Serial.print(analogRead(A0)); Serial.print(','); Serial.print(distance);
    Serial.print('}');
  }
  else; // ignore invalid distances
}
    
//----------------------------------------------------------------------
