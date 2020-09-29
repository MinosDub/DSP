/*
*************************************************
LIAM MAHER
The RGB Tonearm
Processing Sketch
*************************************************

*************************************************
 PSEUDOCODE
*************************************************


 1. Read in values from a colour sensor via the use of the Arduino Serial Port. 
 2. Write these values into an array so that they can be accessed and mapped to audio effects. 
 3. Read in an audio feed from a turntable via a soundcard. Set up classes in order to do so.
 4. Set up a chain of filters which can be mapped to the turntable input.
 5. Set up a series of mappings which cause the different filters to behave in different ways.
 */

//import the libraries that the sketch will use
import processing.serial.*; 
import ddf.minim.*; 
import ddf.minim.ugens.*; 
import ddf.minim.effects.*;

//set up variables that the sketch will use
int [] colors = {0, 0, 0, 0}; //set up an array that will store the RGB and clear values of the sensor
Serial port; 
String bufferIn; 
Minim minim;
AudioInput input;
AudioOutput output;
AudioListener signal; 
LowPassFS lpf;
int LPFcutoff;
float LPF_freq;
HighPassSP hpf;
int HPFcutoff = 1000; 
float HPF_freq;
BandPass bpf;

void setup () {
  size (1024, 400, P3D); 
  port = new Serial (this, "/dev/cu.usbmodem1421", 9600); //begin reading from the specified serial port at a baud rate of 9600
  port.bufferUntil ('\n'); //keep reading this data until a newline character
  frameRate (30); //set sketch framerate
  minim = new Minim (this); //instantiate the Minim class
  int buffer = 1024; //set buffer size
  input = minim.getLineIn(Minim.STEREO, buffer); //set up the input buffer for Minim to listen to
  output = minim.getLineOut(Minim.STEREO, buffer); //set the output buffer for Minim to listen to
  signal = new InputOutputBind(1024); //let Minim know to output the signal that is coming in via the turntable
  input.addListener(signal); //allows sample buffers to be received for sound generating classes immediately after being generated. Here, it allows for real time filtering of the audio input.
  output.addListener(signal); //allows sample buffers to be received for sound generating classes immediately after being generated. Here, it allows for real time filtering of the audio input.
  lpf = new LowPassFS (LPFcutoff, 44100); //instantiate LowPassFS, set cutoff to be a variable and the sample rate.
  input.addEffect(lpf); //Add low pass filter to the input
  hpf = new HighPassSP(HPFcutoff, 44100); //instantiate HighPassSP, set cutoff to be a variable and also set the sample rate.
  input.addEffect(hpf); //Add effect to input.
  bpf = new BandPass (440, 20, 44100); //instantiate BandPass, set cutoff starting bandwidth and the and also set the sample rate.
  input.addEffect(bpf); //Add effect to input.
}

void draw () {
  background(colors[0], colors[1], colors[2]);  //Set background colour to represent the RGB values from the colour sensor
  LPFcutoff = (colors [0]); //map the Red values of the sensor to the low pass filter cutoff frequency.
  LPF_freq = map(LPFcutoff, 100, 256, 200, 3000); //threshold and map these red values to be between 200 and 3000Hz for filtering. 
  lpf.setFreq(LPF_freq); //set Low Pass filter frequencies to be the mapped values in the above line. 
  HPFcutoff = ((colors [1] + colors [2])/2); //set the cutoff frequency of the high pass filter to be the incoming red and blue values from the sensor, divided by 2. 
  HPF_freq = map(HPFcutoff, 0, 256, 3000, 10000); //map the above values to be between 3000 and 10,000 Hz
  println (HPF_freq); //println function to aid in debugging
  //println (LPF_freq); //println function to aid in debugging
  float passBand = map(colors[0], 0, 255, 500, 1000); // map the Red color values to the range [100, 5000] for the passBand frequencies
  bpf.setFreq(passBand); //set pass band frequencies to be the mapped values above
  float bandWidth = map(colors[2], 0, 255, 50, 500); //set the bandwidth of the filter to be mapped blue values from the sensor
  bpf.setBandWidth(bandWidth); //set bandwidth to the above mapped values

//draw the waveforms so we can see what is monitoring
for (int i=0; i < input.bufferSize () - 1; i++) {
  stroke (0);
  line( i, 100 + input.left.get(i)*50, i+1, 100 + input.left.get(i+1)*50 );
  line( i, 300 + input.right.get(i)*50, i+1, 300 + input.right.get(i+1)*50 );
  
  // draw a rectangle to represent the pass band
  noStroke();
  fill(255);
  rect((bpf.getBandWidth()/1.5), 0, (bpf.getBandWidth()/1.5), height);
}

//Print some text to the sketch screen so that the user can tell if input monitoring is enabled or disabled
String monitoringState = input.isMonitoring() ? "enabled" : "disabled";
fill (0);
text( "Input monitoring is currently " + monitoringState + ".", 5, 15 );
}


//keyPressed functions here allow user interaction with the system and allow them to change the types of filters that are heard
void keyPressed()
{
  //function for Low Pass Filter
  if ( key == '1') {
    input.addEffect (lpf);
    input.removeEffect (hpf);
    input.removeEffect (bpf);
  }
  //function for High Pass Filter
  if ( key == '2') {
    input.removeEffect (lpf);
    input.removeEffect (bpf);
    input.addEffect (hpf);
  }
  //function for Band Pass Filter
  if ( key == '3') {
    input.addEffect (bpf);
    input.removeEffect (lpf);
    input.removeEffect (hpf);
  }
  //function to remove filters altogether and allow the unfiltered analogue signal to be heard
  if ( key == '4') {
    input.removeEffect (bpf);
    input.removeEffect (lpf);
    input.removeEffect (hpf);
  }
 //function to allow the toggling on and off of monitoring the audio
  if ( key == 'm' || key == 'M' )
  {
    if ( input.isMonitoring() )
    {
      input.disableMonitoring();
    } else
    {
      input.enableMonitoring();
    }
  }
}

//allows for the reading of incoming data from the serial port of the Arduino board
void serialEvent (Serial port) {
  if (port.available()>0) { //Read from the serial port if there are any available values to read
    bufferIn = port.readStringUntil('\n'); //Fill the bufferIn variable with characters from the serial port until a new line character is read
    if (bufferIn!=null) {                           //if the string values is not a null character
    String [] stringArray = split (bufferIn, '\t'); //fill an array with the string values and separate each values by a tab character

      colors = new int [4]; //setup a new array of integers with five places
      if (stringArray.length == 4) {           //if the array is 5 characters full
        for (int i=0; i<colors.length; i++) {  //fill the array with the values from the string array using a for loop until all of the slots are full
          colors [i] = int (stringArray [i]);
          //println (colors); //allows for debugging
        }
      }
    }
  }
}

//some housekeeping for the sketch, making sure minim and the audio output are closed when the sketch is closed
void stop()
{
  output.close();
  minim.stop();
}
