class Particle {
  float beginX = 20.0;  // Initial x-coordinate
  float beginY = 10.0;  // Initial y-coordinate
  float endX = 570.0;   // Final x-coordinate
  float endY = 320.0;   // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move

  float x = 0.0;        // Current x-coordinate
  float y = 0.0;        // Current y-coordinate
  float step = 0.01;    // Size of each step along the path
  float pct = 0.0;      // Percentage traveled (0.0 to 1.0)

  public Particle(PVector source, PVector destination) {
    pct = 0.0;
    beginX = source.x;
    beginY = source.y;
    endX = destination.x;
    endY = destination.y;

    distX = endX - beginX;
    distY = endY - beginY;
  }

  void step() {
    update();
    display();
  }

  void display() {    
    fill(255, 0, 0);
    ellipse(x, y, 1, 1);
  }

  void update() {
    pct += step;
    if (pct < 1.0) {
      x = beginX + pct * distX;
      y = beginY + pct * distY;
    }
  }

  // Is the particle still useful?
  boolean isDead() {
    return pct >= 1.0;
  }
}

