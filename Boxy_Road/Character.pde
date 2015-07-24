class Character {

  // position fields
  int x;
  int y;
  int tx;
  int ty;
  float cx;
  float cy;

  // movement interpolation fields
  BasicTween xTween;
  BasicTween yTween;

  void update() {
    //tween the character movement 
    cx = xTween.tween(millis());
    cy = yTween.tween(millis());

    if (cx == tx) {
      x = tx;
    }
    if (cy == ty) {
      y = ty;
    }
  }

  void draw() {
    pushStyle();

    // draw shadow
    fill(50);
    rect((int) (cx * tileSize + 22), cy * tileSize + 28, charSize, charSize);

    // draw character
    fill(game.charColour);
    rect((int) (cx * tileSize + 25), cy * tileSize + 25, charSize, charSize);

    popStyle();
  }

  void move(int dir) {
    int nx = x;
    int ny = y;

    switch(dir) {

    case 0: // up
      ny -= 1;
      break;
    case 1: // left
      nx -= 1;
      break;
    case 2: // down
      ny += 1;
      break;
    case 3: // right
      nx += 1;
      break;
    }

    // check targeted tile exists
    if (world.onTiles(nx, ny)) {
      tx = nx;
      ty = ny;

      // create new movement tweens
      xTween = new BasicTween(x, 75, (tx - x), millis());
      yTween = new BasicTween(y, 75, (ty - y), millis());

      // check for coins in new position
      if (world.coinCollect(tx, ty)) {
        game.coinCollected();
      }

      // check for slows in new position
      if (world.slowCollect(tx, ty)) {
        game.slowCollected();
      }
    }
  }

  void shuntLeft() {
    // move the character one unit to the left
    x -= 1;
    tx -= 1;
    cx -= 1;

    // update the movement tweens
    xTween.startValue = x;
    xTween.valueRange = tx - x;
  }

  void reset() {
    // reset character position
    x = 12;
    y = 5;
    tx = x;
    ty = y;
    cx = x;
    cy = y;
    xTween = new BasicTween(x, 0, 0, millis());
    yTween = new BasicTween(y, 0, 0, millis());
  }
}

