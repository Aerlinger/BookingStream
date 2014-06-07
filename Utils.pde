PVector geodeticToCartesian(float lat, float lon) {
  float x = (lon - corrected_min_longitude) / (corrected_max_longitude - corrected_min_longitude) * width;
  float y = (corrected_max_latitude - lat) / (corrected_max_latitude - corrected_min_latitude) * height;

  return new PVector(x, y);
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

