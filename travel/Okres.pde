class Okres {
  private String id = null;
  private PShape shape = null;
  private int suicides2010 = -1;
  private int guests2010 = -1;
  
  private color cFill = color(255, 255, 255);
  private final color cFillNan = color(0, 0, 255);
  
  public Okres(TableRow tr, PShape okresyShape) {
    this.id = tr.getString("id");
    this.shape = okresyShape.getChild(id);
  }
  
  public Okres(TableRow mapTr, PShape okresyShape, TableRow suicidesTr, TableRow guestsTr) {
    this(mapTr, okresyShape);
    if (suicidesTr != null) {
      this.suicides2010 = suicidesTr.getInt("suicides_2010");
    }
    if (guestsTr != null) {
      this.guests2010 = guestsTr.getInt("guests2010");
    }
  }
  
  public void draw(PGraphics pg) {
    pg.fill(cFill);
    pg.shape(shape);
    pg.noFill();
  }
  
  public int getSuicides2010() {
    return suicides2010;
  }
  
  public int getGuests2010() {
    return guests2010;
  }
  
  public void updateCFill() {
    if (guests2010 == -1) {
      cFill = cFillNan;
    } else {
      int valueSuicides = (int) map(log(suicides2010), 0, log(maxSuicides2010), 0, 255);
      int valueGuests = (int) map(log(guests2010), 0, log(maxGuests2010), 0, 255);
      cFill = color(valueSuicides, valueGuests, 0);
    }
  }
  
  public String getId() {
    return id;
  }
}

