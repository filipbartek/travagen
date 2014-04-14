import java.util.Set;
import java.util.HashSet;

class MapOkresy {
  private static final String filename = "Districts_of_Czech_Republic_vector_line_model.svg";
  //private static final String filename = "map_cr_okres_highpolygon.svg";
  private static final String okresyFilename = "processed/okresy.csv";
  
  private static final float lngMin = 12.09081161f; // W; x-; 12º 05′ 26,92179″
  private static final float lngMax = 18.85925389f; // E; x+; 18° 51´ 33.31399"
  private static final float latMax = 51.05570479f; // N; y-; 51º 03′ 20,53724″
  private static final float latMin = 48.5518078f; // S; y+; 48º 33′ 06,50807″
  
  private float mapWidth = Float.NaN;
  private float mapHeight = Float.NaN;
  
  private PShape shape = null;
  public Table okresy = null;
  private Set<Okres> okresySet = null;
  
  private PGraphics pgBuffer = null;
  
  public MapOkresy() {
    loadFileShape();
    loadOkresy();
    okresySet = new HashSet<Okres>();
    PShape okresyShape = getOkresyShape();
    for (TableRow okresRow : okresy.rows()) {
      Okres okres = new Okres(okresRow, okresyShape);
      okresySet.add(okres);
    }
  }
  
  public PShape getOkresyShape() {
    PShape okresyShape = shape.getChild("LandUse").getChild("okresy");
    return okresyShape;
  }
  
  public void draw(PGraphics pg, boolean redraw) {
    if (pgBuffer == null || redraw) {
      drawBuffer();
    }
    //pg.shape(shape);
    pg.image(pgBuffer, 0, 0);
  }
  
  private void drawBuffer() {
    pgBuffer = createGraphics((int) mapWidth, (int) mapHeight);
    pgBuffer.beginDraw();
    pgBuffer.translate(-188.42308, -3.9615385);
    //transform="translate(-188.42308,-3.9615385)"
    for (Okres okres : okresySet) {
      okres.draw(pgBuffer);
    }
    pgBuffer.endDraw();
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
  
  private boolean loadOkresy() {
    okresy = null;
    boolean loaded = true;
    try {
      okresy = loadTable(okresyFilename, "header");
    } catch (NullPointerException e) {
      loaded = false;
    }
    if (!loaded) {
      loadFileXml();
    }
    return loaded;
  }
  
  private void loadFileShape() {
    shape = loadShape(filename);
    shape.disableStyle();
    mapWidth = shape.width;
    mapHeight = shape.height;
  }
  
  private boolean loadFileXml() {
    println("Loading okresy XML");
    initOkresy();
    XML root = loadXML(filename);
    if (root == null) {
      return false;
    }
    for (XML landUseG : root.getChildren("g")) {
      if (landUseG.getString("id").equals("LandUse")) {
        for (XML okresyG : landUseG.getChildren("g")) {
          if (okresyG.getString("id").equals("okresy")) {
            for (XML okresPath : okresyG.getChildren("path")) {
              String id = okresPath.getString("id");
              TableRow tr = okresy.addRow();
              tr.setString("id", id);
            }
            break; // No other element can have the same id
          }
        }
        break; // No other element can have the same id
      }
    }
    saveTable(okresy, okresyFilename, "csv");
    return true;
  }
  
  private void initOkresy() {
    okresy = new Table();
    okresy.addColumn("id");
  }
}

