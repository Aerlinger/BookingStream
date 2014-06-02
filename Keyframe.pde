/**
 A Keyframe is a simple data object that encapsulates all information needed to perform a motion tween between two lat/long pairs.
 */
class Keyframe {
  public long frame_start;
  public long frame_end;

  public float start_latitude;
  public float start_longitude;

  public float end_latitude;
  public float end_longitude;

  public Keyframe(long frame_start, long frame_end, PVector source, PVector destination) { //float start_latitude, float start_longitude, float end_latitude, float end_longitude) {
    this.frame_start = frame_start;
    this.frame_end = frame_end;

    this.start_latitude   = source.x;
    this.start_longitude  = source.y;

    this.end_latitude = destination.x;
    this.end_longitude = destination.y;
  }

  String toString() {
    return "fs: " + frame_start + " fe: " + frame_end + " -> " + "(" + start_latitude + ", " + start_longitude + ")";
  }
}

