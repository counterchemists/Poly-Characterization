//Data collection code for magnet-feedback experiment
String textileID = "003_015_060"; // serialStep1Step2 --> 000_000_0000 --> ID_Minutes_Minutes
String filename = textileID + ".csv";

//for logging data
import java.io.BufferedWriter; //log lines
import java.io.FileWriter; //create files

import processing.serial.*; //include the serial library

//----------Configure ReadingToResistance Stuff---------------//

String HEADER = "ID,Time,Task,Resistance,Newton,Weight";                                  // TODO: Check if OK

//----------------------------------------------------------//

boolean spacePressed = false;
boolean recording = false;
int startTime = -1;
int countdown;
int[] taskDelays = { 15000 /*PressureDynamics*/, 2000 /*Pressure*/, 2000 /*Square*/, 2000 /*Stretching*/};
RecordManager recordM = new RecordManager();

int wid = 0;
int weightsPressure[] = {5, 10, 20, 50, 100, 200, 500}; //populate array with weights to use in characterization
int weightsStrain[] = {5, 10, 20, 50, 100, 200, 500}; //populate array with weights to use in characterization

int numberOfSamples = 300; //how many samples should be recorded
String[] tasks ={"PressureDynamics", "Pressure", "SquareResistance", "Stretch"}; //name of the tasks
boolean weightPlaced = false;
int taskStage = 0;

int lineCounter = 0; //will be incremented with each writing
int currentTask = 0;

//----------------UI features-----------------//

//some buttons to do stuff with
Button next;
Button previous;
Button pause;
Button placeWeight;

String taskname;
String instructions = null;
String timer = "";
int[] pos_tn = { 500, 150 };
int[] pos_inst = { 500, 175 };
int[] pos_timer = { 500, 200 };

//font to make things look nice
PFont font;


void setup() {

  textAlign(CENTER);
  font = createFont("arial", 18); //this is just for easthetics.
  textFont(font);

  size(1000, 600);

  //initializing the buttons. The text is formatted like this: "name of button: button hotkey"
  next = new Button("next:x");
  previous = new Button("previous:z");
  pause = new Button("pause:p");
  placeWeight = new Button("nextWeight: ");

  setupNewtonmeter();
  setupOhmmeter();
}


void draw() {
  //set the background
  background(180, 170, 210);
  fill(255);


  if(recording) {
    recordM.addRValue(readOhmmeter());
    float tmp = recordM.recordingNM() ? readNewton() : -1.0;
    recordM.addNMValue(tmp);
  }


  textAlign(CENTER);
  taskname = tasks[currentTask];
  //experimental Logic
  if (taskname.equals("PressureDynamics")) {
    //placeWeight.display(20, 20, 200, 200);
    //logLine();

    switch(taskStage) {
      case 0:
        if(instructions == null) { instructions = "Press the 'space' bar to start recording"; }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(true);
          recording = true;
          spacePressed = false;
          instructions = "Get ready";
          //startTime = millis();
          countdown = millis() + 5000;
        }
        break;
      case 1:
      background(250, 170, 210);
        if(countdown <= millis()) {
                      instructions = "Put the weight on the material";
          timer = null;
          taskStage = 2;
          //recording = false;
          startTime = millis();
        } else {
          int dt = countdown-millis();
          timer = (dt/1000) + ":" + (dt%1000);
        }
        break;
      case 2:
        if(recording) {
          int dt = millis() - startTime;
          if(dt > taskDelays[currentTask]) {
              background(250, 170, 210);
            instructions = "Remove the weight from the material";
            timer = null;
            taskStage = 3;
            //recording = false;
            startTime = millis();
          } else {
            timer = (dt/1000) + ":" + (dt%1000);
          }
        }
        break;
      case 3:
        //if(spacePressed) { recording = true; spacePressed = false; startTime = millis(); }
        if(recording) {
          int dt = millis() - startTime;
          if(dt > taskDelays[currentTask]) {
            instructions = "Task finished (recording data)";
            timer = null;
            taskStage = 4;
          } else {
            timer = (dt/1000) + ":" + (dt%1000);
          }
        }
        break;
      case 4:
        recording = false;
        recordM.record(textileID, taskname, -1);
        instructions = "Data recorded in "+filename+"!";
        taskStage = 5;
        break;
      case 5:
        break;
      }
  } else if (taskname.equals("Pressure")) {
    switch(taskStage) {
      case 0:
        if(instructions == null) {
          if(wid < weightsPressure.length) { instructions = String.format("Place %dg on the material (Spacebar starts recrording)", weightsPressure[wid]); }
          else { taskStage = 3; }
        }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(true);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Remove the weight from the material (saving data in %s)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2: // saving data
        recording = false;
        recordM.record(textileID, taskname, weightsPressure[wid]);
        instructions = null;
        wid++;
        taskStage = 0;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        break;
    }
  } else if (taskname.equals("SquareResistance")) {
    switch(taskStage) {
      case 0:
        if(instructions == null) { instructions = "Place the electrodes on the material (SWAP ELECTRODES)"; }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(false);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Task finished (recording data)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2:
        recording = false;
        recordM.record(textileID, taskname, -1);
        taskStage = 3;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        break;
    }
  } else if (taskname.equals("Stretch")) {
        switch(taskStage) {
      case 0:
        if(instructions == null) {
          if(wid < weightsPressure.length) { instructions = String.format("Stretch the material with %dg", weightsStrain[wid]); }
          else { taskStage = 3; }
        }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(false);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Remove the weight (saving data in %s)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2:
        recording = false;
        recordM.record(textileID, taskname, weightsStrain[wid]);
        instructions = null;
        wid++;
        taskStage = 0;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        exit();
        break;
    }
  }

  //stretch in direction of the courses: https://www.kobakant.at/DIY/?p=5689

  //display the buttons by providing them with x & y coordinate as well as height and width
  next.display(800, 400, 100, 60);
  pause.display(450, 400, 100, 60);


  //check if the buttons are clicked and do stuff if they are

  if (next.isToggled()) {
    //do something
    if (mousePressed && !next.isHover()) {
      next.toggle();
    }
    if (!mousePressed && next.isHover()) {
      //  goNext();
      next.toggle(); //switches button state
      updateTask(currentTask+1);
    }
  }

  if (previous.isToggled()) {
    //do something
    if (mousePressed && !previous.isHover()) {
      previous.toggle();
    }
    if (!mousePressed && previous.isHover()) {
      //step back
      previous.toggle(); //switches button state
      //currentCondition--; <--needs to be index (also check repititions
      updateTask(currentTask-1);
    }
  }


  if (pause.isToggled()) {
    // println(hapticsOn);
    //do something
  } else {
  }

  textAlign(LEFT);
  if(taskname != null && taskname.length() != 0) {
    text(taskname, pos_tn[0], pos_tn[1]);
  }
  if(instructions != null && instructions.length() != 0) {
    text(instructions, pos_inst[0], pos_inst[1]);
  }
  if(timer != null && timer.length() != 0) {
    text(timer, pos_timer[0], pos_timer[1]);
  }
}

void keyPressed() {
  if (key == ' ') { // space bar pressed
    spacePressed = true;
  }
  //println("Key pressed: "+key);
}


void updateTask(int tid) {
  currentTask = tid;
  taskStage = 0;
  instructions = null;
  wid = 0;
  timer = null;
  spacePressed = false;
  if (currentTask < 0 || currentTask == tasks.length) {
    currentTask = 0;
    //currentRepetition++;
  }
}

String currentTime() {
  return String.valueOf(hour()) + ":" + String.valueOf(minute()) +  " " + String.valueOf(day()) +  "/"  + String.valueOf(month()) +  "/" +   String.valueOf(year());
}
