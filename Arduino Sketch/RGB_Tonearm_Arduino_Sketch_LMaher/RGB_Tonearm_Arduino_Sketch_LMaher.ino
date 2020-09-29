/*
***************************************************
LIAM MAHER_RGB_Tonearm_ArduinoSketch
***************************************************
*/

#include <Wire.h> //include the wire library to communicate with I2C/TWI devices
#include "Adafruit_TCS34725.h" //include the library for the colour sensor

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_2_4MS, TCS34725_GAIN_16X);

int arraySpace;//extra values to extend the serial messages sent to Processing so that the array is long enough to be read accurately by Processing

void setup() {
  // put your setup code here, to run once:
  Serial.begin (9600);
  arraySpace = 0; //variable to ensure that the serial message is long enough to be successfully read
}

void loop() {


  uint16_t clear_, red, green, blue; //definte 16bit unsigned integer values for the four types of values

  tcs.getRawData(&red, &green, &blue, &clear_); //get raw clear and RGB values from sensor

  //convert raw 16 bit colour values to 8 bit values. These are adjusted according to the clear light values
  uint16_t sum = clear_;
  float r, g, b;
  r = red; r /= sum;
  g = green; g /= sum;
  b = blue, b /= sum;
  r *= 256; g *= 256; b *= 256;

  //Print each of the variables. They are separated by a tab character so that they can be effectively split and written into an array in Processing
  Serial.print(int(r));
  Serial.print("\t");
  Serial.print(int(g));
  Serial.print("\t");
  Serial.print(int(b));
  Serial.print("\t");
  Serial.print (arraySpace);
  Serial.println();

  delay(3); //wait 3 milliseconds

}
