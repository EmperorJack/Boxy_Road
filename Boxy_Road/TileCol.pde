class TileCol {

  boolean[] solids;
  boolean[] tiles;
  float[] randoms;
  boolean[] coins;
  boolean[] slows;
  boolean noExtras;

  TileCol(boolean[] solids, float[] randoms, boolean noExtras) {
    this.solids = solids;
    this.randoms = randoms;
    tiles = new boolean[numTilesY];
    coins = new boolean[numTilesY];
    slows = new boolean[numTilesY];
    this.noExtras = noExtras;
  }

  void draw() {
    // draw a standard tile
    for (int y = 0; y < numTilesY; y++) {
      if (tiles[y]) {
        drawTile(25, 25 + y * tileSize, tileSize, tileSize, y);
      }
    }
  }

  void drawSpawning() {
    // draw a tile that is being created
    for (int y = 0; y < numTilesY; y++) {
      if (tiles[y] && (y*3 < -offset)) {
        drawTile(25, 25 + y * tileSize, tileSize, tileSize, y);
      }
    }
  }

  void drawDespawning() {
    // draw a tile that is being destroyed
    for (int y = 0; y < numTilesY; y++) {
      if (tiles[y]) {
        drawTile(25, 25 + y * tileSize, tileSize + offset, tileSize + offset, y);
      }
    }
  }

  void drawTile(int x, int y, float w, float h, int i) {
    // draw a tile given rectangle information
    rect(x, y, w, h);

    // if a coin should be drawn
    if (coins[i]) {
      pushStyle();

      // draw shadow
      fill(50);
      ellipse(x-2, y+2, 15, 15);

      // draw coin
      fill(232, 169, 80);
      ellipse(x, y, 15, 15);

      popStyle();
    }

    // if a slow should be drawn
    if (slows[i]) {
      pushStyle();

      // draw shadow
      fill(50);
      rect(x-2, y+2, 15, 15);

      // draw slow
      fill(100, 255, 100);
      rect(x, y, 15, 15);

      popStyle();
    }
  }

  boolean isSolid(int y) {
    // returns whether the specified tile is solid or not
    return tiles[y];
  }

  boolean removeCoin(int y) {
    // if given tile contains a coin
    if (coins[y]) {
      // remove it
      coins[y] = false;
      return true;
    }
    return false;
  }

  boolean removeSlow(int y) {
    // if given tile contains a coin
    if (slows[y]) {
      // remove it
      slows[y] = false;
      return true;
    }
    return false;
  }

  void shuffleRandoms() {
    // reset the tiles and pickups
    tiles = new boolean[numTilesY];
    coins = new boolean[numTilesY];
    slows = new boolean[numTilesY];

    for (int y = 0; y < numTilesY; y++) {
      // solid tiles are always spawned
      if (solids[y]) {
        tiles[y] = true;
      }

      // determine the tile spawning on the random chance value
      if (random(0, 1) < randoms[y]) {
        tiles[y] = true;
      }

      // determine if the tile should spawn a coin
      if (!noExtras && tiles[y] && random(0, 1) < 0.025) {
        coins[y] = true;
      }

      // determine if the tile should spawn a slow
      if (!noExtras && tiles[y] && random(0, 1) < 0.0035) {
        slows[y] = true;
      }
    }
  }
}

