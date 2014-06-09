class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  PVector destination;
  
  ArrayList history = new ArrayList();
  float distthresh = 60;
  
  int particleColor;
  boolean doTrace = false;
  int traceColor;
  
  ParticleSystem(int particleColor, boolean doTrace) {
    origin       = new PVector(0, 0);
    destination  = new PVector(0, 0);
    
    this.particleColor = particleColor;
    this.doTrace       = doTrace;

    particles = new ArrayList<Particle>();
  }

  void addParticle(long lifetimeInFrames, int do_trace) {
    particles.add(new Particle(origin, destination, this.particleColor, lifetimeInFrames, do_trace));
  }

  void addParticle(PVector source, PVector destination, long lifetimeInFrames, int do_trace) {
    particles.add(new Particle(source, destination, this.particleColor, lifetimeInFrames, do_trace));
  }
  
  void updateHistory(PVector newPosition) {
    history.add(0, newPosition);
  }

  void run(Renderer renderContext) {
    for (int i = particles.size ()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.step(renderContext);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

