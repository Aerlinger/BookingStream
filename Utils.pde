PVector normalizeCoordinates(PVector coordinates) {
  //PVector coords = rotate(-1, coordinates);
  
  float xNorm = (coordinates.x - topLeft.x) / Math.abs(topLeft.x - bottomRight.x) * width;
  float yNorm = (coordinates.y - topLeft.y) / Math.abs(topLeft.y - bottomRight.y) * height;
  
  return rotate(-1, new PVector(xNorm, yNorm));
}

float deg2rad(float degrees) {
  return degrees * PI/180;
}

PVector geodeticToCartesian(float lat, float lon) {
  float latRads = (float) deg2rad(lat);//Math.toRadians(lat);
  
  float x = (float) ((180.0 + lon) / 360.0) * 100;
  float y = (float) (1 - log(tan(latRads) + 1 / cos(latRads)) / PI) / 2 * 100;
  
  return new PVector(x, y);
}

PVector rotate(float angleInRads, PVector orig) {
  //PVector center = new PVector(width, height/2);
  
  PVector center = normalizeCoordinates(geodeticToCartesian((corrected_max_latitude + corrected_min_latitude)/2, (corrected_max_longitude + corrected_min_longitude)/2));
  
  float x = center.x + (orig.x - center.x) * cos(angleInRads) - (orig.y - center.y) * sin(angleInRads);
  float y = center.y + (orig.x - center.x) * sin(angleInRads) - (orig.y - center.y) * cos(angleInRads);
  
  return new PVector(x, y);
}

void printLocation(PVector vector2, String tag) {
  println(tag, ": [", vector2.x, ", ", vector2.y, "]"); 
}

long unixtime_to_frame_number(long timestamp) {
  long seconds_since_start_of_all_bookings = (timestamp - min_time);
  int hours = secondsToHours(seconds_since_start_of_all_bookings);

  return hours * SIM_FRAMES_PER_HOUR;
}

int secondsToHours(long seconds) {
  return (int) seconds / 3600;
}

int hoursToSeconds(float hours) {
  return (int) hours * 3600;
}

