class Position {
  
  protected int x;
  protected int y;
   
  public Position( int xC, int yC ){
    x = xC;
    y = yC;
  }
  
  public Position(){
    x = 0;
    y = 0;
  }
  
  public void move( int x_inc, int y_inc ){
    x += x_inc;
    y += y_inc;
  }
  
  public void moveto( int x_inc, int y_inc ){
    x = x_inc;
    y = y_inc;
  }
  
  public int x() { return x; }
  public int y() { return y; }
  
}
