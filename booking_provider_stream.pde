ParticleSystem ps;
Renderer renderer;

int fps = 30;

// 1 second in simulation == 1 hour when sim_frames_per_hour = fps.
int sim_frames_per_hour = 1;

// Assume it takes a pro 1/2 hour to get to a job
int provider_travel_time_in_frames = sim_frames_per_hour / 2;  

long max_time; 
long min_time; 

int WIDTH = 1280;
int HEIGHT = 1024;

// TODO: lat/longs are still miscoded for many providers so we need to actually hardcode them.
float min_latitude;
float max_latitude;

float min_longitude;
float max_longitude;

float LAT_RANGE = 0.6;
float LON_RANGE = 0.6;

float corrected_min_latitude = 40.7 - LAT_RANGE / 2;
float corrected_max_latitude = 40.7 + LAT_RANGE / 2;

float corrected_min_longitude = -73.97 - LON_RANGE / 2;
float corrected_max_longitude = -73.97 + LON_RANGE / 2;



void precalculate_geospatial_boundaries(JSONArray booking_events) {
  min_time = Long.MAX_VALUE;
  max_time = -Long.MIN_VALUE;

  min_latitude = Long.MAX_VALUE;
  max_latitude = Long.MIN_VALUE;

  min_longitude = Long.MAX_VALUE;
  max_longitude = Long.MIN_VALUE;
  
  for (int i = 0; i < booking_events.size(); i++) {    
    JSONObject booking = booking_events.getJSONObject(i); 

    long time_start = booking.getInt("date_start_unix");
    long time_end = booking.getInt("date_end_unix");

    float booking_latitude   = booking.getFloat("booking_latitude");
    float booking_longitude  = booking.getFloat("booking_longitude");

    float provider_latitude  = booking.getFloat("provider_latitude");
    float provider_longitude = booking.getFloat("provider_longitude");
  
    if (time_end > max_time)
      max_time = time_end;

    if (time_start < min_time)
      min_time = time_start;

    if (booking_latitude < min_latitude || provider_latitude < min_latitude)
      min_latitude = Math.min(booking_latitude, provider_latitude);  

    if (booking_latitude > max_latitude || provider_latitude > max_latitude)
      max_latitude = Math.max(booking_latitude, provider_latitude);

    if (booking_longitude < min_longitude || provider_longitude < min_longitude)
      min_longitude = Math.min(booking_longitude, provider_longitude);  

    if (booking_longitude > max_longitude || provider_longitude > max_longitude)
      max_longitude = Math.max(booking_longitude, provider_longitude);
  }
}

void printDebugInfo() {  
  println("CORRECTED Min lat/lon, Max lat/lon", corrected_min_latitude, corrected_min_longitude, corrected_max_latitude, corrected_max_longitude);

  println("Min Time", min_time);
  println("Max Time: ", max_time);

  println("Range of hours: ", seconds_to_hours(max_time - min_time));
}


void setup() {
  JSONArray booking_events = loadJSONArray("/Users/Aerlinger/Documents/Processing/particle_system/booking_stream.json");

  ps = new ParticleSystem(); 

  precalculate_geospatial_boundaries(booking_events);

  printDebugInfo();
  
  renderer = new Renderer();
  
  for (int i = 0; i < booking_events.size(); i++) {    
    JSONObject booking = booking_events.getJSONObject(i); 

    long booking_start_time  = booking.getInt("date_start_unix");
    long booking_end_time    = booking.getInt("date_end_unix");

    float booking_latitude   = booking.getFloat("booking_latitude");
    float booking_longitude  = booking.getFloat("booking_longitude");

    float provider_latitude  = booking.getFloat("provider_latitude");
    float provider_longitude = booking.getFloat("provider_longitude");
    
    PVector booking_location   = new PVector(booking_latitude, booking_longitude);
    PVector provider_location  = new PVector(provider_latitude, provider_longitude);

    int provider_travel_time_in_seconds = 30 * 60;

    renderer.addKeyframeByUnixTime(booking_start_time, booking_start_time - provider_travel_time_in_seconds, provider_location, booking_location);
    renderer.addKeyframeByUnixTime(booking_end_time, booking_end_time + provider_travel_time_in_seconds, booking_location, provider_location);

//    long booking_start_frame_source = unixtime_to_frame_number(booking_start_time) - provider_travel_time_in_frames;   // Provider dot leaves their home
//    long booking_start_frame_dest  = unixtime_to_frame_number(booking_start_time);                                     // Provider dot arrives at booking

//    long booking_end_frame_source  = unixtime_to_frame_number(booking_end_time);                                       // Provider dot leaves booking
//    long booking_end_frame_dest    = unixtime_to_frame_number(booking_end_time) + provider_travel_time_in_frames;      // Provider dot arrives back home

    

//    Keyframe keyframe_arrive = new Keyframe( booking_start_frame_source, 
//                                             booking_start_frame_dest, 
//                                             provider_latitude, 
//                                             provider_longitude, 
//                                             booking_latitude, 
//                                             booking_longitude );
//
//    Keyframe keyframe_depart = new Keyframe( booking_end_frame_source, 
//                                             booking_end_frame_dest, 
//                                             booking_latitude, 
//                                             booking_longitude, 
//                                             provider_latitude, 
//                                             provider_longitude );
//
//    ArrayList<Keyframe> start_keys = keyframes.get(booking_start_frame_source);
//    ArrayList<Keyframe> end_keys   = keyframes.get(booking_end_frame_source);
//
//    if (start_keys == null)
//      start_keys = new ArrayList<Keyframe>();
//
//    if (end_keys == null)
//      end_keys = new ArrayList<Keyframe>();
//
//    start_keys.add(keyframe_arrive);  
//    end_keys.add(keyframe_depart);
//
//    keyframes.put(booking_start_frame_source, start_keys);
//    keyframes.put(booking_end_frame_source, end_keys);
  }

  size(WIDTH, HEIGHT);
  background(0);
  noStroke();
}

long frame_number = 0;

void draw() {
  fill(0, 100);
  rect(0, 0, WIDTH, HEIGHT);

  frame_number++;

  renderer.render(ps);
  //ArrayList<Keyframe> keyframe_list = keyframes.get(frame_number);

  ps.run();

//  for (int i=0; keyframe_list != null && i < keyframe_list.size (); ++i) {
//
//    Keyframe kf = keyframe_list.get(i);    
//
//    float start_lat = kf.start_latitude;
//    float start_lon = kf.start_longitude;
//
//    float end_lat = kf.end_latitude;
//    float end_lon = kf.end_longitude;
//
//    PVector source_coord = geodetic_to_cartesian(start_lat, start_lon);
//    PVector dest_coord = geodetic_to_cartesian(end_lat, end_lon);
//
//    float init_x = source_coord.x;
//    float init_y = source_coord.y;
//
//    float end_x = dest_coord.x;
//    float end_y = dest_coord.y;
//
//    fill(255, 255, 0);
//    ellipse(init_x % width, init_y % height, 2, 2);
//
//    fill(0, 0, 255);
//    ellipse(end_x % width, end_y % height, 1, 1);
//
//    ps.addParticle(new PVector(init_x % WIDTH, init_y % HEIGHT), new PVector(end_x % WIDTH, end_y % HEIGHT));
//  }
}

//class Runner {
//  ArrayList<> EventListeners
//  
//  public Runner() {
//  }
//  
//  public setup() {
//  }
//  
//  public () {
//  }
//  
//  private void initializeDependencies() {
//  }
//}


