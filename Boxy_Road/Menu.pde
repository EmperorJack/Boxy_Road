class Menu {

  // menu fields
  TileCol[] titleBlock;
  int state;
  PImage informationImage = loadImage("instructions.png");
  PImage documentationImage = loadImage("documentation.png");
  PImage highScoresImage = loadImage("highscores.png");

  // button fields
  Button playButton = new Button(280, 405, 360, 55, "Play");
  Button instructionsButton = new Button(280, 485, 360, 55, "Instructions");
  Button highScoresButton = new Button(280, 565, 360, 55, "High Scores");
  Button documentationButton = new Button(280, 645, 360, 55, "Documentation");
  Button exitButton = new Button(280, 725, 360, 50, "Exit");
  Button resetHighScoresButton = new Button(825, 725, 360, 50, "Reset High Scores");

  // highscore fields
  int[] scores;
  String[] names;

  Menu() {
    titleImage = loadImage("title.png");
    titleBlock = world.loadBlock(titleImage, true);
    state = 0;
    scores = new int[5];
    names = new String[5];
  }

  void draw() {
    // draw title tile shadows
    pushMatrix();
    translate(-5, 0);
    drawTitle(true);
    popMatrix();

    // draw title tiles
    drawTitle(false);

    // draw menu buttons
    drawMenuButtons();

    // draw differing menu states
    pushStyle();

    if (state == 0) {
      image(informationImage, 550, 380);
    } else if (state == 1) {
      drawHighScores();
    } else if (state == 2) {
      image(documentationImage, 550, 380);
    }

    popStyle();
  }

  void drawTitle(boolean isShadow) {
    pushMatrix();
    pushStyle();
    rectMode(CENTER);

    translate(tileSize*1.5, tileSize);

    scale(0.5);

    color actualColour = game.tileColour;
    if (isShadow) {
      actualColour = color(red(actualColour)-100, green(actualColour)-100, 
      blue(actualColour)-100);
    }

    // draw every tile column
    fill(actualColour);
    for (int col = 0; col < titleBlock.length; col++) {
      translate(tileSize, 0);
      titleBlock[col].draw();
    }

    popStyle();
    popMatrix();
  }

  void drawMenuButtons() {
    pushMatrix();
    pushStyle();

    rectMode(CENTER);
    fill(255);

    // option box outline
    rect(825, 565, 550, 370);

    // buttons
    playButton.draw();
    instructionsButton.draw();
    highScoresButton.draw();
    documentationButton.draw();
    exitButton.draw();

    popStyle();
    popMatrix();
  }

  void drawHighScores() {
    pushStyle();
    
    // draw image and button
    image(highScoresImage, 550, 380);
    rectMode(CENTER);
    resetHighScoresButton.draw();
    
    textSize(40);
    fill(50);
    
    // print the high scores table
    for (int i = 0; i < 5; i++) {
      String s = names[i] + " : " + scores[i];
      textAlign(LEFT, TOP);
      text((i+1) + ". ", 580, 430 + (i * 50));
      textAlign(CENTER, TOP);
      text(s, 825, 430 + (i * 50));
    }

    popStyle();
  }

  void updateHighScores(int score, String name) {
    // check the current scores against the new score
    for (int i = 0; i < 5; i++) {
      // if the new score is higher than a highscore
      if (score > scores[i]) {

        // rearrange the scores and names array
        for (int j = 4; j >= max (i, 1); j--) {
          scores[j] = scores[j-1];
          names[j] = names[j-1];
        }

        // add the new score and name
        scores[i] = score;
        names[i] = name;
        break;
      }
    }

    // overwrite the scores and names data files
    String[] data = new String[scores.length];

    for (int i = 0; i < 5; i++) {
      data[i] = names[i] + ":" + scores[i];
    }
    saveStrings("data/highscores.txt", data);
  }


  void loadHighScores() {
    // check the high scores file exists
    File f = new File(dataPath("highscores.txt"));

    // if it does not exist
    if (!f.exists()) {
      resetHighScores();
      return;
    }

    // load the scores and names data files
    String[] data = loadStrings("data/highscores.txt");

    for (int i = 0; i < 5; i++) {
      String[] split = data[i].split(":");
      scores[i] = int(split[1]);
      names[i] = split[0];
    }
  }

  void resetHighScores() {
    // generate an empty high scores table
    scores = new int[5];
    names = new String[5];
    for (int i = 0; i < 5; i++) {
      updateHighScores(0, "Null");
    }
  }

  boolean mouseOnButton(int button) {
    if (button == 0) {
      return playButton.mouseOn();
    } else if (button == 1) {
      return instructionsButton.mouseOn();
    } else if (button == 2) {
      return highScoresButton.mouseOn();
    } else if (button == 3) {
      return documentationButton.mouseOn();
    } else if (button == 4) {
      return exitButton.mouseOn();
    } else if (button == 5) {
      return resetHighScoresButton.mouseOn();
    }
    return false;
  }
}

