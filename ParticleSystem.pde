class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  PVector destination;
  
  ArrayList history = new ArrayList();
  float distthresh = 60;

  ParticleSystem(PVector source, PVector sink) {
    origin = source.get();
    destination = sink.get();

    particles = new ArrayList<Particle>();
  }
  
  ParticleSystem() {
    origin       = new PVector(0, 0);
    destination  = new PVector(0, 0);

    particles = new ArrayList<Particle>();
  }

  void addParticle(int colr, long lifetimeInFrames, int do_trace) {
    particles.add(new Particle(origin, destination, colr, lifetimeInFrames, do_trace));
  }

  void addParticle(PVector source, PVector destination, int colr, long lifetimeInFrames, int do_trace) {
    particles.add(new Particle(source, destination, colr, lifetimeInFrames, do_trace));
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

