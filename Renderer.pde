

class Renderer extends GenericFrameEvent {
  private HashMap<Long, ArrayList<Keyframe>> keyframes;
  private long frameNumber;
  
  
  
  PixelShader imgProc;
 
  float noiseScale = 0.005;
  float noiseZ = 0;
  int particlesDensity = 8;
  int particleMargin = 64; 
  Particle[] particles;
  int[] currFrame;
  int[] prevFrame;
  int[] tempFrame;
  
  public Renderer() {
    this.keyframes = new HashMap<Long, ArrayList<Keyframe>>();
    this.frameNumber = 0;
    this.imgProc = new PixelShader();
    
    this.currFrame = new int[width*height];
    this.prevFrame = new int[width*height];
    this.tempFrame = new int[width*height];
    
    for(int i=0; i<width*height; i++) {
      this.currFrame[i] = color(0, 0, 0);
      this.prevFrame[i] = color(0, 0, 0);
      this.tempFrame[i] = color(0, 0, 0);
    }
    
    //this.mm = new MovieMaker(this, 1280, 720, "deformation.mov",25, MovieMaker.MOTION_JPEG_B, MovieMaker.BEST);
  }
  
  public Keyframe addKeyframe(long frame_start, long frame_end, PVector sourceLocation, PVector destinationLocation, int do_trace) {
    Keyframe keyframe = new Keyframe( frame_start, 
                                      frame_end, 
                                      sourceLocation,
                                      destinationLocation, 
                                      do_trace );

    // Keyframes are stored in the HashMap by their start time, but many events can share start time, so we need to chain "hash collisions" in an ArrayList.
    // Note: there are certainly better and faster ways of doing this, which may be worth pursuing in the future. (E.x. SortedSet, Multihash, etc...)     
    ArrayList<Keyframe> keys = keyframes.get(frame_start);
    
    if (keys == null)
      keys = new ArrayList<Keyframe>();

    keys.add(keyframe); 
    keyframes.put(frame_start, keys);
    
    return keyframe;
  }
  
  public Keyframe addKeyframeByUnixTime(long unixEpochStartTime, long unixEpochEndTime, PVector sourceLocation, PVector destinationLocation, int do_trace) {
    long frameStart  = unixtime_to_frame_number(unixEpochStartTime);    // Provider dot leaves booking
    long frameEnd    = unixtime_to_frame_number(unixEpochEndTime);      // Provider dot arrives back home
    
    return addKeyframe(frameStart, frameEnd, sourceLocation, destinationLocation, do_trace);
  }
  
  void drawProviderLocation(ParticleSystem particleSystem, PVector providerLocation, long lifetimeInFrames) {
    spawnParticle(particleSystem, providerLocation, providerLocation, color(255, 255, 255), lifetimeInFrames, 0); 
  }
  
  void drawBookingLocation(ParticleSystem particleSystem, PVector bookingLocation, long lifetimeInFrames) {
    spawnParticle(particleSystem, bookingLocation, bookingLocation, color(0, 255, 255), lifetimeInFrames, 0);  
  }
  
  void spawnParticle(ParticleSystem particleSystem, PVector source, PVector destination, int colr, long lifetimeInFrames, int do_trace) {
    particleSystem.addParticle(source, destination, colr, lifetimeInFrames, do_trace);
  }
  
  void drawBackground() {
    background(bg);
  }
  
  void drawLogo() {
    image(logo, 50, 10);
  }
  
  void drawTime() {
    text(this.frameNumber /(float) SIM_FRAMES_PER_HOUR, width - 105, 25);
  }
  
  void drawSidebar() {
    fill(0, 125);
    rect(0, 0, width, 70);
    drawLogo();
    fill(255, 255);
    
    drawTime();
  }
    
  public void render(ParticleSystem particleSystem) {
    this.frameNumber++;
  
    ArrayList<Keyframe> keyframeChain = keyframes.get(frameNumber);
    
    drawBackground();
    drawSidebar();
    
    particleSystem.run(this);
    
    for (int i=0; keyframeChain != null && i < keyframeChain.size(); ++i) {
      Keyframe keyframe = keyframeChain.get(i);
      
      PVector source_coord = new PVector(keyframe.start_latitude, keyframe.start_longitude);
      PVector dest_coord   = new PVector(keyframe.end_latitude, keyframe.end_longitude);
  
      spawnParticle(particleSystem, source_coord, dest_coord, color(255, 0, 0), keyframe.durationInFrames(), keyframe.do_trace);
      
      //drawProviderLocation(particleSystem, source_coord, (int) 2.5 *keyframe.durationInFrames());
      //drawBookingLocation(particleSystem, dest_coord, keyframe.durationInFrames());
    }
    
    if (render = true)
      saveFrame("output/frame_" + (int) frameNumber + ".png");
    //mm.addFrame();
    
    if (this.frameNumber > 400) {
      exit();
    }
  }
}

