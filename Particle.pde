class Particle {
  float beginX = 20.0;  // Initial x-coordinate
  float beginY = 10.0;  // Initial y-coordinate
  float endX = 570.0;   // Final x-coordinate
  float endY = 320.0;   // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move

  float x = 0.0;        // Current x-coordinate
  float y = 0.0;        // Current y-coordinate
  float step = 0.1;    // Size of each step along the path
  float pct = 0.0;      // Percentage traveled (0.0 to 1.0)
  int do_trace;
  int colr;
  long lifetimeInFrames = 0;
  int nframes = 0;

  public Particle(PVector source, PVector destination, int colr, long lifetimeInFrames, int do_trace) {
    this.step = 1.0/(lifetimeInFrames + 1);
    this.lifetimeInFrames = lifetimeInFrames;
    this.do_trace = do_trace;
    this.colr = colr;
    
    pct = 0.0;
    beginX = source.x;
    beginY = source.y;
    endX = destination.x;
    endY = destination.y;

    distX = endX - beginX;
    distY = endY - beginY;
  }

  void step(Renderer renderer) {
    if (pct < 1.0) {
      nframes++;
      update();
      display(renderer);
    }
  }

  void display(Renderer renderer) {
    fill(colr);
    x = beginX + pct * distX;
    y = beginY + pct * distY;
    
    pct += this.step;
      
    if (do_trace != 0 && pct > .01 && pct < 1) {
      if (do_trace == TRACE_TO) {
        stroke(0, 255, 0, 200);
        fill(0, 255, 255);
      } else {
        stroke(255, 0, 255, 200);
        fill(255, 0, 255);
      }
      
      strokeWeight(1);
      
      float x2 = x + 10 * sin(PI * pct) * (this.step * distX);
      float y2 = y + 10 * sin(PI * pct) * (this.step * distY);
      
      line(x, y, x2, y2);
      noStroke();
      
    } else {
      float complete = ((float) nframes) / lifetimeInFrames;

      fill(100 * pct, 255, 100 * pct, 255);
      ellipse(x, y, BOOKING_RADIUS * sin(PI/2 * pct) + BOOKING_RADIUS/2, BOOKING_RADIUS * sin(PI/2 * pct) + BOOKING_RADIUS/2);
    }
  }

  void update() {
  }

  // Is the particle still useful?
  boolean isDead() {
    return this.pct >= 1.0;
  }
}


