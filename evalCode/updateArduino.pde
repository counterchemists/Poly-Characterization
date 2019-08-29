import processing.serial.*; //include the serial library

Serial arduinoPort;  // The serial port at which we listen to data from the Arduino
String rawIncomingValues; //this is where you dump the content of the serial port
int[] incomingValues = { 0, 0, 0, 0, 0, 0, 0 };     //this is where you will store the incoming values, so you can use them in your program
int token = 10; //10 is the linefeed number in ASCII
//You can replace it with whatever symbol marks the end of your line (http://www.ascii-code.com/)
boolean connectionEstablished = false;



void arduinoSerialSetup() {
  // List all the available serial ports
  println("these are the available ports: ");
  printArray(Serial.list());
  //chose your serial port, by putting the correct number in the square brackets
  //you might need to just trial and error this, the first time you do it

  String serialPort;
    serialPort = Serial.list()[0];

  //check if you are using the port you think you are using
  println("You are using this port: " + serialPort);
  // Open the port with the same baud rate you set in your arduino
  arduinoPort = new Serial(this, serialPort, 9600);
}


//This is the function that receives and parses the data
//it executes whenever data is received
void serialEvent(Serial arduinoPort) {
  //we read the incoming data until we have found our toke (its defined at the top, but can be any character
  rawIncomingValues = arduinoPort.readStringUntil(token);
  //if there actually is a valid incoming value, we use the splitTokens
  //this splits the incoming string into an array of integers that is easy to work with
  if (rawIncomingValues != null) {
    incomingValues = int(trim(splitTokens(rawIncomingValues, ",")));
    //  println(incomingValues);
    connectionEstablished = true;

    if(recording) {
      if(recordM.recordingNM()) {
        recordM.addNMValue(readNewton());
      }
      recordM.addValues(incomingValues);
    }
  }
}
