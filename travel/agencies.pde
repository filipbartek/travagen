import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.jsoup.nodes.Element;
// http://jsoup.org/

import java.util.regex.Pattern;
import java.util.regex.Matcher;

final String file_ackcr = "ackcr.htm";
//final String file_ackcr = "C:\\Users\\TTT\\Documents\\GitHub\\travagen\\travel\\data\\ackcr.htm";
//final String file_ackcr = "ackcr_nodia.htm";

final String addrPatStr =
//"((?<street1>[\\w ]*?) )|(?<street2>[\\w ]*?\\.)(?<number>[\\w/]+?), [(\\d{3} ??\\d{2} [\\w ]*)([\\w ]* \\d{3} ??\\d{2})]";
"(?U)\\A(?:P.O.BOX \\d+)?(?<street>[\\w. ]*[\\w.]) (?<number>[\\w/]+), (?<zip>\\d{3} \\d{2}) (?<city>[\\w- ]*)(?:, (?<county>[\\w- ]*))?\\Z";
// TODO: Refine pattern so that it matches Usti nad Orlici ...
// http://docs.oracle.com/javase/tutorial/essential/regex/index.html
Pattern addrPat;

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
  } else {
    tr.setString("street", matcher.group("street"));
    tr.setString("number", matcher.group("number"));
    tr.setString("zip", matcher.group("zip"));
    tr.setString("city", matcher.group("city"));
  }
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
  addresses.addColumn("number");
  addresses.addColumn("zip");
  addresses.addColumn("city");
  
  Elements memberElems = doc.select("div.clen");
  for (Element memberElem : memberElems) {
    processMemberElem(memberElem, addresses.addRow());
  }
  
  return addresses;
}

