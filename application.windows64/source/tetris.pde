// Generic function for ease of modular arithmetic
int modulo( int num, int divisor ){
  if( num >= divisor ){ 
    while( num >= divisor ){ 
      num -= divisor; 
    } 
  }
  if( num < 0 ){
    while( num < 0 ){
      num += divisor;
    }
  }
  return num;
}

//*******************************//

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

//*******************************//

class Square extends Position {
  
  private float sizeX;
  private float sizeY;
  private boolean isClicked;
  private boolean clickable;
  private int screenLayer;
  private Position offset;
  private color Color;
  
  Square( int xC, int yC, float widthC, float heightC ){
    super( xC, yC );
    sizeX = widthC;
    sizeY = heightC;
    Color = color(0,0,0);
    
    isClicked = false;
    clickable = false;
    screenLayer = 0;
    offset = new Position(0,0);
  }
  
  public void display() {
    fill( Color );
    rect( x, y, sizeX, sizeY );
  }
  
  public float sizeX() { return sizeX; }
  public float sizeY() { return sizeY; }
  public Position offset() { return offset; }
  public boolean isClicked() { return isClicked; }
  public void setLayer( int layer ) { screenLayer = layer; }
  public void setColor( color newColor ) { Color = newColor; }
  
  // Change whether or not we can click on the object
  public void clickable( boolean tf ){
    clickable = tf;
  }
  
  // Check if the flag should be raised or lowered on click
  public boolean clicked() { 
    if( mousePressed == true && mouseX > x && mouseX < x + sizeX && mouseY > y && mouseY < y + sizeY ){
      return true;
    }
    else { 
      return false;
    } 
  }
  
  // When mouse is clicked inside of image, raise flag that does not lower until mouse is unclicked (anywhere)
  // Follow while flag is raised
  public void followMouse() {
    
    if( !clickable ){ return; }
    
    if( isClicked == false && clicked() ){
      offset = new Position( mouseX - x, mouseY - y );
    }
    if( mousePressed == true && clicked() ){
      isClicked = true;
      print( "true " );
    }
    if( isClicked ){
      print( "true    " );
      move( mouseX - x - offset.x , mouseY - y - offset.y );
    }
    if( mousePressed == false ){
      isClicked = false;
      print( "false " );
    } 
  }
  
  
}

//*******************************//

class Shape extends Position {
  private int pieces;
  private int rotation;
  
  public Shape( int numPieces ){
    pieces = numPieces;
    rotation = 0;
  }
  
  // Rotation is intended to be one of four values, since a square only has four sides
  public void setRotation( int rotato ){
    if( rotato <= 3 && rotato >= 0 ){
      rotation = rotato;
    }
    else {
      print( "Error: invalid rotation" );
    }
  }
  
  public int getRotation(){ return rotation; }
  
  // Create a new position in a direction signified by the rotation key
  public Position newPointInDirection( Position oldPt, int direction, int dist ){
    if( direction == 0 ){
      return new Position( oldPt.x + dist, oldPt.y );
    }
    else if( direction == 1 ){
      return new Position( oldPt.x, oldPt.y + dist );
    }
    else if( direction == 2 ){
      return new Position( oldPt.x - dist, oldPt.y );
    }
    else if( direction == 3 ){
      return new Position( oldPt.x, oldPt.y - dist );
    }
    else return oldPt;
  }
  
  // Create a set of points given 3 rotation keys, generating from the original point toward a final point
  public ArrayList<Position> generateTetromino (int dir1, int dir2, int dir3){
    
    ArrayList<Position> points = new ArrayList<Position>(0);

    points.add(new Position( x, y ));  
    points.add( newPointInDirection( points.get(0), modulo( dir1 + rotation, 4 ), 50 ) ); 
    points.add( newPointInDirection( points.get(1), modulo( dir2 + rotation, 4 ), 50 ) );
    points.add( newPointInDirection( points.get(2), modulo( dir3 + rotation, 4 ), 50 ) );   
    
    return points;
  }
  
  // T-Tetrominos are unique, in that we generate from the center
  public ArrayList<Position> generateTTetromino (){
    
    ArrayList<Position> points = new ArrayList<Position>(0);

    points.add(new Position( x, y ));  
    points.add( newPointInDirection( points.get(0), modulo( rotation, 4 ), 50 ) ); 
    points.add( newPointInDirection( points.get(0), modulo( 1 + rotation, 4 ), 50 ) );
    points.add( newPointInDirection( points.get(0), modulo( 2 + rotation, 4 ), 50 ) );   
    
    return points;
  }
   
}

//*******************************//

class Block extends Position {
 
  public ArrayList<Square> pieces;
  public Shape blockshape;
  public Position offset;
  private int DNA;
  private boolean touched;
  
  // Constructor for random block
  public Block( int theSize, Position pos ){
    pieces = new ArrayList<Square>(theSize);
    blockshape = new Shape(theSize);
    ArrayList<Position> spaces = new ArrayList<Position>(0);
    DNA = int(random(0,7));
    touched = false;
    x = pos.x;
    y = pos.y;
    offset = new Position(x,y);

    update();
  }
  
  // Constructor for given DNA code
  public Block( int theSize, Position pos, int theDNA ){
    pieces = new ArrayList<Square>(theSize);
    blockshape = new Shape(theSize);
    ArrayList<Position> spaces = new ArrayList<Position>(0);
    DNA = theDNA;
    touched = false;
    x = pos.x;
    y = pos.y;
    offset = new Position(x,y);

    update();
  }
  
  // Copy constructor
  public Block( Block other ){
    this.pieces = other.pieces;
    this.blockshape = other.blockshape;
    this.offset = other.offset;
    this.touched = other.touched;
    this.x = other.x;
    this.y = other.y;
    this.update();
  }
  
  // Update the Shape of the object, in the event that rotation occurs and on construction
  public void update(){
    
    blockshape.x = x;
    blockshape.y = y;
    
    pieces = new ArrayList<Square>(0);
    ArrayList<Position> spaces = new ArrayList<Position>(0);
    color Color = color(0,0,0);
    
    if( DNA == 0 ){ spaces = blockshape.generateTetromino(0,1,2); Color = color( 180, 200, 10 ); }
    else if( DNA == 1 ){ spaces = blockshape.generateTetromino(0,3,0); Color = color(160, 50, 0); }
    else if( DNA == 2 ){ spaces = blockshape.generateTetromino(0,1,0); Color = color(0, 150, 50 ); }
    else if( DNA == 3 ){ spaces = blockshape.generateTetromino(1,0,0); Color = color(0, 50, 150); }
    else if( DNA == 4 ){ spaces = blockshape.generateTetromino(3,0,0); Color = color(160, 80, 60); }
    else if( DNA == 5 ){ spaces = blockshape.generateTetromino(0,0,0); Color = color(80, 100, 160);}
    else if( DNA == 6 ){ spaces = blockshape.generateTTetromino(); Color = color(50, 100, 50);}
    
    for( Position posi : spaces ){
      Square newSquare = new Square( posi.x, posi.y, 50, 50 );
      newSquare.clickable(true);
      newSquare.setColor( Color );
      pieces.add( newSquare );
    }
    
  }
  
  // Change the Shape of the object
  public void mutate( int newCode ){
    DNA = newCode;
  }
  
  // Access the Shape information
  public int getDNA(){
    return DNA;
  }
  
  // Change the "touched" state
  public void touching( boolean newState ){
    touched = newState;
  }
  
  public boolean touching(){
    return touched;
  }
  
  // Change the offset to a specific position
  public void setOffset( Position pos ){
    offset = new Position( pos.x - x, pos.y - y );
  }
  
  public void followMouse(){
    if( touched == true ){
      x = mouseX - offset.x;
      y = mouseY - offset.y; 
    } 
  }
  
  public void smoothGrid( int xG, int yG ){
    if( touched == false ){
      x = int( lerp( x, (x/xG) * xG, .5 ) );
      y = int( lerp( y, (y/yG) * yG, .5 ) );
    }
  }
  
  public void display(){
    for( Square square : pieces ){
      square.display();
    }
  }
  
}


//*******************************//
//                               //
//      GAME FUNCTIONALITY       //
//                               //
//*******************************//

Block b = new Block( 4, new Position(200,200) );
Block newBlock = new Block( 4, new Position(650,150)) ;
ArrayList<Square> grid = new ArrayList<Square>(0);
int points = 0;

void keyPressed(){
  
  if( keyPressed && keyCode == RIGHT ){
    b.move( 50, 0 );
  }
  else if( keyPressed && keyCode == LEFT ){
    b.move( -50, 0 );
  }
  else if( keyPressed && keyCode == UP ){
    b.move( 0, -50 );
  }
  else if( keyPressed && keyCode == DOWN ){
    b.move( 0, 50 );
  }
  else if( keyPressed && keyCode == ENTER && isBlockInGrid(b, grid) == false && isBlockOnGrid(b, 50,550,50,550) == true ){
    b.update();
    for( Square square : b.pieces ){
      grid.add( square );
    }
    b.pieces.clear();
    b = newBlock;
    b.moveto(200, 200);
    int dna = int(random(0,7));
    if( dna == 0 ){ newBlock = new Block( 4, new Position(675,150), 0); }
    else if( dna == 1 ){ newBlock = new Block( 4, new Position(650,200), 1); }
    else if( dna == 2 ){ newBlock = new Block( 4, new Position(650,150), 2); }
    else if( dna == 3 ){ newBlock = new Block( 4, new Position(650,150), 3); }
    else if( dna == 4 ){ newBlock = new Block( 4, new Position(650,200), 4); }
    else if( dna == 5 ){ newBlock = new Block( 4, new Position(625,200), 5); }
    else if( dna == 6 ){ newBlock = new Block( 4, new Position(700,150), 6); }
    
  }
  else if( keyPressed && keyCode == SHIFT){
    b.blockshape.setRotation(modulo(b.blockshape.getRotation() + 1, 4));
  }
  
}

boolean clearFullRow( ArrayList<Square> grid, int row ){
  ArrayList<Square> fullRow = new ArrayList<Square>(0);
  ArrayList<Square> fullCol = new ArrayList<Square>(0);
  boolean cleared = false;
  
  for( Square square : grid ){
    if( square.y == row * 50 ){
      fullRow.add(square);
    }
  }
  
  if( fullRow.size() == 10 ){
    print( "Full row " );
    for( Square squ : fullRow ){
      grid.remove( squ );
    }
    for( int i = 1; i <= 10 ; i++ ){
      fullCol = new ArrayList<Square>(0);  
      for( Square square : grid ){
          if( square.x == i * 50 ){
            fullCol.add(square);
          }
        }
        if( fullCol.size() == 9 ){
          //print( "Full collumn " );
            for( Square squ : fullCol ){
              grid.remove( squ );
            }
        }
    }
    cleared = true;
  }
  
  for( Square square : grid ){
    if( square.x == row * 50 ){
      fullCol.add(square);
    }
  }
  
  if( fullCol.size() == 10 ){
    //print( "Full collumn " );
    for( Square squ : fullCol ){
      grid.remove( squ );
    }
    cleared = true;
  }
  
  /*
  if( cleared ){
  print( "RowSize: " + fullRow.size() + " " );
  print( "ColSize: " + fullCol.size() + "\n" );
  }
  */
  
  
  return cleared;
  
}
  
// Test if any of the squares in a block are over a square in a grid
boolean isBlockInGrid( Block block, ArrayList<Square> squares ){
  for( Square square : b.pieces ){
    for( Square gridSquare : squares ){
      if( square.x() == gridSquare.x() && square.y() == gridSquare.y() ){
        return true;
      }
    }
  }
  return false;
}

// Test if all squares in a block are on a grid
boolean isBlockOnGrid( Block block, int xLeft, int xRight, int yTop, int yBot ){
  for( Square square : b.pieces ){
    if( !(square.x() < xRight && square.x() >= xLeft && square.y() < yBot && square.y() >= yTop) ){
      return false;
    }
  }
  return true;  
  
}

// Keep a generic block on a grid by moving it if it goes outside the bounds
void keepOnGrid( Block blk, int xLeft, int xRight, int yTop, int yBot, int blockLength ){
  for( Square square : blk.pieces ){
    if( square.x() < xLeft ){ 
      b.move(blockLength,0); 
      break; 
    }
    else if( square.x() >= xRight ){ 
      b.move(-blockLength,0); 
      break; 
    }
    else if( square.y() < yTop ){ 
      b.move(0,blockLength); 
      break; 
    }
    else if( square.y() >= yBot ){ 
      b.move(0,-blockLength); 
      break; 
    }
  }
}
  
  
//*******************************//
//                               //
//      RUNTIME OPERATIONS       //
//                               //
//*******************************//


void setup(){ 
  
  // Initialize New Block to random state
  int dna = int(random(0,7));
  if( dna == 0 ){ newBlock = new Block( 4, new Position(675,150), 0); }
  else if( dna == 1 ){ newBlock = new Block( 4, new Position(650,200), 1); }
  else if( dna == 2 ){ newBlock = new Block( 4, new Position(650,150), 2); }
  else if( dna == 3 ){ newBlock = new Block( 4, new Position(650,150), 3); }
  else if( dna == 4 ){ newBlock = new Block( 4, new Position(650,200), 4); }
  else if( dna == 5 ){ newBlock = new Block( 4, new Position(625,200), 5); }
  else if( dna == 6 ){ newBlock = new Block( 4, new Position(700,150), 6); }
  newBlock.update();
  
  size(900,600);
  
  background(80);
  stroke(0);
  
  PFont tex;
  tex = loadFont( "Monaco-48.vlw" );
  textFont( tex, 24 );

}

void draw(){
  
  background(30);
  fill(255);
  rect( 50, 50, 500, 500 );
  rect( 600, 50, 250, 250 );
  
  fill(30);
  text( "NEXT", 690, 100 );
  
  fill(255);
  text( "SCORE", 600, 400 );
  text( points, 800, 400 );
  
  
  newBlock.update();
  newBlock.display();
  
  keepOnGrid( b, 50,550,50,550, 50 );
  b.smoothGrid(50,50);
  for( int i = 1; i < 11 ; i++ ){
    if( clearFullRow( grid, i ) ){
    
      points += 100;
    }
  }
  
  // Draw everything in the grid
  fill( 225 );
  for( Square square : grid ){
    square.display();
  }
  
  // Draw the grid itself
  for( int i = 1; i < 12 ; i++ ){
    line( 50*i, 50, 50*i, 550 );
    line( 50, 50*i, 550, 50*i );
  }
  
  // Draw the held block
  if( b.pieces.size() != 0 ) { b.update(); }
  for( Square square : b.pieces ){
    square.setColor( 100 );
  }
  if( isBlockOnGrid(b, 50,550,50,550) == true ) { b.display(); }
  

  
  
}


//*******************************//
