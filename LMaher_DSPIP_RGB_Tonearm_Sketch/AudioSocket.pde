//This routine lets Minim know to output the signal that is coming in via the turntable

class InputOutputBind implements AudioSignal, AudioListener
{
  private float[] leftChannel ;
  private float[] rightChannel;

 InputOutputBind(int sample)
  {
    leftChannel = new float[sample];
    rightChannel= new float[sample];
  }
  // This part is implementing AudioSignal interface, see Minim reference
  void generate(float[] samp)
  {
  //arraycopy() method copies an array from the specified source array, beginning at the specified position, to the specified position of the destination array.
    arraycopy(leftChannel,samp);
  }
 //generate values for the range of the function
  void generate(float[] left, float[] right)
  {
     arraycopy(leftChannel,left);
     arraycopy(rightChannel,right);
  }
 // This part is implementing AudioListener interface, see Minim reference 
 //Synchronized methods enable a simple strategy for preventing thread interference and memory consistency errors. 
 //If an object is visible to more than one thread, all reads or writes to that object's variables are done through synchronized methods.
  synchronized void samples(float[] samp)
  {
     arraycopy(samp,leftChannel);
  }
  
  //Write arraycopy values to the left and right channels
  synchronized void samples(float[] sampL, float[] sampR)
  {
    arraycopy(sampL,leftChannel);
    arraycopy(sampR,rightChannel);
  }  
} 

