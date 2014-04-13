import de.bezier.data.XlsReader;

class Suicides {
  private static final String file_suicides = "401211p10.xls";
  
  // Columns:
  // okres_name
  // suicides_2010
  public /*static*/ Table loadSuicides(PApplet thePapplet) {
    XlsReader reader;
    println(dataPath(""));
    reader = new XlsReader(thePapplet, file_suicides);
    
    Table suicides;
    suicides = new Table();
    suicides.addColumn("okres_name");
    suicides.addColumn("suicides_2010");
    
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
        // Go to header cell
        while (reader.hasMoreCells() &&
            reader.getCellNum() < headCell) {
          reader.nextCell();
        }
        if (reader.getCellNum() == headCell) {
          String okres_name = reader.getString();
          if (!okres_name.equals("")) {
            TableRow newRow = suicides.addRow();
            newRow.setString("okres_name", okres_name);
            int rowNum = reader.getRowNum();
            int cellNum = reader.getCellNum() + 5;
            int value = reader.getInt(rowNum, cellNum);
            newRow.setInt("suicides_2010", value);
          }
        }
      }
    }
    
    return suicides;
  }
}

