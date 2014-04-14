class Agency {
  private String name = null;
  private String url = null;
  private String address = null;
  private float lat = Float.NaN; // latitude
  private float lng = Float.NaN; // longitude
  
  private float x = Float.NaN;
  private float y = Float.NaN;
  private boolean selected = false;
  
  private static final float pointSize = 10.0f;
  
  public Agency(float lat, float lng, MapOkresy map) {
    this.lat = lat;
    this.lng = lng;
    initXY(map);
  }
  
  public float pointDist(float pointX, float pointY) {
    return dist(pointX, pointY, x, y);
  }
  
  public void setSelected(boolean selected) {
    this.selected = selected;
  }
  
  private void initXY(MapOkresy map) {
    float lngMin = map.getLngMin();
    float lngMax = map.getLngMax();
    float latMin = map.getLatMin();
    float latMax = map.getLatMax();
    float mapWidth = map.getMapWidth();
    float mapHeight = map.getMapHeight();
    this.x = map(lng, lngMin, lngMax, 0, mapWidth);
    this.y = map(lat, latMax, latMin, 0, mapHeight);
  }
  
  public Agency(String name, String url, String address, float lat, float lng, MapOkresy map) {
    this(lat, lng, map);
    this.name = name;
    this.url = url;
    this.address = address;
  }
  
  public Agency(TableRow tr, MapOkresy map) {
    this.name = tr.getString("name");
    this.url = tr.getString("url");
    this.address = tr.getString("address");
    this.lat = tr.getFloat("latitude");
    this.lng = tr.getFloat("longitude");
    initXY(map);
  }
  
  public float getLat() {
    return lat;
  }
  
  public float getLng() {
    return lng;
  }
  
  private final color cFillSelected = color(0, 255, 255);
  private final color cFillNotSelected = color(0, 0, 255);
  
  public void draw(PGraphics pg) {
    color cFill;
    if (selected) {
      cFill = cFillSelected;
    } else {
      cFill = cFillNotSelected;
    }
    pg.fill(cFill);
    pg.ellipse(x, y, pointSize, pointSize);
    pg.noFill();
  }
}

