#include <Arduino.h>
#include <Wire.h>

#ifndef TERARANGER_ONE_H
#define TERARANGER_ONE_H

class TeraRanger_One {
 private:
  static const uint8_t crc_table[256];
  uint8_t crc8(uint8_t*, uint8_t);

 public:
  TeraRanger_One();
  uint16_t distance();
};
  
#endif
