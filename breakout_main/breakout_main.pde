// Breakout
// Andrew Willard
// CS340-01

// game state enum
enum GameCondition {
  LOADSCREEN,
  PLAYING,
  GAMEOVER
}

// Game State Instance
GameState game;

// setup
void setup() {
  background(0);
  size(1400, 900);
  
  // instantiate a Game
  game = new GameState();
  
  // set frame rate of game
  frameRate(120);
}

// draw loop
void draw() {
  // game state LOADSCREEN
  if (game.state == GameCondition.LOADSCREEN) {
    background(0);
    rectMode(CENTER);
    textAlign(CENTER);
    textSize(50);
    text("Press Space to Begin", width / 2, height / 2);
    
    // listen for space bar press to start game
    if (keyPressed) {
      if (key == ' ') {
         game.state = GameCondition.PLAYING;
         key = '0';
      }
    }
    
  }
  
  // game state PLAYING
  if (game.state == GameCondition.PLAYING) {
    // redraw the background
    background(0);
    
    // draw game border
    rectMode(CENTER);
    fill(0);
    stroke(255);
    strokeWeight(2);
    rect(width / 2, (height - 100) / 2 + 100, width - 4, height - 104);
    
    // draw bricks
    game.drawBricks();
    
    // process key presses
    if (keyPressed) {
      game.processControls();
    }
    
    // move balls and process collisions
    game.moveBalls();
    
    // draw paddle and balls
    game.drawPaddle();
    game.drawBalls();
    
    // draw game info at top of screen
    game.printStats();
  }
  
  // game state GAMEOVER
  if (game.state == GameCondition.GAMEOVER) {
    background(0);
    rectMode(CENTER);
    textAlign(CENTER);
    textSize(50);
    text("GAME OVER\nFinal Score: " + game.score + "\nPress Space to Restart", width / 2, height / 2);
    
    // listen for space bar press to start game
    if (keyPressed) {
      if (key == ' ') {
        game = new GameState();
        game.state = GameCondition.PLAYING;
        key = '0';
      }
    }
  }
  
}

/* CLASSES
------------------------------------------------- */

// A class to represent a moving ball in the game
class Ball {
  // x and y coordinate of the center point of the ball and current velocity of ball
  PVector ballPos, ballVelocity;
  
  // radius of all balls
  int ballDiameter = 12;
  
  Ball(PVector startPos, PVector startVelocity) {
    this.ballPos = startPos;
    this.ballVelocity = startVelocity;
  }
  
  // get center X of ball
  float x() {
    return this.ballPos.x;
  }
  
  float y() {
    return this.ballPos.y;
  }
  
  // move ball according to velocity
  void move() {
    this.ballPos.add(this.ballVelocity);
  }
  
  // set ball X coordinate (when moving ball stuck to paddle)
  void setX(float x) {
    this.ballPos.x = x;
  }
  
  // set ball Y coordinate
  void setY(float y) {
    this.ballPos.y = y;
  }
  
  // set ball velocity
  void setVelocity(PVector newVelocity) {
    this.ballVelocity = newVelocity;
  }
  
  // helper getters for top, bottom, and sides of ball
  float leftEdge() {
    return this.ballPos.x - ballDiameter / 2;
  }
  
  float rightEdge() {
    return this.ballPos.x + ballDiameter / 2;
  }
  
  float topEdge() {
    return this.ballPos.y - ballDiameter / 2;
  }
  
  float bottomEdge() {
    return this.ballPos.y + ballDiameter / 2;
  }
  
  // bounces ball off a side wall or side of brick
  void hBounce() {
    this.ballVelocity.x *= -1;
  }
  
  // bounces ball off a top or bottom wall or top or bottom of brick
  void vBounce() {
    this.ballVelocity.y *= -1;
  }
  
  void display() {
    strokeWeight(0);
    fill(255);
    circle(this.ballPos.x, this.ballPos.y, ballDiameter);
  }
  
}

// A class to represent the player's paddle in the game
class Paddle {
  // vector to contain the x/y coordinates of the center point of the paddle
  PVector paddlePos;
  // speed in pixels per frame that the paddle will move left to right
  double speed;
  // dimensions of the paddle
  PVector paddleDims;
  
  // width of window paddle exists in
  int windowWidth;
  
  // 'Big' Paddle powerup tracker
  int largerBy;
  
  Paddle(int windowWidth, int windowHeight) {
    this.paddlePos = new PVector(windowWidth / 2, windowHeight - 5);
    this.speed = 5;
    this.paddleDims = new PVector(100, 10);
    this.windowWidth = windowWidth;
    this.largerBy = 0;
  }
  
  PVector paddlePos() {
    return this.paddlePos;
  }
  
  PVector paddleDims() {
    return this.paddleDims;
  }
  
  float leftEdge() {
    return this.paddlePos.x - this.paddleDims.x / 2;
  }
  
  float rightEdge() {
    return this.paddlePos.x + this.paddleDims.x / 2;
  }
  
  float topEdge() {
    return this.paddlePos.y - this.paddleDims.y / 2;
  }
  
  float bottomEdge() {
    return this.paddlePos.y + this.paddleDims.y / 2;
  }
  
  void moveRight() {
    // move to the right by speed
    this.paddlePos.x += this.speed;
    
    // check for out of bounds and set to farthest right if yes
    if (this.paddlePos.x + this.paddleDims.x / 2 > this.windowWidth) {
      this.paddlePos.x = this.windowWidth - this.paddleDims.x / 2;
    }
  }
  
  void moveLeft() {
    // move to the left by speed
    this.paddlePos.x -= this.speed;
    
    // check for out of bounds and set to farthest left if yes
    if (this.paddlePos.x - this.paddleDims.x / 2 < 0) {
      this.paddlePos.x = this.paddleDims.x / 2;
    }
  }
  
  void makeBig() {
    if (this.largerBy < 4) {
      this.largerBy += 1;
      this.paddleDims.x = 100 + this.largerBy * 40;
    }
  }
  
  void makeSmall() {
    this.largerBy = 0;
    this.paddleDims.x = 100;
  }
  
  // return a vector to deflect the ball off of the paddle
  // the ball will deflect straight up if it hits in the center, and will be more angled the farther away it is from center of paddle
  PVector deflectionAngle(float ballX) {
    return new PVector(ballX - this.paddlePos.x, this.paddleDims.x / -2).normalize().setMag(game.gameSpeed);
  }
  
  void display() {
    fill(255);
    strokeWeight(0);
    rectMode(CENTER);
    rect(this.paddlePos.x, this.paddlePos.y, this.paddleDims.x, this.paddleDims.y);
  }
  
}

// a class to handle an individual brick
class Brick {
  // vector to conain x/y coordinates of center point of brick
  PVector brickPos;
  
  // brick health
  int health;
  
  // brick point value
  int points;
  
  // brick fill color
  color brickColor;
  
  // brick outline colors - determined by health
  color[] healthIndicator = {#000000, #777777, #bbbbbb, #ffffff};
  
  Brick(float x, float y, int health, color brickColor) {
    this.brickPos = new PVector(x, y);
    this.health = health;
    this.brickColor = brickColor;
    this.points = health * 150;
  }
  
  PVector center() {
    return this.brickPos;
  }
  
  color brickColor() {
    return this.brickColor;
  }
  
  int health() {
    return this.health;
  }
  
  float topEdge() {
    return this.brickPos.y - game.brickH / 2;
  }
  
  float bottomEdge() {
    return this.brickPos.y + game.brickH / 2;
  }
  
  float rightEdge() {
    return this.brickPos.x + game.brickW / 2;
  }
  
  float leftEdge() {
    return this.brickPos.x - game.brickW / 2;
  }
  
  int damage() {
    this.health -= 1;
    if (this.health == 0) {
      return this.points;
    } else {
      return 0;
    }
  }
  
  void display() {
    if (this.health > 1) {
      fill(this.healthIndicator[3]);
    } else {
      fill(this.brickColor);
    }
    stroke(this.healthIndicator[this.health - 1]);
    strokeWeight(3);
    rectMode(CENTER);
    rect(this.brickPos.x, this.brickPos.y, game.brickW - 4, game.brickH - 4);
  }
  
}

// class for brick layouts - hard coded for different "levels"
class BrickLayouts {
  // these are the different levels - ints indicate starting health of each brick
  // bricks with 0 health will not display or cause collisions
  int[][] levelOne = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  };
  int[][] levelTwo = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}
  };
  int[][] levelThree = {
    {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  };
  int[][] levelFour = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 3, 0},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 0},
    {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0}
  };
  
  int[][][] levels = {levelOne, levelTwo, levelThree, levelFour};
  
  int totalLevels = 4;
  
}

// Game State Class
// Will hold all Globally-needed information about the game state

class GameState {
  // array of all possible brick colors (Class level)
  color[] brickColors = {
    #2f4f4f,
    #7f0000,
    #191970,
    #006400,
    #bdb76b,
    #ff0000,
    #ffa500,
    #ffff00,
    #00ff00,
    #00fa9a,
    #00ffff,
    #0000ff,
    #d8bfd8,
    #ff00ff,
    #1e90ff,
    #ff1493
  };
  
  BrickLayouts layouts = new BrickLayouts();
  
  // general game speed - controls speed of balls and paddle
  int gameSpeed = 5;
  
  // player paddle
  Paddle paddle;
  
  // amount of bricks in a row
  int cols = 20;
  // max amount of bricks in a column
  int rows = 16;
  
  // ball diameter
  int ballDiameter = 12;

  // vars for brick width and height - calculated at instantiation based on width/height of screen
  float brickW;
  float brickH;

  // 2d array of all the bricks
  Brick[][] bricks;
  
  // array of balls - will start as just one
  ArrayList<Ball> gameBalls;

  // pause state variable
  boolean gamePaused = true;
  
  // player lives
  int livesLeft;
  
  // score
  int score;
  
  // game state
  GameCondition state;
  
  int currentLevel;
  
  // Constructor
  GameState() {
    // set level to 1
    this.currentLevel = 1;
    
    // set brick width/height based on window size
    this.brickW = (width - 4.0) / cols;
    this.brickH = (height - 100.0) / rows / 2.0;
    
    // create all bricks and put them in the brick 2d array
    this.bricks = new Brick[cols][rows];
    
    for (int i = 0; i < this.cols; i++) {
      for (int j = 0; j < this.rows; j++) {
        float brickX = i * brickW + brickW / 2 + 2;
        float brickY = j * brickH + brickH / 2 + 102;
        this.bricks[i][j] = new Brick(brickX, brickY, layouts.levels[this.currentLevel - 1][j][i], this.brickColors[j]);
      }
    }
    
    // instantiate player paddle
    this.paddle = new Paddle(width, height);
    
    // calculate starting position of initial Ball
    this.gameBalls = new ArrayList<Ball>();
    PVector ballStart = new PVector(width / 2, height - this.ballDiameter - this.paddle.paddleDims().y / 2);
    Ball firstBall = new Ball(ballStart, this.setInitialBallVelocity());
    this.gameBalls.add(firstBall);
    
    // initialize lives to 3
    this.livesLeft = 3;
    
    // initialize score to 0
    this.score = 0;
    
    // initialize game conidition to load screen
    this.state = GameCondition.LOADSCREEN;
    
  }
  
  // helper method to set an initial velocity for a ball
  PVector setInitialBallVelocity() {
    return new PVector(random(-10, 10), random(-2, -10)).normalize().setMag(this.gameSpeed);
  }
  
  // method to draw all bricks if they haven't been destroyed
  void drawBricks() {
    for (int i = 0; i < this.cols; i++) {
      for (int j = 0; j < this.rows; j++) {
        if (this.bricks[i][j].health > 0) {
          this.bricks[i][j].display();
        }
      }
    }
  }
  
  // method to draw player paddle
  void drawPaddle() {
    this.paddle.display();
  }
  
  // method to draw all balls
  void drawBalls() {
    for (Ball ball : this.gameBalls) {
      ball.display();
    }
  }
  
  // if key pressed, this will run to perform the appropriate actions
  // key is a global var from processing of the last key pressed
  void processControls() {
    switch (key) {
      case 'a':
      case 'A':
        // move left
        this.paddle.moveLeft();
        if (this.gamePaused) {
          for(Ball ball : this.gameBalls) {
            ball.setX(this.paddle.paddlePos().x);
          }
        }
        break;
      case 'd':
      case 'D':
        // move right
        this.paddle.moveRight();
        if (this.gamePaused) {
          for(Ball ball : this.gameBalls) {
            ball.setX(this.paddle.paddlePos().x);
          }
        }
        break;
      case ' ':
        // unpause game
        this.gamePaused = false;
        break;
      // backdoor to force level up without destroying all bricks
      case '=':
        this.levelUp();
        key = '0';
        break;
      case 'm':
      case 'M':
        this.multiBall();
        key = '0';
        break;
      case 'p':
        noLoop();
        break;
    }
  }
  
  // moves all game balls according to their velocities
  // also checks for collisions in current frame
  void moveBalls() {
    if (!this.gamePaused) {
      for (int b = this.gameBalls.size() - 1; b >= 0; b--) {
        Ball ball = this.gameBalls.get(b);
        // move ball
        ball.move();
        
        // get general ball direction to see which collisions to look for
        boolean movingRight = ball.ballVelocity.x >= 0;
        boolean movingDown = ball.ballVelocity.y >= 0;
        
        // check for collisions now that ball has moved
        // horizontal collisions
        if (movingRight) {
          // collision with right wall
          if (ball.rightEdge() >= width) {
            ball.hBounce();
            ball.setX(width - this.ballDiameter / 2);
          } else {
            // collisions with left side of bricks
            // don't need to do this unless we didn't bounce off the right wall
            for (int i = 0; i < cols; i++) {
              for (int j = 0; j < rows; j++) {
                Brick brick = this.bricks[i][j];
                if (brick.health > 0 && ball.y() <= brick.bottomEdge() && ball.y() >= brick.topEdge() && ball.rightEdge() >= brick.leftEdge() && ball.rightEdge() <= brick.rightEdge()) {
                  ball.hBounce(); //<>//
                  this.score += brick.damage();
                  if (brick.health < 1) {
                    this.powerUpCheck();
                  }
                  continue;
                }
              }
            }
          }
        } else {
          // collision with left wall
          if (ball.leftEdge() <= 0) {
            ball.hBounce();
            ball.setX(this.ballDiameter / 2);
          } else {
            // collisions with right side of bricks
            for (int i = 0; i < cols; i++) {
              for (int j = 0; j < rows; j++) {
                Brick brick = this.bricks[i][j];
                if (brick.health > 0 && ball.y() <= brick.bottomEdge() && ball.y() >= brick.topEdge() && ball.leftEdge() >= brick.leftEdge() && ball.leftEdge() <= brick.rightEdge()) {
                  ball.hBounce();
                  this.score += brick.damage();
                  if (brick.health < 1) {
                    this.powerUpCheck();
                  }
                  continue;
                }
              }
            }
          }
        }
        
        // check for vertical collisions
        if (movingDown) {
          // collision with bottom of screen or paddle
          if (ball.bottomEdge() >= this.paddle.paddlePos().y) {
            // see if ball hits the paddle
            if (ball.rightEdge() >= this.paddle.leftEdge() && ball.leftEdge() <= paddle.rightEdge()) {
              // bounce off of paddle
              ball.setVelocity(paddle.deflectionAngle(ball.x()));
            } else {
              // ball missed paddle, remove ball from balls array
              // since we are iterating through gameBalls arrayList backwards, this will not cause us to skip any balls when one is deleted
              this.gameBalls.remove(b);
            }
          } else {
            // collisions with tops of bricks
            for (int i = 0; i < cols; i++) {
              for (int j = 0; j < rows; j++) {
                Brick brick = this.bricks[i][j];
                if (brick.health > 0 && ball.x() >= brick.leftEdge() && ball.x() <= brick.rightEdge() && ball.bottomEdge() >= brick.topEdge() && ball.bottomEdge() <= brick.bottomEdge()) {
                  // bounce ball and damage brick
                  ball.vBounce();
                  this.score += brick.damage();
                  if (brick.health < 1) {
                    this.powerUpCheck();
                  }
                  continue;
                }
              }
            }
          }
        } else {
          // moving up - check collision with top of screen
          if (ball.topEdge() <= 100) {
            ball.vBounce();
            ball.setY(this.ballDiameter + 100);
          } else {
            // collisions with bottoms of bricks
            for (int i = 0; i < cols; i++) {
              for (int j = 0; j < rows; j++) {
                Brick brick = this.bricks[i][j];
                if (brick.health > 0 && ball.x() >= brick.leftEdge() && ball.x() <= brick.rightEdge() && ball.topEdge() >= brick.topEdge() && ball.topEdge() <= brick.bottomEdge()) {
                  // bounce ball and damage brick
                  ball.vBounce();
                  this.score += brick.damage();
                  if (brick.health < 1) {
                    this.powerUpCheck();
                  }
                  continue;
                }
              }
            }
          }
        }
      }
    }
    // after looping through game balls - check if there are balls left in array and lose a life if none remain
    if (this.gameBalls.size() == 0) {
      // decrement lives left
      this.livesLeft -= 1;
      if (this.livesLeft >= 1) {
        this.reset();
      } else {
        this.state = GameCondition.GAMEOVER;
        this.gamePaused = true;
      }
    }
    
    // check for level up
    if (this.checkComplete()) {
      this.levelUp();
    }
    
  }
  
  // random assignment of power ups when bricks are broken
  void powerUpCheck() {
    // get random value 0 - 999
    int r = floor(random(0, 1000));
    if (r < 40) {
      // big paddle
      this.paddle.makeBig();
    }
    if (r >= 40 && r < 70) {
      // multi-ball
      this.multiBall();
    }
  }
  
  // level end checker
  boolean checkComplete() {
    // check to see if level is complete - returns true if all bricks are gone
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        Brick brick = this.bricks[i][j];
        if (brick.health > 0) {
          // if any brick still has health, level isn't complete
          return false;
        }
      }
    }
    // if we get here, all bricks have 0 health, we can level up
    return true;
  }
  
  // multi-ball powerup - split each ball into 2 more balls
  void multiBall() {
    // clamp total number of balls to 10
    if (this.gameBalls.size() <= 10) {
      ArrayList<Ball> newBalls = new ArrayList<Ball>();
      // loop through current balls and create two more with random velocity vectors at the location of current ball
      // we will store these in newBalls to avoid creating iteration problems
      for (int i = 0; i < this.gameBalls.size(); i++) {
        // get current position and create new velocity vectors for the balls
        PVector randomV1 = new PVector(random(-10, 10), random(-2, -10)).normalize().setMag(this.gameSpeed);
        PVector randomV2 = new PVector(random(-10, 10), random(-2, -10)).normalize().setMag(this.gameSpeed);
        Ball ball1 = new Ball(new PVector(this.paddle.paddlePos().x, height - this.ballDiameter - this.paddle.paddleDims().y / 2), randomV1);
        Ball ball2 = new Ball(new PVector(this.paddle.paddlePos().x, height - this.ballDiameter - this.paddle.paddleDims().y / 2), randomV2);
        newBalls.add(ball1);
        newBalls.add(ball2);
      }
      
      // add new balls to game balls
      for (int i = 0; i < 2; i++) {
        this.gameBalls.add(newBalls.get(i));
      }
    }
  }
  
  // helper method to process level up
  void levelUp() {
    // increment level
    this.currentLevel += 1; //<>//
    // reset to level 1 if current level is out of bounds
    if (this.currentLevel > layouts.totalLevels) {
      this.currentLevel = 1;
    }
    
    // reset bricks array
    this.bricks = new Brick[cols][rows];
    
    for (int i = 0; i < this.cols; i++) {
      for (int j = 0; j < this.rows; j++) {
        float brickX = i * brickW + brickW / 2 + 2;
        float brickY = j * brickH + brickH / 2 + 102;
        this.bricks[i][j] = new Brick(brickX, brickY, layouts.levels[this.currentLevel - 1][j][i], this.brickColors[j]);
      }
    }
    
    // reset balls and paddle
    this.paddle = new Paddle(width, height);
    
    // calculate starting position of initial Ball
    this.gameBalls = new ArrayList<Ball>();
    Ball firstBall = new Ball(new PVector(width / 2, height - this.ballDiameter - this.paddle.paddleDims().y / 2), this.setInitialBallVelocity());
    this.gameBalls.add(firstBall);
    
    // increment lives for level up
    this.livesLeft += 1;
    
    // 1000 point bonus for finishing a level
    this.score += 1000;
    
    // pause game so player can reposition
    this.gamePaused = true;
    
  }
  
  // stat printer
  void printStats() {
    textSize(30);
    
    // lives remaining
    rectMode(CENTER);
    textAlign(LEFT);
    fill(255);
    if (this.livesLeft <= 1) {
      fill(#ff0000);
    }
    text("Lives Remaining: " + this.livesLeft, 40, 50);
    fill(255);
    textAlign(CENTER);
    text("Level " + this.currentLevel, width / 2, 50);
    
    // powerups
    fill(#00ff44);
    textSize(18);
    String powerups = "";
    // big paddle
    if (this.paddle.largerBy > 0) {
      powerups = "Big Paddle\n";
    }
    // multi-ball
    if (this.gameBalls.size() > 1) {
      powerups += "Multi-Ball\n";
    }
    text(powerups, (width - 40) - width / 4, 50);
    
    // score
    fill(255);
    textAlign(RIGHT);
    text("Score: " + this.score, width - 40, 50);
  }
  
  // reset method for after losing a life
  void reset() {
    // pause game so player can decide when to start again
    this.gamePaused = true;
    
    // re-initialize ball
    PVector ballStart = new PVector(this.paddle.paddlePos().x, height - this.ballDiameter - this.paddle.paddleDims().y / 2);
    Ball firstBall = new Ball(ballStart, this.setInitialBallVelocity());
    this.gameBalls.add(firstBall);
    
    // reset big paddle powerup
    this.paddle.makeSmall();
  }
  
}
