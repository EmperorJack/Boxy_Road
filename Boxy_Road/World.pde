class World {

  // tile queue
  ArrayList<TileCol> tiles;

  // block fields
  ArrayList<TileCol[]> blocks;
  TileCol[] gateBlock;
  int blockCycler;
  int blockCounter;
  int blockSize = 40;
  int numUniqueBlocks = 7;
  int blocksPerLevel = 3;
  boolean nextBlockNextLevel;

  // defining image colours
  color chance100 = color(255);
  color chance85 = color(200);
  color chance50 = color(128);
  color chance15 = color(50);

  // column entry and exit indices
  int entryPoint = 2;
  int exitPoint = numTilesX - 2;

  World() {
    loadBlocks();
  }

  void draw() {
    // draw tile shadows
    pushMatrix();
    translate(-5, 0);
    drawTiles(true);
    popMatrix();

    // draw tiles
    drawTiles(false);
  }

  void drawTiles(boolean isShadow) {
    pushMatrix();
    pushStyle();

    color actualColour = game.tileColour;
    if (isShadow) {
      actualColour = color(red(actualColour)-100, green(actualColour)-100, 
      blue(actualColour)-100);
    }

    // draw the despawning column
    translate(tileSize * entryPoint, 0);
    fill(actualColour, map(offset, 0, -tileSize, 255, 0));
    tiles.get(entryPoint).drawDespawning();

    // draw every tile column
    fill(actualColour);
    for (int col = entryPoint + 1; col < exitPoint-1; col++) {
      translate(tileSize, 0);
      tiles.get(col).draw();
    }

    // draw the spawning column
    translate(tileSize, 0);
    fill(actualColour, map(offset, 0, -tileSize, 0, 255));
    tiles.get(exitPoint-1).drawSpawning();

    popStyle();
    popMatrix();
  }

  boolean onTiles(int x, int y) {
    // check position is within bounds of grid
    if (0 <= entryPoint && x < exitPoint && 0 <= y && y < numTilesY) {
      // check if the tile is solid
      return tiles.get(x).isSolid(y);
    }
    return false;
  }

  boolean coinCollect(int x, int y) {
    // check position is within bounds of grid
    if (0 <= entryPoint && x < exitPoint && 0 <= y && y < numTilesY) {
      // check if the tile has a coin to be removed
      return tiles.get(x).removeCoin(y);
    }
    return false;
  }

  boolean slowCollect(int x, int y) {
    // check position is within bounds of grid
    if (0 <= entryPoint && x < exitPoint && 0 <= y && y < numTilesY) {
      // check if the tile has a slow to be removed
      return tiles.get(x).removeSlow(y);
    }
    return false;
  }

  void cycleTiles() {
    // shuffle the despawning row so there is a chance
    // of spawning random tiles next time
    tiles.get(0).shuffleRandoms();

    // remove the first row
    tiles.remove(0);

    // check whether new tile columns need to be added
    if (blockCycler == blockSize-1) {

      // check to see if level needs to be incremented
      if (blockCounter == blocksPerLevel) {

        nextBlockNextLevel = true;
        game.levelTextOpac = 0;

        // toggle music tracks
        game.track01.unmute();
        game.track02.mute();

        // read the gate block
        for (int x = 0; x < blockSize; x++) {
          tiles.add(gateBlock[x]);
        }

        blockCycler = 0;
        blockCounter = 0;
      } else {
        // add a new random block
        int randomIndex = (int) random(0, numUniqueBlocks);
        TileCol[] block = blocks.get(randomIndex);

        // read the blocks
        for (int x = 0; x < blockSize; x++) {
          tiles.add(block[x]);
        }

        // check if this block starts a new level
        if (nextBlockNextLevel) {
          // tell the game to move to the next level settings
          game.nextLevel();
          nextBlockNextLevel = false;

          // toggle music tracks
          game.track01.mute();
          game.track02.unmute();
        }

        blockCycler = 0;
        blockCounter++;
      }
    } else {
      blockCycler++;
    }
  }

  void loadBlocks() {
    blocks = new ArrayList<TileCol[]>();
    blockImages = new PImage[numUniqueBlocks];

    // load the gate block
    gateImage = loadImage("gate.png");
    gateBlock = loadBlock(gateImage, true);

    // for each unique block image file to load
    for (int i = 0; i < numUniqueBlocks; i++) {
      // load the block image file
      blockImages[i] = loadImage("block" + i + ".png");

      // load the block tile columns
      TileCol[] blockRows = loadBlock(blockImages[i], false);

      // append the new block to the blocks list
      blocks.add(blockRows);
    }
  }

  TileCol[] loadBlock(PImage image, boolean noCoins) {
    TileCol[] blockRows = new TileCol[blockSize];

    // determine the solid tiles in each row of the block
    for (int x = 0; x < blockSize; x++) {
      boolean[] solids = new boolean[numTilesY];
      float[] randoms = new float[numTilesY];

      // each tile
      for (int y = 0; y < numTilesY; y++) {

        // if it's a solid tile
        if (image.get(x, y) == chance100) {
          solids[y] = true;
          randoms[y] = 1;
        }

        // if it's a 85% chance tile
        if (image.get(x, y) == chance85) {
          randoms[y] = 0.85;
        }

        // if it's a 50% chance tile
        if (image.get(x, y) == chance50) {
          randoms[y] = 0.5;
        }

        // if it's a 15% chance tile
        if (image.get(x, y) == chance15) {
          randoms[y] = 0.15;
        }
      }
      blockRows[x] = new TileCol(solids, randoms, noCoins);

      // shuffle the new tile column by default
      blockRows[x].shuffleRandoms();
    }

    return blockRows;
  }

  void reset() {
    blockCycler = blockSize-1;
    blockCounter = 0;
    nextBlockNextLevel = false;
    tiles = new ArrayList<TileCol>();

    // initial grid state
    for (int x = 0; x < exitPoint; x++) {
      boolean[] solids = new boolean[numTilesY];
      float[] randoms = new float[numTilesY];
      for (int y = 3; y < numTilesY-3; y++) {
        solids[y] = true;
        randoms[y] = 1;
      }
      TileCol newRow = new TileCol(solids, randoms, true);

      // shuffle the new tile column by default
      newRow.shuffleRandoms();

      tiles.add(newRow);
    }
  }
}

