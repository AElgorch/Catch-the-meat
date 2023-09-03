import java.awt.Color;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import processing.core.PImage;

List<Fruit> fruits; // List to store fruit instances
List<PowerUp> powerUps; // List to store power-up instances
List<Bomb> bombs; // List to store bomb instances
Paddle paddle; // Paddle instance
int score; // Player's score
int startTime; // Start time of the game
int gameDuration = 2 * 60 * 1000; // 2 minutes in milliseconds

boolean gameOver; // Flag to indicate game over state
PImage appleImage; // Image for apple fruit
PImage bananaImage; // Image for banana fruit
PImage powerUpImage; // Image for power-up
PImage bombImage; // Image for bomb
int numBombsLeft; // Number of bombs left to collide with before the game ends
boolean gameEnded; // Flag to indicate the end of the game

// Power-up variables
int powerupDuration = 10 * 1000; // Duration of the power-up in milliseconds
int lastPowerupTime; // Keep track of the time when the last power-up appeared

void setup() {
  fullScreen();
  fruits = new ArrayList<Fruit>(); // Initialize the fruit list
  powerUps = new ArrayList<PowerUp>(); // Initialize the power-up list
  bombs = new ArrayList<Bomb>(); // Initialize the bomb list
  paddle = new Paddle(); // Create a new paddle instance
  score = 0;
  startTime = millis();
  gameOver = false;
  numBombsLeft = 3;
  gameEnded = false;

  // Load the apple, banana, power-up, and bomb images
  appleImage = loadImage("apple.png");
  bananaImage = loadImage("banana.png");
  powerUpImage = loadImage("powerup.png");
  bombImage = loadImage("bomb.png");

  // Add initial fruits
  for (int i = 0; i < 5; i++) {
    fruits.add(new Fruit());
  }

  // Initialize lastPowerupTime
  lastPowerupTime = millis();
}

void draw() {
  background(0);

  // Check if game duration has passed
  if (millis() - startTime >= gameDuration) {
    gameOver = true;
  }

  if (!gameOver) {
    // Move and display fruits
    for (Fruit fruit : fruits) {
      fruit.move();
      fruit.display();
    }

    // Move and display power-ups
    for (PowerUp powerUp : powerUps) {
      powerUp.move();
      powerUp.display();

      // Check collision with paddle
      if (powerUp.intersects(paddle)) {
        powerUp.applyPowerUp();
        powerUps.remove(powerUp);
        break;
      }
    }

      // Move and display bombs
    Iterator<Bomb> bombIterator = bombs.iterator();
    while (bombIterator.hasNext()) {
      Bomb bomb = bombIterator.next();
      bomb.move();
      bomb.display();

      // Check collision with paddle
      if (bomb.intersects(paddle)) {
        numBombsLeft--;
        bombIterator.remove();
        if (numBombsLeft <= 0) {
          gameOver = true;
        }
      }
    }

    // Check collision with paddle and score points
    Iterator<Fruit> iterator = fruits.iterator();
    while (iterator.hasNext()) {
      Fruit fruit = iterator.next();
      if (fruit.intersects(paddle)) {
        iterator.remove();
        score++;
      }
    }

    // Spawn new fruits if needed
    while (fruits.size() < 5) {
      fruits.add(new Fruit());
    }

    // Spawn a bomb every 10 seconds
    if (millis() - lastPowerupTime >= 10000) {
      bombs.add(new Bomb());
      lastPowerupTime = millis();
    }

    paddle.update();
    paddle.display();

    // Display score
    fill(255);
    textSize(20);
    text("Score: " + score, 10, 30);

    // Display remaining time
    int remainingTime = (gameDuration - (millis() - startTime)) / 1000;
    text("Time: " + remainingTime + "s", width - 100, 30);

    // Display number of bombs left
    text("Lives: " + numBombsLeft, width - 180, 60);
  } else {
    // Game over
    fill(255, 0, 0);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("Game Over", width / 2, height / 2);

    // Display score underneath the "Game Over" sign
    fill(255);
    textSize(20);
    text("Score: " + score, width / 2, height / 2 + 40);

    if (gameEnded) {
      // Display game-ended message
      fill(255);
      textSize(20);
      text("Bombs collided: " + (3 - numBombsLeft), width / 2, height / 2 + 80);
    }
  }
}

void keyPressed() {
  if (!gameOver) {
    if (keyCode == LEFT) {
      paddle.moveLeft();
    } else if (keyCode == RIGHT) {
      paddle.moveRight();
    }
  }
}

// Represents a fruit
class Fruit {
  float x, y;
  float speed;
  PImage image;

  Fruit() {
    reset();
    speed = random(1, 5);
    // Randomly assign either apple or banana image to the fruit
    if (random(1) < 0.5) {
      image = appleImage;
    } else {
      image = bananaImage;
    }
  }

  void reset() {
    x = random(width);
    y = 0;
  }

  void move() {
    y += speed;
  }

  void display() {
    image(image, x, y, 80, 80);
  }

  boolean intersects(Paddle paddle) {
    return y + 80 > height - 20 && x + 80 > paddle.x - 80 && x < paddle.x + 80;
  }
}

// Represents a power-up
class PowerUp {
  float x, y;
  float speed;
  PImage image;

  PowerUp() {
    reset();
    speed = random(1, 5);
    image = powerUpImage;
  }

  void reset() {
    x = random(width);
    y = 0;
  }

  void move() {
    y += speed;

    // Check if power-up is out of bounds
    if (y > height) {
      powerUps.remove(this);
    }
  }

  void display() {
    image(image, x, y, 80, 80);
  }

  boolean intersects(Paddle paddle) {
    return y + 80 > height - 20 && x + 80 > paddle.x - 80 && x < paddle.x + 80;
  }

  void applyPowerUp() {
    int timeIncrease = 10 * 1000; // Increase the time remaining by 10 seconds
    gameDuration += timeIncrease;
  }
}

// Represents a bomb
class Bomb {
  float x, y;
  float speed;
  PImage image;

  Bomb() {
    reset();
    speed = random(1, 5);
    image = bombImage;
  }

  void reset() {
    x = random(width);
    y = 0;
  }
  
  void move() {
    y += speed;

  // Check if bomb is out of bounds
  if (y > height) {
    reset();
  }
}


  void display() {
    image(image, x, y, 80, 80);
  }

  boolean intersects(Paddle paddle) {
    return y + 80 > height - 20 && x + 80 > paddle.x - 80 && x < paddle.x + 80;
  }
}

// Represents the paddle
class Paddle {
  float x;
  float speed = 20; // Adjust paddle speed here

  Paddle() {
    x = width / 2;
  }

  void update() {
    if (keyPressed && !gameOver) {
      if (keyCode == LEFT) {
        moveLeft();
      } else if (keyCode == RIGHT) {
        moveRight();
      }
    }
  }

  void display() {
    fill(0, 255, 0);
    rect(x - 75, height - 10, 150, 20); // Increase hitbox height to 20 pixels
  }

  void moveLeft() {
    x -= speed;
    if (x < 75) {
      x = 75;
    }
  }

  void moveRight() {
    x += speed;
    if (x > width - 75) {
      x = width - 75;
    }
  }
}
