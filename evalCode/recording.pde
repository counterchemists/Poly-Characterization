
class RecordManager {

  ArrayList<Float> rValues = new ArrayList<Float>(); // Ohmmeter values
  ArrayList<Float> nmValues = new ArrayList<Float>(); // Newtonmeter values
  boolean recordN; // tells whether newtonmeter data are recorded

  void clearValues() {
    rValues.clear();
    nmValues.clear();
  }

  void addRValue(float value) { rValues.add(value); }
  void addNMValue(float value) { nmValues.add(value); }

  void recordNM(boolean r) { recordN = r; }

  boolean recordingNM() { return recordN; }

  void record(String textID, String taskname, int weight) {
    for(int i=0; i<rValues.size(); i++) {
      // header: TextileID,Time,Taskname,Resistance,Newton,Weight
      String line = String.format("%s,%d,%s,", textID, millis(), taskname);
      line += rValues.get(i)+",";
      line += nmValues.get(i)+",";
      line += weight+",";
      appendTextToFile(filename, line.substring(0, line.length()-1)+"\n");
    }
    clearValues();
  }
};
