== BookingStream

Processing based visualization for showing an overview of where and when
bookings are made over time along with travel distances to/from
providers to each location.

=== How it works

Data is read from a JSON file exported from the database containing
the UNIX timestamps for the start and end time of each booking.
Locations are representated as lat/lon pairs for both bookings and
providers. The JSON file is read within Processing where A HashMap is
 constructed from the timestamps and the set of lat/lon pairs. The timestamps are
converted into frames where the earliest booking is at frame 0 and the last
booking would be at the last frame. Each hour of day consists of many
frames, although this can be configured in the core BookingStream class. 

The renderer increments a counter each frame of plackback. If the
current frame number is found within the keyframe Hashmap an
animation event is triggered (such as a particle spawning) for each
keyframe belonging to that frame number. Booking times are discrete and
therefore it is possible for a keyframe to have many booking start
events. Therefore, chaining via an ArrayList is used to manage multiple
booking events at a particular keyframe.


