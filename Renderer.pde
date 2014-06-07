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
  }
  
  public Keyframe addKeyframe(long frame_start, long frame_end, PVector sourceLocation, PVector destinationLocation, boolean do_trace) {
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
  
  public Keyframe addKeyframeByUnixTime(long unixEpochStartTime, long unixEpochEndTime, PVector sourceLocation, PVector destinationLocation, boolean do_trace) {
    long frameStart  = unixtime_to_frame_number(unixEpochStartTime);    // Provider dot leaves booking
    long frameEnd    = unixtime_to_frame_number(unixEpochEndTime);      // Provider dot arrives back home
    
    return addKeyframe(frameStart, frameEnd, sourceLocation, destinationLocation, do_trace);
  }
  
  void drawProviderLocation(ParticleSystem particleSystem, PVector providerLocation, long lifetimeInFrames, boolean do_trace) {
    spawnParticle(particleSystem, providerLocation, providerLocation, color(255, 255, 0), lifetimeInFrames, false);  
  }
  
  void drawBookingLocation(ParticleSystem particleSystem, PVector bookingLocation, long lifetimeInFrames, boolean do_trace) {
    spawnParticle(particleSystem, bookingLocation, bookingLocation, color(0, 255, 255), lifetimeInFrames, false);  
  }
  
  void spawnParticle(ParticleSystem particleSystem, PVector source, PVector destination, int colr, long lifetimeInFrames, boolean do_trace) {
    particleSystem.addParticle(source, destination, colr, lifetimeInFrames, do_trace);
  }
    
  public void render(ParticleSystem particleSystem) {
    fill(255, 255);
    rect(0, 0, width, height);
  
    this.frameNumber++;
  
    ArrayList<Keyframe> keyframeChain = keyframes.get(frameNumber);
   
//    imgProc.blur(this.prevFrame, this.tempFrame, width, height);
//    imgProc.scaleBrightness(this.tempFrame, this.tempFrame, width, height, 100);
//     fill(255, 10);
//    rect(0, 0, width, height);
    
//    arraycopy(this.tempFrame, this.currFrame);
    
    particleSystem.run(this);
    
    for (int i=0; keyframeChain != null && i < keyframeChain.size(); ++i) {
      Keyframe keyframe = keyframeChain.get(i);
  
      PVector source_coord = geodeticToCartesian(keyframe.start_latitude, keyframe.start_longitude);
      PVector dest_coord = geodeticToCartesian(keyframe.end_latitude, keyframe.end_longitude);
  
      spawnParticle(particleSystem, source_coord, dest_coord, color(255, 0, 0), keyframe.durationInFrames(), keyframe.do_trace);  
  
      //drawProviderLocation(particleSystem, source_coord);
      //drawBookingLocation(particleSystem, dest_coord);
    }
    
//    imgProc.drawPixelArray(this.currFrame, 0, 0, width, height);
//    arraycopy(this.currFrame, this.prevFrame);

//    fill(255, 25);
//    rect(0, 0, width, height);
  }
}
