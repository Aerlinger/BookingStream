class Renderer extends GenericFrameEvent {
  private HashMap<Long, ArrayList<Keyframe>> keyframes;
  private long frameNumber;
  
  public Renderer() {
    keyframes = new HashMap<Long, ArrayList<Keyframe>>();
    this.frameNumber = 0;
  }
  
  public Keyframe addKeyframe(long frame_start, long frame_end, PVector sourceLocation, PVector destinationLocation) {
    Keyframe keyframe = new Keyframe( frame_start, 
                                      frame_end, 
                                      sourceLocation,
                                      destinationLocation );

    // Keyframes are stored in the HashMap by their start time, but many events can share start time, so we need to chain "hash collisions" in an ArrayList.
    // Note: there are certainly better and faster ways of doing this, which may be worth pursuing in the future. (E.x. SortedSet, Multihash, etc...)     
    ArrayList<Keyframe> keys = keyframes.get(frame_start);
    
    if (keys == null)
      keys = new ArrayList<Keyframe>();

    keys.add(keyframe); 
    keyframes.put(frame_start, keys);
    
    return keyframe;
  }
  
  public Keyframe addKeyframeByUnixTime(long unixEpochStartTime, long unixEpochEndTime, PVector sourceLocation, PVector destinationLocation) {
    long frameStart  = unixtime_to_frame_number(unixEpochStartTime);    // Provider dot leaves booking
    long frameEnd    = unixtime_to_frame_number(unixEpochEndTime);      // Provider dot arrives back home
    
    return addKeyframe(frameStart, frameEnd, sourceLocation, destinationLocation);
  }
  
  void drawProviderLocation(PVector providerLocation) {
    fill(255, 255, 0);
    ellipse(providerLocation.x % width, providerLocation.y % height, 2, 2);
  }
  
  void drawBookingLocation(PVector bookingLocation) {
     fill(255, 0, 255);
     ellipse(bookingLocation.x % width, bookingLocation.y % height, 1, 1);
  }
  
  void spawnParticle(ParticleSystem particleSystem, PVector source, PVector destination) {
    particleSystem.addParticle(source, destination);
  }
    
  public void render(ParticleSystem particleSystem) {
    fill(0, 100);
    rect(0, 0, width, height);
  
    this.frameNumber++;
  
    ArrayList<Keyframe> keyframeChain = keyframes.get(frameNumber);
  
    particleSystem.run();
  
    for (int i=0; keyframeChain != null && i < keyframeChain.size(); ++i) {
      Keyframe keyframe = keyframeChain.get(i);
  
      PVector source_coord = geodeticToCartesian(keyframe.start_latitude, keyframe.start_longitude);
      PVector dest_coord = geodeticToCartesian(keyframe.end_latitude, keyframe.end_longitude);
  
      //drawProviderLocation(source_coord);
      //drawBookingLocation(dest_coord);
      
      spawnParticle(particleSystem, source_coord, dest_coord);
    }
  }
}
