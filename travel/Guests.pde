import java.util.Map;

import de.bezier.data.XlsReader;

class Guests {
  private static final String dataFilename = "tabulka_CRU9010PU_OK.xls";
  private static final String processedFilename = "processed/guests.csv";
  
  public Table guests = null;
  
  private StringDict okresNameNormDict = null;
  
  public Guests(PApplet thePapplet) {
    loadGuests(thePapplet);
  }
  
  private void initOkresNameNormDict() {
    okresNameNormDict = new StringDict();
    okresNameNormDict.set("Plzeň-město", "plzen");
    okresNameNormDict.set("Ostrava-město", "ostrava");
    okresNameNormDict.set("Hlavní město Praha", "praha");
    okresNameNormDict.set("Brno-město", "brno");
  }
  
  private boolean loadGuests(PApplet thePapplet) {
    boolean loaded = loadProcessed();
    if (loaded) {
      return true;
    }
    loaded = loadData(thePapplet);
    return loaded;
  }
  
  private boolean loadProcessed() {
    boolean loaded = true;
    guests = null;
    try {
      guests = loadTable(processedFilename, "header");
    } catch (NullPointerException e) {
      loaded = false;
    }
    return loaded;
  }
  
  private boolean loadData(PApplet thePapplet) {
    println("Loading guests from XLS table");
    initOkresNameNormDict();
    initGuests();
    XlsReader reader = new XlsReader(thePapplet, dataFilename);
    reader.firstRow();
    // Go to last non-data row
    for (int i = 0; i < 4; i++) {
      reader.nextRow();
    }
    // Process data rows
    for (int i = 0; i < 77; i++) {
      reader.nextRow();
      processRow(reader);
    }
    saveTable(guests, processedFilename, "csv");
    return true;
  }
  
  private void processRow(XlsReader reader) {
    String okresName = reader.getString();
    // Go to number of guests cell
    reader.nextCell();
    int numGuests2010 = reader.getInt();
    addOkres(okresName, numGuests2010);
  }
  
  private void addOkres(String okresName, int numGuests2010) {
    String okresId = normOkresName(okresName);
    TableRow tr = guests.addRow();
    tr.setString("okresId", okresId);
    tr.setString("okresName", okresName);
    tr.setInt("guests2010", numGuests2010);
  }
  
  private void initGuests() {
    guests = new Table();
    guests.addColumn("okresId", Table.STRING);
    guests.addColumn("okresName", Table.STRING);
    guests.addColumn("guests2010", Table.INT);
  }
  
  private /*static*/ String normOkresName(String s) {
    String replacement = okresNameNormDict.get(s);
    if (replacement != null) {
      return replacement;
    }
    String result = normString(s);
    return result;
  }
}

