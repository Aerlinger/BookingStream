import java.util.HashSet;
Renderer renderer;

int fps = 120;

// 1 second in simulation == 1 hour when SIM_FRAMES_PER_HOUR = fps. A higher value here makes the simulation seem slower
int SIM_FRAMES_PER_HOUR = 60;

// Assume it takes a pro 1/2 hour to get to a job
int provider_travel_time_in_frames = SIM_FRAMES_PER_HOUR / 2;  

long max_time; 
long min_time; 

// TODO: lat/longs are still miscoded for many providers so we need to actually hardcode them.
float min_latitude;
float max_latitude;

float min_longitude;
float max_longitude;

float LON_RANGE = 0.35;
float LAT_RANGE = 0.6 * LON_RANGE;

// BOTTOM_LEFT:
//-73.69834899902344
//40.64183303643054

//TOP RIGHT:
//-74.13093566894531
//40.896905775860006

float CENTER_LAT = 40.782;
float CENTER_LON = -73.915;

float ZOOM = 1;

//float corrected_min_latitude = CENTER_LAT - LAT_RANGE / 2;
//float corrected_max_latitude = CENTER_LAT + LAT_RANGE / 2;

//float corrected_min_longitude = CENTER_LON - LON_RANGE / 2;
//float corrected_max_longitude = CENTER_LON + LON_RANGE / 2;

// New York:
float corrected_min_latitude = 40.64183303643054; 
float corrected_max_latitude = 40.896905775860006;

float corrected_min_longitude = -74.13093566894531;
float corrected_max_longitude = -73.69834899902344;

float BOOKING_RADIUS = 3;
float BOOKING_JITTER = 1200;

// POSITIONING:
float[] CENTER = new float[]{40.7, -74};
float ROTATION = 0;//-.22; // Degrees 

PImage bg;
PImage logo;

PVector bottomRight;
PVector topLeft;


void precalculateGeospatialBoundaries(JSONArray booking_events) {
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
  
  topLeft     = geodeticToCartesian(corrected_max_latitude, corrected_min_longitude);
  bottomRight = geodeticToCartesian(corrected_min_latitude, corrected_max_longitude);
   
  center = normalizeCoordinates(geodeticToCartesian((corrected_max_latitude + corrected_min_latitude)/2, (corrected_max_longitude + corrected_min_longitude)/2));
  
  printLocation(topLeft, "TOP LEFT:");
  printLocation(bottomRight, "TOP RIGHT:");
}

boolean APPLY_JITTER = true;

final int TRACE_TO = 1;
final int NO_TRACE = 0;
final int TRACE_FROM = -1;

void processBookingEvent(JSONObject jsonObj) {
  long startTime = jsonObj.getInt("date_start_unix");
  long endTime = jsonObj.getInt("date_end_unix");
  
  float bookingLatitude   = jsonObj.getFloat("booking_latitude");
  float bookingLongitude  = jsonObj.getFloat("booking_longitude");

  float providerLatitude  = jsonObj.getFloat("provider_latitude");
  float providerLongitude = jsonObj.getFloat("provider_longitude");
  
  PVector bookingLocation = new PVector(bookingLatitude, bookingLongitude);
  PVector providerLocation = new PVector(providerLatitude, providerLongitude);
  
  String type = jsonObj.getString("type");
  
  PVector providerPos = normalizeCoordinates(geodeticToCartesian(providerLatitude, providerLongitude));
  PVector bookingPos = normalizeCoordinates(geodeticToCartesian(bookingLatitude, bookingLongitude));
  
  renderer.addProvider(new PVector(providerPos.x, providerPos.y));
  
  if(type.equals("availability_log"))
    renderer.addAvailabilityLog(startTime, bookingPos, providerPos);
  else
    renderer.addBooking(startTime, endTime, bookingPos, providerPos);
}

void parseJSON(JSONArray booking_events) {
   for (int i = 0; i < booking_events.size(); i++) {    
    JSONObject bookingEvent = booking_events.getJSONObject(i); 
    processBookingEvent(bookingEvent);
  }
}

void printDebugInfo() {  
  println("CORRECTED Min lat/lon, Max lat/lon", corrected_min_latitude, corrected_min_longitude, corrected_max_latitude, corrected_max_longitude);

  println("Min Time", min_time);
  println("Max Time: ", max_time);

  println("Range of hours: ", secondsToHours(max_time - min_time));
  
  println("Coordinate Range: ", topLeft.x, topLeft.y, ", ", bottomRight.x, bottomRight.y);
}

PVector center;

void setup() {
  smooth();
  
  int WIDTH = 1280;
  int HEIGHT = 1024;

  frameRate(fps);  
  size(WIDTH, HEIGHT);
  
  noStroke();
  textSize(18);
  
  bg = loadImage("assets/ny_bg_dark.png");
  logo = loadImage("assets/hb_logo.png");
  JSONArray booking_events = loadJSONArray("json/booking_logs_stream.json");
  
  precalculateGeospatialBoundaries(booking_events);
  printDebugInfo();
  
  renderer = new Renderer();
  parseJSON(booking_events);
  
  background(bg); 
}

void draw() {
  renderer.render();  
}

