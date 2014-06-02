class Renderer extends GenericFrameEvent {
  private HashMap<Long, ArrayList<Keyframe>> keyframes;
  private int frameNumber = 0; 
  
  public Renderer() {
    keyframes = new HashMap<Long, ArrayList<Keyframe>>();
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
  
  void drawProviderLocation(float x, float y) {
    fill(255, 255, 0);
    ellipse(x % width, y % height, 2, 2);
  }
  
  void drawBookingLocation(float x, float y) {
     fill(255, 0, 255);
     ellipse(x % width, y % height, 1, 1);
  }
  
  void spawnParticle(ParticleSystem particleSystem, PVector source, PVector destination) {
    particleSystem.addParticle(source, destination);
  }
    
  void render(ParticleSystem particleSystem) {
    fill(0, 100);
    rect(0, 0, width, height);
  
    frame_number++;
  
    ArrayList<Keyframe> keyframeChain = keyframes.get(frame_number);
  
    particleSystem.run();
  
    for (int i=0; keyframeChain != null && i < keyframeChain.size(); ++i) {
      Keyframe keyframe = keyframeChain.get(i);
  
      PVector source_coord = geodetic_to_cartesian(keyframe.start_latitude, keyframe.start_longitude);
      PVector dest_coord = geodetic_to_cartesian(keyframe.end_latitude, keyframe.end_longitude);
  
      float init_x = source_coord.x;
      float init_y = source_coord.y;
  
      float end_x = dest_coord.x;
      float end_y = dest_coord.y;
  
      drawProviderLocation(init_x, init_y);
      drawBookingLocation(end_x, end_y);
      
      spawnParticle(particleSystem, new PVector(init_x % width, init_y % height), new PVector(end_x % width, end_y % height));
    }
  }
}
