class Agency {
  private String name = null;
  private String url = null;
  private String address = null;
  private float lat = Float.NaN; // latitude
  private float lng = Float.NaN; // longitude
  private float x = Float.NaN;
  private float y = Float.NaN;
  
  private static final float pointSize = 10.0f;
  
  public Agency(float lat, float lng, Map map) {
    this.lat = lat;
    this.lng = lng;
    initXY(map);
  }
  
  private void initXY(Map map) {
    float lngMin = map.getLngMin();
    float lngMax = map.getLngMax();
    float latMin = map.getLatMin();
    float latMax = map.getLatMax();
    float mapWidth = map.getMapWidth();
    float mapHeight = map.getMapHeight();
    this.x = map(lng, lngMin, lngMax, 0, mapWidth);
    this.y = map(lat, latMax, latMin, 0, mapHeight);
  }
  
  public Agency(String name, String url, String address, float lat, float lng, Map map) {
    this(lat, lng, map);
    this.name = name;
    this.url = url;
    this.address = address;
  }
  
  public Agency(TableRow tr, Map map) {
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
  
  public void draw(PGraphics pg) {
    pg.ellipse(x, y, pointSize, pointSize);
  }
}

