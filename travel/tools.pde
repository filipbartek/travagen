import java.text.Normalizer;

String normString(String s) {
  String result = stripAccents(s);
  result = result.toLowerCase();
  result = result.replace(' ', '_');
  return result;
}

// http://stackoverflow.com/a/15190787
String stripAccents(String s)  {
  String result = Normalizer.normalize(s, Normalizer.Form.NFD);
  result = result.replaceAll("[\\p{InCombiningDiacriticalMarks}]", "");
  return result;
}

