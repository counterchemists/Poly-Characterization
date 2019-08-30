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
    newtonmeterPort = new Serial(this, portname, 9600);
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

void setupOhmmeter() {
  String portname;

  if (System.getProperty("os.name").equals("Linux"))
    portname = "/dev/ttyUSB0";
  else
    portname = Serial.list()[1];

  ohmmeterPort = new Serial(this, portname, 115200);
  try {
    println("Opening " + portname);
  }
  catch (Exception e) {
    println(e);
    println("ERROR: OhmMeter connection failed");
    exit();
  }

  // set multimeter to measure resistance:
  ohmmeterPort.write("conf:res\n");
}


float readOhmmeter() {
  // fetch a measure:
  ohmmeterPort.write("INIT\nFETC?\n");
  while (ohmmeterPort.available() <= 0) delay(1); // delay seems mandatory

  String inBuffer = ohmmeterPort.readString();

  return float(inBuffer);
}
