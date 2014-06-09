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
  
  final int BOOKING_COLOR = color(255, 0, 0);
  final int PROVIDER_COLOR = color(0, 255, 0);
  final int LOG_COLOR = color(255, 125, 0);
  
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
    
    this.BookingParticles = new ParticleSystem(BOOKING_COLOR, true);
    this.AvailabilityLogParticles = new ParticleSystem(LOG_COLOR, true);
    
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
    if (!this.providerLocations.add(ProviderLocation)) {
      //if (ProviderLocation.x > -501 && ProviderLocation.x < -499 && ProviderLocation.y < 1992 && ProviderLocation.y > 1991) {
        //float providerLatitude = random(corrected_min_latitude, corrected_max_latitude);
         //float providerLongitude = random(corrected_min_longitude, corrected_max_longitude);
      
        //addProvider(normalizeCoordinates(geodeticToCartesian(providerLatitude, providerLongitude)));
        //println("COLLISION", ProviderLocation.x, ProviderLocation.y);
        
        //float providerX = random(0, 1280);
        //float providerY = random(0, 1024);
        
        //addProvider(new PVector(providerX, providerY));
      //}
    }
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
    tint(255, 5);
    background(bg);
  }
  
  void drawLogo() {
    tint(255, 255);
    image(logo, 0, 5);
  }
  
  void drawTime() {
    textSize(22);
    
    float hours_elapsed = this.frameNumber /(float) SIM_FRAMES_PER_HOUR;
    
    int hour_of_day = (int) Math.floor(hours_elapsed);
    int minutes = (int) ((hours_elapsed - hour_of_day) * 60.0);
    int days_elapsed = (int) hours_elapsed / 24;
    
    String am_pm = (hour_of_day > 12) ? "PM" : "AM";
    
    text(month_start + "/" + (int) (day_start + days_elapsed) + "/2014  " + hour_of_day % 12 + ":" + minutes + " " + am_pm, width - 235, 25);
  }
  
  void drawSidebar() {
    fill(0, 125);
    rect(0, 0, width, 70);
    drawLogo();
    fill(255, 255);
    
    drawTime();
  }
  
  void drawLegend() {
    float legendLeft = 20;
    float legendBottom = 20;
    float legendHeight = 150;
    float legendWidth = 200;
    float margin = 15; 
    textSize(16);
    
    // Background
    fill(0, 200);
    rect(legendLeft, height - legendBottom - legendHeight, legendWidth, legendHeight);
    
    fill(BOOKING_COLOR, 255);
    ellipse(legendLeft + margin, height - legendBottom - legendHeight + 30, 5, 5);
    text("Booking in progress", legendLeft + 1.5 * margin, height - legendBottom - legendHeight + 35);
    
    fill(LOG_COLOR, 255);
    ellipse(legendLeft + margin, height - legendBottom - legendHeight + 60, 5, 5);
    text("Booking made", legendLeft + 1.5 * margin, height - legendBottom - legendHeight + 65);
    
    fill(PROVIDER_COLOR, 255);
    ellipse(legendLeft + margin, height - legendBottom - legendHeight + 90, 5, 5);
    text("Provider location", legendLeft + 1.5 * margin, height - legendBottom - legendHeight + 95);
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
      
    drawLegend();
  }
}

