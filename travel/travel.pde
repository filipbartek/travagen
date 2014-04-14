// Are there more travel agencies in ugly or sad cities?
// Is there a correlation between number of travel agencies and attractiveness of the area?

// Dimensions:
// location
// incoming tourists
// number of travel agencies
// number of suicides

// Data required:
// by okres:
//   position
//   number of citizens (to normalize the following)
//   number of travel agencies
//   number of incoming tourists

final int w = 1024;
final int h = 600;

MapOkresy map = null;
Agencies agencies = null;
Suicides suicides = null;
Okresy okresy = null;
Guests guests = null;

PGraphics pg = null;
boolean pgRedraw = false;

void setup() {
  size(w, h);
  noFill();
  noStroke();
  
  pg = createGraphics(width, height);
  pgRedraw = true;
  
  map = new MapOkresy();
  agencies = new Agencies(map);
  suicides = new Suicides(this);
  guests = new Guests(this);
  okresy = new Okresy(map, suicides, guests);
}

void draw() {
  if (pgRedraw) {
    pg.beginDraw();
    okresy.draw(pg, false);
    agencies.draw(pg);
    pg.endDraw();
    pgRedraw = false;
  }
  image(pg, 0, 0);
}

void mouseMoved() {
  //agencies.updateMouse(mouseX, mouseY);
  //pgRedraw = true;
}

