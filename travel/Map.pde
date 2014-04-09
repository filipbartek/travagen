class Map {
  final String filename = "map_cr_okres_highpolygon.svg";
  
  PShape shape;
  Table okresy;
  
  Map() {
    okresy = new Table();
    okresy.addColumn("krajId");
    okresy.addColumn("okresId");
    
    loadFile();
    
    saveTable(okresy, "okresy.csv");
  }
  
  void loadFile() {
    shape = loadShape(filename);
    shape.disableStyle();
    
    loadFileXml();
  }
  
  void loadFileXml() {
    XML root = loadXML(filename);
    XML[] sections = root.getChildren("g");
    for (XML section : sections) {
      if (section.getString("id").equals("Okresy")) {
        XML[] kraje = section.getChildren("g");
        for (XML kraj : kraje) {
          String krajId = kraj.getString("id");
          XML[] okresyGs = kraj.getChildren("path");
          for (XML okres : okresyGs) {
            String okresId = okres.getString("id");
            TableRow tr = okresy.addRow();
            tr.setString("krajId", krajId);
            tr.setString("okresId", okresId);
          }
        }
        break; // Assume there is only one section with id "Okresy"
      }
    }
  }
  
  void draw() {
    PShape okresyShape = shape.getChild("Okresy");
    for (TableRow tr : okresy.rows()) {
      String krajId = tr.getString("krajId");
      String okresId = tr.getString("okresId");
      PShape okres = okresyShape.getChild(krajId).getChild(okresId);
      color c = color(255, 0, 0);
      fill(c);
      shape(okres);
    }
  }
}

