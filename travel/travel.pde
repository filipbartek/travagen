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

final int w = 800;
final int h = 600;

Map map = null;
Agencies agencies = null;
Suicides suicides = null;

PGraphics pg = null;
boolean pgRedraw = false;

void setup() {
  size(w, h);
  noFill();
  noStroke();
  
  pg = createGraphics(width, height);
  pgRedraw = true;
  
  map = new Map();
  agencies = new Agencies(map);
  suicides = new Suicides(this);
  
  //noLoop();
}

void draw() {
  if (pgRedraw) {
    pg.beginDraw();
    //pg.scale(0.5);
    map.draw(pg);
    float mapWidth = map.getWidth();
    float mapHeight = map.getHeight();
    mapWidth *= 0.95;
    mapHeight *= 0.95;
    println(mapWidth);
    println(mapHeight);
    agencies.draw(pg, mapWidth, mapHeight);
    pg.endDraw();
    pgRedraw = false;
  }
  image(pg, 0, 0);
  stroke(255, 255, 255);
  line(0, mouseY, width, mouseY);
  noStroke();
}

void mouseMoved() {
  // TODO: Add interaction.
  //map.updateSelected();
  //pgRedraw = true;
  //print(".");
}

void mouseClicked() {
  println(mouseX);
  println(mouseY);
}

