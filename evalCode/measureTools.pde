import processing.serial.*; //include the serial library

Serial newtonmeterPort;
Serial ohmmeterPort;

float ohm = 0;


/////////////////////////////////////////////////////
// NEWTON METER:

void setupNewtonmeter() {
  String portname;
  if (System.getProperty("os.name").equals("Linux"))
    portname = "/dev/ttyACM0";
  else
    portname = Serial.list()[1];

  println("Opening " + portname);
  try {
    newtonmeterPort = new Serial(this, "COM4", 9600);
  }
  catch (Exception e) {
    println(e);
    println("ERROR: Newtonmeter connection failed");
    exit();
  }
}

float readNewton() {
  // ask Newtonmeter to provide data
  newtonmeterPort.write("?");
  while (newtonmeterPort.available() <= 0) delay(1); // delay seems mandatory

  String inBuffer = newtonmeterPort.readString();
  String force = new String(inBuffer);
  force = force.substring(1, force.length()-2);
  return float(force);
}

/////////////////////////////////////////////////////
// OHM METER:

void setupOhmmeter() {//manually setOhmmeter to 5digit .2plc before starting sketch
  String portname;

  if (System.getProperty("os.name").equals("Linux"))
    portname = "/dev/ttyUSB0";
  else
    portname = Serial.list()[1];

  ohmmeterPort = new Serial(this, "COM3", 115200);
  try {
    println("Opening " + portname);
  }
  catch (Exception e) {
    println(e);
    println("ERROR: OhmMeter connection failed");
    exit();
  }

  // set multimeter to measure resistance (+turn display off for speed):
   ohmmeterPort.write("DISP OFF\n");
}


float readOhmmeter() { //manually setOhmmeter to 5digit .2plc
  // fetch a measure:
  ohmmeterPort.write("INIT\nFETC?\n");
  while (ohmmeterPort.available() <= 0) delay(1); // delay seems mandatory

  String inBuffer = ohmmeterPort.readString();
  float[] inValues = float(split(inBuffer, ","));
  print(inValues.length + " ---> "); 
  if (inValues.length>2) {
    println(inValues[inValues.length-2]);//I discard the last one, in case its malformed, and use the most recent one after
    return inValues[inValues.length-2];
  } else {
    return Float.NaN;
  }
}