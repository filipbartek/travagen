import de.bezier.data.XlsReader;

class Suicides {
  private static final String file_suicides = "401211p10.xls";
  private static final String processedFilename = "processed/suicides.csv";
  
  public Table suicides = null;
  
  private StringDict okresNameNormDict = null;
  
  public Suicides(PApplet thePapplet) {
    initOkresNameNormDict();
    loadSuicides(thePapplet);
  }
  
  private void initOkresNameNormDict() {
    okresNameNormDict = new StringDict();
    okresNameNormDict.set("Karlovy  Vary", "karlovy_vary");
    okresNameNormDict.set("Plzeň-město", "plzen");
    okresNameNormDict.set("Ostrava-město", "ostrava");
    okresNameNormDict.set("Mladá Bol.", "mlada_boleslav");
    okresNameNormDict.set("Brno-město", "brno");
  }
  
  private void loadSuicides(PApplet thePapplet) {
    boolean loaded = loadSuicidesProcessed();
    if (!loaded) {
      loadSuicidesXls(thePapplet);
    }
  }
  
  private boolean loadSuicidesProcessed() {
    boolean loaded = true;
    suicides = null;
    try {
      suicides = loadTable(processedFilename, "header");
    } catch (NullPointerException e) {
      loaded = false;
    }
    return loaded;
  }
  
  private void loadSuicidesXls(PApplet thePapplet) {
    println("Loading suicides from XLS file");
    initSuicides();
    XlsReader reader;
    reader = new XlsReader(thePapplet, file_suicides);
    
    // Process the two parts
    for (int headCell = 0; headCell <= 7; headCell += 7) {
      reader.firstRow();
      
      // Go to header row
      for (int i = 0; i < 3; i++) {
        reader.nextRow();
      }
      
      // Process data rows
      while (reader.hasMoreRows()) {
        reader.nextRow();
        processRow(reader, headCell);
      }
    }
    saveTable(suicides, processedFilename, "csv");
  }
  
  private void processRow(XlsReader reader, int headCell) {
    // Go to header cell
    while (reader.hasMoreCells() &&
        reader.getCellNum() < headCell) {
      reader.nextCell();
    }
    if (reader.getCellNum() == headCell) {
      String okres_name = reader.getString();
      if (!okres_name.equals("")) {
        int rowNum = reader.getRowNum();
        int cellNum = reader.getCellNum() + 5;
        int value = reader.getInt(rowNum, cellNum);
        addOkres(okres_name, value);
      }
    }
  }
  
  private void initSuicides() {
    suicides = new Table();
    suicides.addColumn("okres_name");
    suicides.addColumn("suicides_2010");
    suicides.addColumn("okresNameNormal");
  }
  
  private void addOkres(String name, int suicides2010) {
    TableRow newRow = suicides.addRow();
    newRow.setString("okres_name", name);
    newRow.setInt("suicides_2010", suicides2010);
    String nameNormal = normOkresName(name);
    newRow.setString("okresNameNormal", nameNormal);
  }
  
  private String normOkresName(String s) {
    String replacement = okresNameNormDict.get(s);
    if (replacement != null) {
      return replacement;
    }
    String result = normString(s);
    return result;
  }
}

