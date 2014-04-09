import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.jsoup.nodes.Element;
// http://jsoup.org/

import java.util.regex.Pattern;
import java.util.regex.Matcher;

final String file_ackcr = "ackcr.htm";

final String[] addrPatStrs = {
"(?U)\\A(?:P\\.O\\.BOX \\d+, )?(?<street>[\\w. ]*\\w\\.?) (?<number>\\w[\\w/]*)(?:,[\\w ]+)?, (?<zip>\\d{3} ?\\d{2}) (?<city>[\\w- ]+)(?:, (?<county>[\\w- ]+))?\\Z",
"(?U)\\A(?:P\\.O\\.BOX \\d+, )?(?<street>[\\w. ]*\\w)\\.(?<number>\\w[\\w/]*)(?:,[\\w ]+)?, (?<zip>\\d{3} ?\\d{2}) (?<city>[\\w- ]+)(?:, (?<county>[\\w- ]+))?\\Z",
"(?U)\\A(?:P\\.O\\.BOX \\d+, )?(?<street>[\\w. ]*\\w\\.?) (?<number>\\w[\\w/]*)(?:,[\\w ]+)?, (?<city>[\\w- ]+) (?<zip>\\d{3} ?\\d{2})(?:, (?<county>[\\w- ]+))?\\Z"
};
Pattern[] addrPats;
// http://docs.oracle.com/javase/tutorial/essential/regex/index.html

void initPats() {
  int n = addrPatStrs.length;
  addrPats = new Pattern[n];
  for (int i = 0; i < n; i++) {
    String addrPatStr = addrPatStrs[i];
    addrPats[i] = Pattern.compile(addrPatStr);
  }
}

void processUrl(String url, TableRow tr) {
  String urlFixed = url.substring(20); // Remove archive.org prefix
  tr.setString("url", urlFixed);
}

void processNameElem(Element elem, TableRow tr) {
  String name = elem.text();
  tr.setString("name", name);
  String url = elem.attr("href");
  processUrl(url, tr);
}

boolean processAddressString(String s, TableRow tr) {
  tr.setString("address", s);
  for (Pattern addrPat : addrPats) {
    Matcher matcher = addrPat.matcher(s);
    if (matcher.find()) {
      tr.setString("street", matcher.group("street"));
      tr.setString("number", matcher.group("number"));
      tr.setString("zip", matcher.group("zip"));
      tr.setString("city", matcher.group("city"));
      return true;
    }
  }
  println(s);
  return false;
}

boolean processAddressElem(Element elem, TableRow tr) {
  String address = elem.text();
  return processAddressString(address, tr);
}

boolean processMemberElem(Element memberElem, TableRow tr) {
  Element nameElem = memberElem.select("h3 > a").first();
  processNameElem(nameElem, tr);
  Element addressElem = memberElem.select("div.adresa").first();
  return processAddressElem(addressElem, tr);
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
  int mismatches = 0;
  for (Element memberElem : memberElems) {
    boolean res = processMemberElem(memberElem, addresses.addRow());
    if (!res) {
      mismatches++;
    }
  }
  if (mismatches > 0) {
    println("mismatches: " + mismatches);
  }
  
  return addresses;
}

