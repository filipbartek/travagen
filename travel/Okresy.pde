import java.util.Map;

static int maxSuicides2010 = 0;
static int maxGuests2010 = 0;

class Okresy {
  private Map<String, Okres> okresy = null;
  private PGraphics pgBuffer = null;
  private float mapWidth = 0;
  private float mapHeight = 0;
  
  public Okresy(MapOkresy map, Suicides suicides, Guests guests) {
    okresy = new HashMap<String, Okres>();
    Table mapTable = map.okresy;
    PShape mapOkresyShape = map.getOkresyShape();
    Table suicidesTable = suicides.suicides;
    Table guestsTable = guests.guests;
    maxSuicides2010 = 0;
    maxGuests2010 = 0;
    for (TableRow mapTr : mapTable.rows()) {
      String id = mapTr.getString("id");
      TableRow suicidesTr = suicidesTable.findRow(id, "okresNameNormal");
      TableRow guestsTr = guestsTable.findRow(id, "okresId");
      Okres okres = new Okres(mapTr, mapOkresyShape, suicidesTr, guestsTr);
      int suicides2010 = okres.getSuicides2010();
      maxSuicides2010 = max(maxSuicides2010, suicides2010);
      int guests2010 = okres.getGuests2010();
      maxGuests2010 = max(maxGuests2010, guests2010);
      okresy.put(id, okres);
    }
    for (Okres okres : okresy.values()) {
      okres.updateCFill();
    }
    mapWidth = map.getMapWidth();
    mapHeight = map.getMapHeight();
  }
  
  public void draw(PGraphics pg, boolean redraw) {
    if (pgBuffer == null || redraw) {
      drawBuffer();
    }
    pg.image(pgBuffer, 0, 0);
  }
  
  private void drawBuffer() {
    pgBuffer = createGraphics((int) mapWidth, (int) mapHeight);
    pgBuffer.beginDraw();
    pgBuffer.translate(-188.42308, -3.9615385);
    //transform="translate(-188.42308,-3.9615385)"
    // Draw "brno" last because it lies completely inside "brno-venkov"
    for (Okres okres : okresy.values()) {
      if (!okres.getId().equals("brno")) {
        okres.draw(pgBuffer);
      }
    }
    Okres okresBrno = okresy.get("brno");
    okresBrno.draw(pgBuffer);
    pgBuffer.endDraw();
  }
}

