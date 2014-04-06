// Are there more travel agencies in ugly or sad cities?
// Is there a correlation between number of travel agencies and attractiveness of the area?

// Dimensions:
// location
// incoming tourists
// number of travel agencies
// number of suicides

// Sources:

// 401211p10.xls
// suicides in by okres and year
// http://www.czso.cz/csu/2011edicniplan.nsf/kapitola/4012-11-n_2011-16

// tabulka_CRU901PU_OK.xls
// incoming tourists in 2010 by okres
// http://vdb.czso.cz/vdbvo/tabdetail.jsp?childsel0=1&cislotab=CRU9010PU_OK&kapitola_id=654&cas_1_98=2010&

// ackcr.html
// travel agencies by 2010-11-11 with addresses
// https://web.archive.org/web/20101111104352/http://www.ackcr.cz/clenove-2

// tabulka_OBY5012PU_OK.xls
// population by 2010-07-01 by okres
// http://vdb.czso.cz/vdbvo/tabdetail.jsp?kapitola_id=572&potvrd=Zobrazit+tabulku&go_zobraz=1&cislotab=OBY5012PU_OK&cas_1_96=20100701&vo=tabulka&voa=tabulka&str=tabdetail.jsp

// CR-okresy-a-kraje-2007.svg
// map of Czech Republic with borders between okreses
// http://upload.wikimedia.org/wikipedia/commons/1/15/CR-okresy-a-kraje-2007.svg

// Districts_of_Czech_Republic_vector_line_model.svg
// map of Czech Republic by districts annotated with names
// http://upload.wikimedia.org/wikipedia/commons/d/de/Districts_of_Czech_Republic_vector_line_model.svg

// map_cr_okres_highpolygon.svg
// map of Czech Republic by districts annotated highpoly
// http://www.icnet.eu/cs/products/icnet/controls/map/

// http://upload.wikimedia.org/wikipedia/commons/3/30/CR-okresy-general-Model.svg
// http://upload.wikimedia.org/wikipedia/commons/4/45/Czech_parliament_elections_2010_-_districts%2C_turnout.svg

// Data required:
// by okres:
//   position
//   number of citizens (to normalize the following)
//   number of travel agencies
//   number of incoming tourists

import de.bezier.data.XlsReader;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.jsoup.nodes.Element;
// http://jsoup.org/

import java.util.regex.Pattern;
import java.util.regex.Matcher;

final int w = 640;
final int h = 480;

//final String file_ackcr = "C:\\Users\\TTT\\Documents\\GitHub\\travagen\\travel\\data\\ackcr.htm";
//final String file_ackcr = "ackcr_nodia.htm";
final String file_ackcr = "ackcr.htm";
final String file_suicides = "401211p10.xls";

final String addrPatStr = "[\\w ]*?[ \\.][\\w/]+?, [(\\d{3} ??\\d{2} [\\w ]*)([\\w ]* \\d{3} ??\\d{2})]";
// TODO: Refine pattern so that it matches Usti nad Orlici ...
// http://docs.oracle.com/javase/tutorial/essential/regex/index.html
Pattern addrPat;

// Columns:
// okres_name
// suicides_2010
Table
loadSuicides() {
  XlsReader reader;
  println(dataPath(""));
  reader = new XlsReader(this, file_suicides);
  
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

void processUrl(String url, TableRow tr) {
  String urlFixed = url.substring(20);
  tr.setString("url", urlFixed);
}

void processNameElem(Element elem, TableRow tr) {
  String name = elem.text();
  tr.setString("name", name);
  String url = elem.attr("href");
  processUrl(url, tr);
}

void processAddressString(String s, TableRow tr) {
  tr.setString("address", s);
  Matcher matcher = addrPat.matcher(s);
  if (!matcher.find()) {
    println(s);
  }
  //String[] parts = split(s, ',');
  //assert parts.length >= 2;
  //String[] cityParts = split(parts[1], ' ');
  //println(cityParts);
}

void processAddressElem(Element elem, TableRow tr) {
  String address = elem.text();
  processAddressString(address, tr);
}

void processMemberElem(Element memberElem, TableRow tr) {
  Element nameElem = memberElem.select("h3 > a").first();
  processNameElem(nameElem, tr);
  Element addressElem = memberElem.select("div.adresa").first();
  processAddressElem(addressElem, tr);
}

Table loadAgencies() {
  String fileName = dataPath(file_ackcr);
  File input = new File(fileName);
  Document doc = null;
  try {
    doc = Jsoup.parse(input, "UTF-8", "http://www.ackcr.cz/clenove-2");
  } catch (IOException e) {
    println("IOException");
  }
  
  Table addresses;
  addresses = new Table();
  addresses.addColumn("name");
  addresses.addColumn("url");
  addresses.addColumn("address");
  addresses.addColumn("street");
  addresses.addColumn("zip");
  addresses.addColumn("city");
  
  Elements memberElems = doc.select("div.clen");
  for (Element memberElem : memberElems) {
    processMemberElem(memberElem, addresses.addRow());
  }
  
  return addresses;
}

void setup() {
  size(w, h);
  
  //Table suicides = loadSuicides();
  
  addrPat = Pattern.compile(addrPatStr);
  
  Table agencies = loadAgencies();
  saveTable(agencies, "agencies.csv");
  
  noLoop();
}

void draw() {
}

