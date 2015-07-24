import ddf.minim.*;

class Game {

  // game fields
  float rate;
  float rateDecreaseOpac;
  float rateIncreaseOpac;

  // state fields
  boolean paused;
  boolean dead;
  boolean newHighScore;

  // game over screen fields
  Button playAgainButton = new Button(280, 750, 380, 70, "Run Again");
  Button resumeButton = new Button(280, 750, 380, 70, "Resume");
  Button exitToMenuButton = new Button(920, 750, 380, 70, "Exit To Menu");

  // scoring fields
  int score;
  int coins;
  float coinCollectOpac;
  String name;

  // level fields
  int levelCount;
  float levelTextOpac;

  // colour fields
  color tileColour;
  color charColour;
  color[][] colourSet = new color[][] { 
    {
      color(#FFFFFF), color(#888888) // black, gray
    }
    , {
      color(#12e15f), color(#FF5047) // green, red
    }
    , {
      color(#EFFF5A), color(#AD42FF) // yellow, purple
    }
    , {
      color(#B27D19), color(#4093FF) // brown, blue
    }
    , {
      color(#47FFD4), color(#FF6937) // cyan, orange
    }
  };

  // sound fields
  AudioPlayer track01;
  AudioPlayer track02;
  AudioPlayer track02a;
  AudioPlayer track02b;
  AudioPlayer coinSound;
  AudioPlayer speedUpSound;
  AudioPlayer speedDownSound;

  Game() {
    world = new World();
    character = new Character();
    reset();

    // audio track setup
    track01 = minim.loadFile("track01.wav");
    track01.loop();
    track01.mute();
    track02a = minim.loadFile("track02.wav");
    track02a.loop();
    track02a.mute();
    track02b = minim.loadFile("track03.wav");
    track02b.loop();
    track02b.mute();
    track02 = track02a;

    // audio effects setup
    coinSound = minim.loadFile("coin.wav");
    speedUpSound = minim.loadFile("speedUp.wav");
    speedDownSound = minim.loadFile("speedDown.wav");
  }

  void update() {
    if (!paused && !dead) {
      // increment the offset
      offset -= rate;

      // check offset for a tile cycle
      if (offset < -tileSize) {
        offset = 0;

        // cycle the world tiles
        world.cycleTiles();

        // shift the charcter to the left one unit
        if (!world.nextBlockNextLevel) {
          character.shuntLeft();
        }

        // if the next level is on approach move the character to the right edge of the screen
        if (world.nextBlockNextLevel) {
          character.shuntLeft();
        }

        // increment the score
        score += 1;
      }

      // update character
      character.update();

      // check if character died
      if (!checkInBounds()) {
        dead = true;

        // toggle music tracks
        game.track01.unmute();
        game.track02.mute();

        // check if the score beats a high score
        if (score > menu.scores[4]) {
          newHighScore = true;
        }
      }
    }
  }

  void draw() {
    pushMatrix();

    // translate to the current offset
    translate((int) offset, 150);

    // draw world and character
    world.draw();
    character.draw();

    popMatrix();

    // draw the paused text if paused
    if (paused) {
      // draw gray overlay
      fill(0, 150);
      rect(600, 400, w, h);

      drawPausedText();

      // allow exit to menu
      exitToMenuButton.draw();

      // resume game button
      resumeButton.draw();
    }

    // draw the game over text if the character died
    if (dead) {
      // draw gray overlay
      fill(0, 150);
      rect(600, 400, w, h);

      drawGameOverScreen();
    }

    // draw the heads up display
    drawHUD();
  }

  void drawHUD() {
    pushStyle();

    // draw the current score
    fill(255);
    textSize(60);
    textAlign(CENTER, CENTER);
    text((int) score, 475, 70);
    textSize(20);
    text("Score:", 475, 25);

    // notify the player of score increase from coin collect
    if (coinCollectOpac > 0) {
      fill(232, 169, 80, coinCollectOpac * 255);
      textSize(25);
      text("+ 10", 475, 120);
      coinCollectOpac -= 0.01;
    }

    // draw the current rate
    fill(255);
    textSize(60);
    text(nfs((rate - 2), 0, 2), 725, 70);
    textSize(20);
    text("Speed:", 725, 25);

    // notify the player of rate decrease from coin collect
    if (rateDecreaseOpac > 0) {
      fill(100, 255, 100, rateDecreaseOpac * 255);
      textSize(25);
      text("-0.05", 725, 120);
      rateDecreaseOpac -= 0.008;
    }

    // notify the player of rate increase from level increment
    if (rateIncreaseOpac > 0) {
      fill(255, 100, 100, rateIncreaseOpac * 255);
      textSize(25);
      text("+0.5", 725, 120);
      rateIncreaseOpac -= 0.005;
    }

    // draw next level text if required
    if (world.nextBlockNextLevel && !dead) {
      levelTextOpac += 0.0025;
      fill(255, levelTextOpac * 255);
      textSize(50);
      text("Level " + (levelCount+1) + " Ahead!", 600, 300);
    }

    // draw the current level achieved
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(20);
    text("Level: " + levelCount, 20, 25);

    // draw the current coins collected
    text("Coins: " + coins, 20, 55);

    // draw the current fps
    fill(255);
    textSize(15);
    textAlign(RIGHT, CENTER);
    text("FPS : " + (int) frameRate, 1180, 20);

    popStyle();
  }

  void drawPausedText() {
    fill(25);
    textSize(100);
    textAlign(CENTER, CENTER);
    text("PAUSED", 595, 405);
    fill(255);
    text("PAUSED", 600, 400);
  }

  void drawGameOverScreen() {
    pushMatrix();
    pushStyle();

    rectMode(CENTER);
    fill(255);

    // buttons
    playAgainButton.draw();
    exitToMenuButton.draw();

    // game over text
    fill(25);
    textSize(100);
    textAlign(CENTER, CENTER);
    text("GAME OVER!", 595, 405);
    fill(255);
    text("GAME OVER!", 600, 400);

    // new high score text
    if (newHighScore) {
      fill(25);
      textSize(80);
      text("NEW HIGH SCORE!", 595, 205);
      text("Name: " + name + "|", 595, 305);
      fill(255);
      text("NEW HIGH SCORE!", 600, 200);
      text("Name: " + name, 595, 305);
    }

    popStyle();
    popMatrix();
  }

  boolean checkInBounds() {
    // if the player is dead if it hits the left side
    return (world.entryPoint < character.x);
  }

  void coinCollected() {
    // increment the score
    score += 10;

    // increment the coin counter
    coins++;

    // draw the change score text
    coinCollectOpac = 1;

    // play coin collected sound
    coinSound.rewind();
    coinSound.play();
  }

  void slowCollected() {
    // decrement the rate
    rate -= 0.05;

    // draw the decrease in rate text
    rateDecreaseOpac = 1;

    // play slow speed sound
    speedDownSound.rewind();
    speedDownSound.play();
  }

  void nextLevel() {
    levelCount++;

    // increment the rate
    rate += 0.5;

    // draw the increase in rate text
    rateIncreaseOpac = 1;

    // randomise the tile vs character colour
    int a = (int) random(0, 2);
    int b = 1;
    if (a == 1) {
      b = 0;
    }

    // get the colours from the set
    tileColour = colourSet[(levelCount-1) % 5][a];
    charColour = colourSet[(levelCount-1) % 5][b];

    // change the gameplay track if level 5 attained
    if (levelCount == 5) {
      track02 = track02b;
    }

    // play increase speed sound
    speedUpSound.rewind();
    speedUpSound.play();
  }

  void reset() {
    // reset the world and character
    moveStack.clear();
    world.reset();
    character.reset();
    offset = 0;
    rate = 3;
    paused = false;
    dead = false;
    newHighScore = false;
    score = 0;
    coins = 0;
    if (name == null) {
      name = "Player";
    }
    levelCount = 1;
    tileColour = colourSet[0][0];
    charColour = colourSet[0][1];
    track02 = track02a;
  }

  boolean mouseOnButton(int button) {
    if (button == 0) {
      return playAgainButton.mouseOn();
    } else if (button == 1) {
      return resumeButton.mouseOn();
    } else if (button == 2) {
      return exitToMenuButton.mouseOn();
    }
    return false;
  }
}

