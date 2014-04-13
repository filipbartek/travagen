class Map {
  private static final String filename = "map_cr_okres_highpolygon.svg";
  private static final String okresyFilename = "processed/okresy.csv";
  
  private static final float lngMin = 12.09081161f; // W; x-; 12º 05′ 26,92179″
  private static final float lngMax = 18.85925389f; // E; x+; 18° 51´ 33.31399"
  private static final float latMax = 51.05570479f; // N; y-; 51º 03′ 20,53724″
  private static final float latMin = 48.5518078f; // S; y+; 48º 33′ 06,50807″
  
  private float mapWidth = Float.NaN;
  private float mapHeight = Float.NaN;
  
  private PShape shape = null;
  private Table okresy = null;
  
  public Map() {
    loadFile();
    loadOkresy();
  }
  
  public float getWidth() {
    return shape.width;
  }
  
  public float getHeight() {
    return shape.height;
  }
  
  public float getMapWidth() {
    return mapWidth;
  }
  public float getMapHeight() {
    return mapHeight;
  }
  public float getLatMin() {
    return latMin;
  }
  public float getLatMax() {
    return latMax;
  }
  public float getLngMin() {
    return lngMin;
  }
  public float getLngMax() {
    return lngMax;
  }
  
  private void initOkresy() {
    okresy = new Table();
    okresy.addColumn("krajId");
    okresy.addColumn("okresId");
  }
  
  private void loadOkresy() {
    okresy = null;
    try {
      okresy = loadTable(okresyFilename, "header");
    } catch (NullPointerException e) {
    }
    if (okresy == null) {
      loadFileXml();
    }
  }
  
  private void loadFile() {
    shape = loadShape(filename);
    mapWidth = shape.width;
    mapHeight = shape.height;
    //shape.disableStyle();
  }
  
  private void loadFileXml() {
    println("Loading okresy XML");
    initOkresy();
    XML root = loadXML(filename);
    if (root == null) {
      return;
    }
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
    saveTable(okresy, okresyFilename, "csv");
  }
  
  public void draw(PGraphics pg) {
    PShape okresyShape = shape.getChild("Okresy");
    for (TableRow tr : okresy.rows()) {
      String krajId = tr.getString("krajId");
      String okresId = tr.getString("okresId");
      PShape okres = okresyShape.getChild(krajId).getChild(okresId);
      boolean selectedKraj = krajId.equals(selectedKrajId);
      boolean selectedOkres = okresId.equals(selectedOkresId);
      boolean selected = selectedKraj && selectedOkres;
      drawShape(okres, pg, selected);
    }
  }
  
  String selectedKrajId;
  String selectedOkresId;
  
  color cSelected = color(255, 255, 255);
  color cNotSelected = color(0, 0, 255);
  
  void drawShape(PShape shape, PGraphics mainPg, boolean selected) {
    color cFill;
    if (selected) {
      cFill = cSelected;
    } else {
      cFill = cNotSelected;
    }
    color cStroke = color(0, 0, 0);
    PGraphics pg = createGraphics(width, height);
    pg.beginDraw();
    pg.fill(cFill);
    pg.stroke(cStroke);
    pg.shape(shape);
    pg.noFill();
    pg.noStroke();
    pg.endDraw();
    //mainPg.image(pg, 0, 0);
    mainPg.fill(cFill);
    mainPg.stroke(cStroke);
    mainPg.shape(shape);
    mainPg.noFill();
    mainPg.noStroke();
  }
  
  void updateSelected() {
    PShape okresyShape = shape.getChild("Okresy");
    for (TableRow tr : okresy.rows()) {
      String krajId = tr.getString("krajId");
      String okresId = tr.getString("okresId");
      PShape okres = okresyShape.getChild(krajId).getChild(okresId);
      boolean selected = isSelected(okres);
      if (selected) {
        selectedKrajId = krajId;
        selectedOkresId = okresId;
        return; // Select at most one
      }
    }
    selectedKrajId = null;
    selectedOkresId = null;
  }
  
  boolean isSelected(PShape shape) {
    PGraphics pg = createGraphics(width, height);
    color cFill = color(255, 255, 255);
    pg.beginDraw();
    pg.fill(cFill);
    pg.shape(shape);
    pg.noFill();
    pg.endDraw();
    color cMouse = pg.get(mouseX, mouseY);
    return cMouse == cFill;
  }
}

