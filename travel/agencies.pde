import java.util.Set;
import java.util.HashSet;

import java.net.URI;
import java.net.URISyntaxException;

// http://jsoup.org/
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.jsoup.nodes.Element;

class Agencies {
  private static final String dataFilename = "ackcr.htm";
  private static final String processedFilename = "processed/agencies.csv";
  
  private static final float pointSize = 10.0f;
  
  private Table agencies = null;
  private Set<Agency> agenciesSet = null;
  private Agency selectedAgency = null;
  
  public Agencies(MapOkresy map) {
    loadAgencies(map);
    //agenciesSet.add(new Agency(50.251944, 12.091389, map));
    //agenciesSet.add(new Agency(49.550278, 18.858889, map));
    //agenciesSet.add(new Agency(51.055556, 14.316111, map));
    //agenciesSet.add(new Agency(48.5525, 14.333056, map));
  }
  
  public void draw(PGraphics pg) {
    pg.pushMatrix();
    pg.ellipseMode(CENTER);
    for (Agency agency : agenciesSet) {
      agency.draw(pg);
    }
    pg.popMatrix();
  }
  
  public void updateMouse(float x, float y) {
    float bestDist = Float.POSITIVE_INFINITY;
    Agency bestAgency = null;
    for (Agency agency : agenciesSet) {
      float dist = agency.pointDist(x, y);
      if (dist < bestDist) {
        bestDist = dist;
        bestAgency = agency;
      }
    }
    if (selectedAgency != bestAgency) {
      redraw = true;
    }
    if (selectedAgency != null) {
      selectedAgency.setSelected(false);
    }
    if (bestAgency != null) {
      bestAgency.setSelected(true);
      selectedAgency = bestAgency;
    }
  }
  
  private void loadAgencies(MapOkresy map) {
    boolean loaded = loadAgenciesProcessed();
    if (!loaded) {
      loaded = loadAgenciesData();
    }
    if (loaded) {
      agenciesSet = new HashSet<Agency>();
      for (TableRow agencyRow : agencies.rows()) {
        Agency agency = new Agency(agencyRow, map);
        agenciesSet.add(agency);
      }
    }
  }
  
  private boolean loadAgenciesProcessed() {
    boolean loaded = true;
    agencies = null;
    try {
      agencies = loadTable(processedFilename, "header");
    } catch (NullPointerException e) {
      loaded = false;
    }
    return loaded;
  }
  
  private boolean loadAgenciesData() {
    println("Loading agencies from HTM file");
    String dataFilenameAbsolute = dataPath(dataFilename);
    File input = new File(dataFilenameAbsolute);
    Document doc = null;
    try {
      doc = Jsoup.parse(input, "UTF-8", "http://www.ackcr.cz/clenove-2");
    } catch (IOException e) {
      println("IOException");
    }
    if (doc == null) {
      return false;
    }
    loadDoc(doc);
    saveTable(agencies, processedFilename, "csv");
    return true;
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
    initAgencies();
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

