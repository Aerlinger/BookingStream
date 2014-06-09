class Renderer {
  private HashMap<Long, ArrayList<Keyframe>> keyframes;
  private long frameNumber;
  
  PixelShader imgProc;

  // Point systems:  
  private HashSet<PVector> providerLocations;
  ParticleSystem AvailabilityLogParticles;
  ParticleSystem BookingParticles;
 
  float noiseScale = 0.005;
  float noiseZ = 0;
  int particlesDensity = 8;
  int particleMargin = 64; 
  
  int[] currFrame;
  int[] prevFrame;
  int[] tempFrame;
  
  final int PROVIDER_COLOR = color(0, 255, 0);
  int provider_travel_time_in_seconds = 30 * 60;
  int booking_offset = 0;
  
  public Renderer() {
    this.keyframes = new HashMap<Long, ArrayList<Keyframe>>();
    this.providerLocations = new HashSet<PVector>();
    
    this.frameNumber = 0;
    this.imgProc = new PixelShader();
    
    this.currFrame = new int[width*height];
    this.prevFrame = new int[width*height];
    this.tempFrame = new int[width*height];
    
    this.BookingParticles = new ParticleSystem(color(255, 0, 0), true);
    this.AvailabilityLogParticles = new ParticleSystem(color(255, 126, 0), true);
    
    for(int i=0; i<width*height; i++) {
      this.currFrame[i] = color(0, 0, 0);
      this.prevFrame[i] = color(0, 0, 0);
      this.tempFrame[i] = color(0, 0, 0);
    }
  }
  
  public Keyframe addKeyframe(long frameStart, long frameEnd, PVector sourceLocation, PVector destinationLocation, int doTrace) {
    return addKeyframe("booking", frameStart, frameEnd, sourceLocation, destinationLocation, doTrace);
  }
  
  public Keyframe addKeyframe(String type, long frameStart, long frameEnd, PVector sourceLocation, PVector destinationLocation, int doTrace) {
    Keyframe keyframe = new Keyframe( type, 
                                      frameStart, 
                                      frameEnd, 
                                      sourceLocation,
                                      destinationLocation, 
                                      doTrace );

    // Keyframes are stored in the HashMap by their start time, but many events can share start time, so we need to chain "hash collisions" in an ArrayList.
    // Note: there are certainly better and faster ways of doing this, which may be worth pursuing in the future. (E.x. SortedSet, Multihash, etc...)     
    ArrayList<Keyframe> keys = keyframes.get(frameStart);
    
    if (keys == null)
      keys = new ArrayList<Keyframe>();

    keys.add(keyframe); 
    keyframes.put(frameStart, keys);
    
    return keyframe;
  }
  
  public Keyframe addKeyframeByUnixTime(long unixEpochStartTime, long unixEpochEndTime, PVector sourceLocation, PVector destinationLocation, int doTrace) {
    long frameStart  = unixtimeToFrameNumber(unixEpochStartTime);    // Provider dot leaves booking
    long frameEnd    = unixtimeToFrameNumber(unixEpochEndTime);      // Provider dot arrives back home
    
    return addKeyframe("booking", frameStart, frameEnd, sourceLocation, destinationLocation, doTrace);
  }
  
  public Keyframe addLogKeyframeByUnixTime(long unixEpochStartTime, long unixEpochEndTime, PVector sourceLocation, PVector destinationLocation, int doTrace) {
    long frameStart  = unixtimeToFrameNumber(unixEpochStartTime);    // Provider dot leaves booking
    long frameEnd    = unixtimeToFrameNumber(unixEpochEndTime);      // Provider dot arrives back home
    
    return addKeyframe("availability_log", frameStart, frameEnd, sourceLocation, destinationLocation, doTrace);
  }
  
//  void drawProviderLocation(ParticleSystem particleSystem, PVector providerLocation, long lifetimeInFrames) {
//    spawnParticle(particleSystem, providerLocation, providerLocation, color(255, 255, 255), lifetimeInFrames, 0); 
//  }
  
  void addProvider(PVector ProviderLocation) {
    this.providerLocations.add(ProviderLocation);
  }
    
  void addBooking(long bookingStartTime, long bookingEndTime, PVector BookingLocation, PVector ProviderLocation) {
    bookingStartTime += random(-BOOKING_JITTER, BOOKING_JITTER);
    bookingEndTime += random(-BOOKING_JITTER, BOOKING_JITTER);
    
    renderer.addKeyframeByUnixTime(bookingStartTime - provider_travel_time_in_seconds, bookingStartTime, ProviderLocation, BookingLocation, TRACE_TO);
    
    // Provider stays at booking location for three hours:
    renderer.addKeyframeByUnixTime(bookingStartTime - booking_offset, bookingEndTime + booking_offset, BookingLocation, BookingLocation, NO_TRACE);
    
    // Provider travels from a booking to their home:
    renderer.addKeyframeByUnixTime(bookingEndTime, bookingEndTime + provider_travel_time_in_seconds, BookingLocation, ProviderLocation, TRACE_FROM);
  }
  
  void addAvailabilityLog(long LogStartTime, PVector BookingLocation, PVector ProviderLocation) {
    long arrival_time = LogStartTime + provider_travel_time_in_seconds/2;
    
    renderer.addLogKeyframeByUnixTime(LogStartTime, LogStartTime + provider_travel_time_in_seconds/2, BookingLocation, ProviderLocation, TRACE_TO);
    renderer.addLogKeyframeByUnixTime(LogStartTime, LogStartTime + provider_travel_time_in_seconds*3, BookingLocation, BookingLocation, NO_TRACE);
    renderer.addLogKeyframeByUnixTime(arrival_time, arrival_time + provider_travel_time_in_seconds, ProviderLocation, ProviderLocation, NO_TRACE);
  }
  
  void spawnBooking(PVector source, PVector destination, int colr, long lifetimeInFrames, int do_trace) {
    BookingParticles.addParticle(source, destination, lifetimeInFrames, do_trace);
  }
  
  void spawnAvailabilityLog(PVector source, PVector destination, int colr, long lifetimeInFrames, int do_trace) {
    AvailabilityLogParticles.addParticle(source, destination, lifetimeInFrames, do_trace);
  }
  
  void drawBookingLocation(PVector bookingLocation, long lifetimeInFrames) {
    spawnBooking(bookingLocation, bookingLocation, color(0, 255, 255), lifetimeInFrames, 0);  
  }
  
  void drawProviderLocations() {
    fill(PROVIDER_COLOR, 110);
    
    for (PVector provider : providerLocations) {
      ellipse(provider.x, provider.y, 3, 3);
    }
  }
  
  void drawBackground() {
    tint(255, 50);
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
  
  boolean hasProviderAtLocation(PVector providerLocation) {
    return this.providerLocations.contains(providerLocation);
  }
  
  public void render() {
    this.frameNumber++;
  
    ArrayList<Keyframe> keyframeChain = keyframes.get(frameNumber);
    
    drawBackground();
    drawSidebar();
    
    drawProviderLocations();
    
    this.BookingParticles.run(this);
    this.AvailabilityLogParticles.run(this);
    
    for (int i=0; keyframeChain != null && i < keyframeChain.size(); ++i) {
      Keyframe keyframe = keyframeChain.get(i);
      
      PVector source_coord = new PVector(keyframe.start_latitude, keyframe.start_longitude);
      PVector dest_coord   = new PVector(keyframe.end_latitude, keyframe.end_longitude);
  
      // TODO: This needs to be refactored it's a violation of both OCP and Liskov
      if (keyframe.type.equals("booking"))
        spawnBooking(source_coord, dest_coord, color(255, 0, 0), keyframe.durationInFrames(), keyframe.do_trace);
      else
        spawnAvailabilityLog(source_coord, dest_coord, color(255, 0, 0), keyframe.durationInFrames(), keyframe.do_trace);
    }
    
    if (false)
      saveFrame("output/frame_" + (int) frameNumber + ".png");
  }
}

