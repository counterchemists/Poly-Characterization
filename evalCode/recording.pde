
class RecordManager {
  
  ArrayList<int[]> chipValues = new ArrayList<int[]>();
  ArrayList<Float> nmValues = new ArrayList<Float>(); // Newtonmeter values
  boolean recordN; // tells whether newtonmeter data are recorded
  
  void clearValues() {
    chipValues.clear();
    nmValues.clear();
  }
   
  void addValues(int[] values) { chipValues.add(values); }
  
  void addNMValue(float value) { nmValues.add(value); }
  
  void recordNM(boolean r) { recordN = r; }
  
  boolean recordingNM() { return recordN; }
  
  void record(String textID, String taskname, int weight) {
      // header: TextileID,Time,Taskname,10M,1M,330k,100k,47k,10k,4.7k,1k,407,220,47,10,4.7,Newton,Weight
    for(int vi=0; vi<chipValues.size(); vi++) {
      String line = String.format("%s,%d,%s,", textID, millis(), taskname);
      for(int v: chipValues.get(vi)) {
        line += v+",";
      }
      if(recordN) { line += nmValues.get(vi)+","; }
      line += weight+",";
      appendTextToFile(filename, line.substring(0, line.length()-1)+"\n");
    }
    clearValues();
  }
};
