class Agencies {
  private static final String dataFilename = "ackcr.htm";
  private static final String processedFilename = "processed/agencies.csv";
  
  private static final float pointSize = 10.0f;
  private static final float longitudeMin = 12.09081161f; // W; x-; 12º 05′ 26,92179″
  private static final float longitudeMax = 18.85925389f; // E; x+; 18° 51´ 33.31399"
  private static final float latitudeMax = 51.05570479f; // N; y-; 51º 03′ 20,53724″
  private static final float latitudeMin = 48.5518078f; // S; y+; 48º 33′ 06,50807″

  Table agencies = null;
  
  public Agencies() {
    loadAgencies();
  }
  
  public void draw(PGraphics pg, float mapWidth, float mapHeight) {
    pg.pushMatrix();
    color cFill = color(0, 0, 0);
    pg.fill(cFill);
    pg.ellipseMode(CENTER);
    for (TableRow agency : agencies.rows()) {
      drawAgency(pg, agency, mapWidth, mapHeight);
    }
    drawPoint(pg, 50.251944, 12.091389, mapWidth, mapHeight);
    drawPoint(pg, 49.550278, 18.858889, mapWidth, mapHeight);
    drawPoint(pg, 51.055556, 14.316111, mapWidth, mapHeight);
    drawPoint(pg, 48.5525, 14.333056, mapWidth, mapHeight);
    pg.noFill();
    pg.popMatrix();
  }
  
  private void drawAgency(PGraphics pg, TableRow agency, float mapWidth, float mapHeight) {
    float latitude = agency.getFloat("latitude");
    float longitude = agency.getFloat("longitude");
    drawPoint(pg, latitude, longitude, mapWidth, mapHeight);
    //drawPoint(pg, latitudeMin, longitude, mapWidth, mapHeight);
    //drawPoint(pg, latitudeMax, longitude, mapWidth, mapHeight);
    //drawPoint(pg, latitude, longitudeMin, mapWidth, mapHeight);
    //drawPoint(pg, latitude, longitudeMax, mapWidth, mapHeight);
    
  }
  
  private void drawPoint(PGraphics pg, float latitude, float longitude, float mapWidth, float mapHeight) {
    float x = map(longitude, longitudeMin, longitudeMax, 0, mapWidth);
    float y = map(latitude, latitudeMax, latitudeMin, 0, mapHeight);
    pg.ellipse(x, y, pointSize, pointSize);
  }
  
  private void loadAgencies() {
    loadAgenciesProcessed();
    if (agencies == null) {
      println("Loading agencies from HTM file");
      loadAgenciesData();
      saveTable(agencies, processedFilename, "csv");
    }
  }
  
  private void loadAgenciesProcessed() {
    agencies = null;
    try {
      agencies = loadTable(processedFilename, "header");
    } catch (NullPointerException e) {
    }
  }
  
  private void loadAgenciesData() {
    initAgencies();
    String dataFilenameAbsolute = dataPath(dataFilename);
    File input = new File(dataFilenameAbsolute);
    Document doc = null;
    try {
      doc = Jsoup.parse(input, "UTF-8", "http://www.ackcr.cz/clenove-2");
    } catch (IOException e) {
      println("IOException");
    }
    if (doc == null) {
      return;
    }
    loadDoc(doc);
  }
  
  private void initAgencies() {
    agencies = new Table();
    agencies.addColumn("name", Table.STRING);
    agencies.addColumn("url", Table.STRING);
    agencies.addColumn("address", Table.STRING);
    agencies.addColumn("latitude", Table.FLOAT);
    agencies.addColumn("longitude", Table.FLOAT);
  }
  
  private void loadDoc(Document doc) {
    Elements memberElems = doc.select("div.clen");
    for (Element memberElem : memberElems) {
      processMemberElem(memberElem, agencies.addRow());
    }
  }
  
  private void processMemberElem(Element memberElem, TableRow tr) {
    Element nameElem = memberElem.select("h3 > a").first();
    processNameElem(nameElem, tr);
    Element addressElem = memberElem.select("div.adresa").first();
    processAddressElem(addressElem, tr);
  }
  
  private void processNameElem(Element elem, TableRow tr) {
    String name = elem.text();
    tr.setString("name", name);
    String url = elem.attr("href");
    processUrl(url, tr);
  }
  
  private void processUrl(String url, TableRow tr) {
    String urlFixed = url.substring(20); // Remove archive.org prefix
    tr.setString("url", urlFixed);
  }
  
  private void processAddressElem(Element elem, TableRow tr) {
    String address = elem.text();
    processAddressString(address, tr);
  }
  
  private void processAddressString(String s, TableRow tr) {
    tr.setString("address", s);
    addCoordinates(s, tr);
  }
  
  private void addCoordinates(String address, TableRow tr) {
    String queryConstant = "sensor=false&language=en&region=cz";
    String queryAddress = "address=\"" + address + "\"";
    String query = queryAddress + "&" + queryConstant;
    URI uri = null;
    try {
      uri = new URI("http", "maps.googleapis.com", "/maps/api/geocode/xml", query, null);
    } catch (URISyntaxException e) {
      println("URISyntaxException");
    }
    if (uri != null) {
      String url = uri.toASCIIString();
      println("Loading coordinates for address " + address + "...");
      XML xml = loadXML(url);
      addCoordinatesXML(xml, tr);
      delay(100);
    }
  }
  
  private void addCoordinatesXML(XML xml, TableRow tr) {
    XML statusXML = xml.getChild("status");
    String statusString = statusXML.getContent();
    if ("OK".equals(statusString)) {
      XML result = xml.getChild("result");
      XML geometry = result.getChild("geometry");
      XML location = geometry.getChild("location");
      XML lat = location.getChild("lat");
      XML lng = location.getChild("lng");
      float latitude = lat.getFloatContent();
      float longitude = lng.getFloatContent();
      tr.setFloat("latitude", latitude);
      tr.setFloat("longitude", longitude);
    } else {
      println("Error: Coordinates not loaded. Status string: " + statusString);
    }
  }
}

