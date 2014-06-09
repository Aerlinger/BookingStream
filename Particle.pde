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
    
    history = new PVector[(int) lifetimeInFrames + 1];
  }

  void step(Renderer renderer) {
    if (pct < 1.0) {
      update();
      display(renderer);
    }
  }

  void display(Renderer renderer) {
    println("disp particle", x, y);
    fill(colr);
    
    if (do_trace != 0 && pct < 1) {
      if (do_trace == TRACE_TO) {
        stroke(0, 255, 0, 200);
        fill(0, 255, 255);
      } else {
        stroke(0, 255, 255, 200);
        fill(255, 0, 255);
      }
      
      strokeWeight(1);
      
      float x2 = x + 50 * (this.step * distX) / lifetimeInFrames;
      float y2 = y + 50 * (this.step * distY) / lifetimeInFrames;
      
      if (x < 5000 && x2 < 5000 && x > 0 && y > 0) {
        line(x, y, x2, y2);
      }
      
      // Draw trail
      for (int i=history.length-2; i>0; --i) {
        PVector p1 = history[i-1];
        PVector p2 = history[i];
        
        if(p1 != null && p2 != null) {
          //stroke(10*i % 255, 30 * i % 255, 20 * i % 255, 255 - i);
          line(p1.x, p1.y, p2.x, p2.y);
        }
      }
      
      noStroke();
    } else {
      fill(100 * pct, 255, 100 * pct, 255);
      ellipse(x, y, BOOKING_RADIUS * sin(PI/2 * pct) + 2, BOOKING_RADIUS * sin(PI/2 * pct) + 2);
    }
  }

  void update() {
    x = beginX + pct * distX;
    y = beginY + pct * distY;
    
    //history[nframes] = new PVector(x, y);
    
    pct += this.step;
    
    nframes++;
  }

  // Is the particle still useful?
  boolean isDead() {
    return false;
    //return this.pct >= 1.0;
  }
}


