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

final int w = 640;
final int h = 480;

void setup() {
  size(w, h);
  
  //Table suicides = loadSuicides();
  //saveTable(suicides, "suicides.csv");
  
  initPats();
  Table agencies = loadAgencies();
  saveTable(agencies, "agencies.csv");
  
  noLoop();
}

