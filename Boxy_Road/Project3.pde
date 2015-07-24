/*
 * Jack Purvis (300311934)
 * MDDN242: Project 3, Game
 */

// sketch fields
static int w = 1200;
static int h = 800;

// state fields
boolean inGame;

// menu fields
Menu menu;
PImage titleImage;

// game fields
Game game;
World world;
PImage[] blockImages;
PImage gateImage;
Character character;
float offset;
Minim minim;

// movement fields
ArrayList<Integer> moveStack = new ArrayList<Integer>();
float lastMove;

// size fields
static int charSize = 40;
static int tileSize = 50;

// grid fields
static int numTilesX = 25;
static int numTilesY = 11;

void setup() {
  size(w, h);

  // drawing setup
  ellipseMode(CENTER);
  noStroke();
  PFont font = createFont("Square.ttf", 16);
  textFont(font);

  // timing setup
  lastMove = millis();
  offset = 0;

  // sound setup
  minim = new Minim(this);

  // game setup
  game = new Game();
  inGame = false;

  // menu setup
  menu = new Menu();
  menu.loadHighScores();

  // begin playing music
  game.track01.unmute();
}

void draw() {
  background(50);

  // if currently playing the game
  if (inGame) {
    rectMode(CENTER);

    // take the last pressed key for movement direction
    if (moveStack.size() > 0  && (millis() - lastMove) > 100) {
      character.move(moveStack.get(moveStack.size()-1));
      lastMove = millis();
    }

    // update the game
    game.update();

    // render the game
    game.draw();
  } else {
    // if currently in the the menu state
    menu.draw();
  }
}

void keyPressed() {
  if (inGame && !game.newHighScore) {
    // when a key is pressed enable moving in that direction
    if (key == 'w' || keyCode == UP) {
      moveStack.add(0);
    } else if (key == 'a' || keyCode == LEFT) {
      moveStack.add(1);
    } else if (key == 's' || keyCode == DOWN) {
      moveStack.add(2);
    } else if (key == 'd' || keyCode == RIGHT) {
      moveStack.add(3);
    } else if (key == 'p' && inGame && !game.dead) {
      // pause or unpause the game
      game.paused = !game.paused;

      if (game.paused) {
        // toggle music tracks
        game.track01.unmute();
        game.track02.mute();
      } else {
        // toggle music tracks
        game.track01.mute();
        game.track02.unmute();
      }
    }
  } else if (game.dead && game.newHighScore) {
    // modifying the input name string for a new high score
    if (key == BACKSPACE) {
      // back space the last character
      if (game.name.length() > 0) {
        game.name = game.name.substring(0, game.name.length()-1);
      }
    } else if (game.name.length() < 10 && key != ENTER){
      // if max characters not achieved add the new key
      game.name += key;
    }
  }
}

void keyReleased() {
  if (inGame) {
    // when a key is released disable moving in that direction
    if (key == 'w' || keyCode == UP) {
      removeFromMoveStack(0);
    } else if (key == 'a' || keyCode == LEFT) {
      removeFromMoveStack(1);
    } else if (key == 's' || keyCode == DOWN) {
      removeFromMoveStack(2);
    } else if (key == 'd' || keyCode == RIGHT) {
      removeFromMoveStack(3);
    }
  }
}

void mouseClicked() {
  if (!inGame) {
    // when attempting to select a menu button
    if (menu.mouseOnButton(0)) {
      // enter game state
      inGame = true;
      game.reset();

      // toggle music tracks
      game.track01.mute();
      game.track02.unmute();
    } else if (menu.mouseOnButton(1)) {
      // instructions menu option
      menu.state = 0;
    } else if (menu.mouseOnButton(2)) {
      // highscores menu option
      menu.state = 1;

      // get the current highscores
      menu.loadHighScores();
    } else if (menu.mouseOnButton(3)) {
      // documentation menu option
      menu.state = 2;
    } else if (menu.mouseOnButton(4)) {
      // exit game menu option
      minim.stop();
      exit();
    } else if (menu.mouseOnButton(5) && menu.state == 1) {
      // reset high scores option
      menu.resetHighScores();
    }
  } else {
    if (game.dead || game.paused) {
      // when attempting to select a game over screen button
      if (game.mouseOnButton(0) && !game.paused) {
        // check if a high score update needed
        if (game.newHighScore) {
          menu.updateHighScores(game.score, game.name);
        }

        // reset game state
        game.reset();

        // toggle music tracks
        game.track01.mute();
        game.track02.unmute();
      } else if (game.mouseOnButton(1) && game.paused) {
        // unpause the game
        game.paused = !game.paused;

        // toggle music tracks
        game.track01.mute();
        game.track02.unmute();
      } else if (game.mouseOnButton(2)) {
        // enter menu state
        inGame = false;

        // check if a high score update needed
        if (game.newHighScore) {
          menu.updateHighScores(game.score, game.name);
        }

        // toggle music tracks
        game.track01.unmute();
        game.track02.mute();
      }
    }
  }
}

void removeFromMoveStack(int i) {
  // remove all occurances of given direction from the move stack
  ArrayList<Integer> newMoveStack = new ArrayList<Integer>();

  for (int j = 0; j < moveStack.size (); j++) {
    if (moveStack.get(j) != i) {
      newMoveStack.add(moveStack.get(j));
    }
  }

  moveStack = newMoveStack;
}

