class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  PVector destination;

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

  void addParticle() {
    particles.add(new Particle(origin, destination));
  }

  void addParticle(PVector source, PVector destination) {
    particles.add(new Particle(source, destination));
  }

  void run() {
    for (int i = particles.size ()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.step();
      //if (p.isDead()) {
      //  particles.remove(i);
      //}
    }
  }
}

