class Particle {
  float beginX = 20.0;  // Initial x-coordinate
  float beginY = 10.0;  // Initial y-coordinate
  float endX = 570.0;   // Final x-coordinate
  float endY = 320.0;   // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move
  float distance;

  float x = 0.0;        // Current x-coordinate
  float y = 0.0;        // Current y-coordinate
  float step = 0.1;    // Size of each step along the path
  float pct = 0.0;      // Percentage traveled (0.0 to 1.0)
  int do_trace;
  int colr;
  long lifetimeInFrames = 0;
  int nframes = 0;
  
  PVector[] history;

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
    
    distance = sqrt(distX * distX + distY * distY);
    
    history = new PVector[(int) lifetimeInFrames + 1];
  }

  void step(Renderer renderer) {
    if (pct < 1.0) {
      update();
      display(renderer);
    }
  }

  void display(Renderer renderer) {
    fill(this.colr);
    
    if (do_trace != 0 && pct < 1) {
      if (do_trace == TRACE_TO)
        stroke(this.colr, 100);
      else 
        stroke(this.colr, 100);
      
      float x2 = x + 10 * distX / distance;
      float y2 = y + 10 * distY / distance;
      
      if (x < 5000 && x2 < 5000 && x > 0 && y > 0) {
        strokeWeight(2);
        line(x, y, x2, y2);
      }
      
      noStroke();
    } else {
      if(renderer.hasProviderAtLocation(new PVector(x, y))) {
        fill(125, 255, 125, 255 * sin(PI * pct));
        ellipse(x, y, BOOKING_RADIUS * sin(PI * pct) + 2, BOOKING_RADIUS * sin(PI * pct) + 2);
      } else {
        ellipse(x, y, BOOKING_RADIUS * sin(PI * pct) + 1, BOOKING_RADIUS * sin(PI * pct) + 1);
      }
    }
  }

  void update() {
    x = beginX + pct * distX;
    y = beginY + pct * distY;
    
    pct += this.step;
    
    nframes++;
  }

  // Is the particle still useful?
  boolean isDead() {
    return this.pct >= 2.0;
  }
}


