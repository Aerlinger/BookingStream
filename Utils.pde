PVector geodetic_to_cartesian(float lat, float lon) {
  float x = (lon - corrected_min_longitude) / (corrected_max_longitude - corrected_min_longitude) * width;
  float y = (corrected_max_latitude - lat) / (corrected_max_latitude - corrected_min_latitude) * height;

  return new PVector(x, y);
}

long unixtime_to_frame_number(long timestamp) {
  long seconds_since_start_of_all_bookings = (timestamp - min_time);
  int hours = seconds_to_hours(seconds_since_start_of_all_bookings);

  return hours * sim_frames_per_hour;
}

int seconds_to_hours(long seconds) {
  return (int) seconds / 3600;
}

