PVector normalizeCoordinates(PVector coordinates) {  
  float xNorm = (coordinates.x - topLeft.x) / Math.abs(topLeft.x - bottomRight.x) * width * ZOOM;
  float yNorm = (coordinates.y - topLeft.y) / Math.abs(topLeft.y - bottomRight.y) * height * ZOOM;
  
  return rotation(ROTATION, new PVector(xNorm, yNorm));
}

float deg2rad(float degrees) {
  return degrees * PI/180;
}

PVector geodeticToCartesian(float lat, float lon) {
  float latRads = (float) deg2rad(lat);//Math.toRadians(lat);
  
  float x = (float) ((180.0 + lon) / 360.0);
  float y = (float) (1 - log(tan(latRads) + 1 / cos(latRads)) / PI) / 2;
  
  return new PVector(x, y);
}

PVector rotation(float angleInRads, PVector orig) {
  float x = width/2  + (orig.x - width/2) * cos(angleInRads) - (orig.y - height/2) * sin(angleInRads);
  float y = height/2 + (orig.x - width/2) * sin(angleInRads) + (orig.y - height/2) * cos(angleInRads);
  
  return new PVector(x, y);
}

void printLocation(PVector vector2, String tag) {
  println(tag, ": [", vector2.x, ", ", vector2.y, "]"); 
}

long unixtimeToFrameNumber(long timestamp) {
  long seconds_since_start_of_all_bookings = (timestamp - min_time);
  float hours = secondsToHours(seconds_since_start_of_all_bookings);

  return (long) (hours * SIM_FRAMES_PER_HOUR);
}

float secondsToHours(long seconds) {
  return (float) seconds / 3600.0;
}

int hoursToSeconds(float hours) {
  return (int) hours * 3600;
}

