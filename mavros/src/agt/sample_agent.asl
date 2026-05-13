/* ArduPilot example 1: GUIDED takeoff, wait 20 s, then land. */
/* !demo_ardupilot_takeoff_wait_land.

+!demo_ardupilot_takeoff_wait_land
  <-
    .print("ArduPilot demo: switch to GUIDED, arm, take off, wait, and land.");
    .set_mode("GUIDED");
    .wait(1000);
    .arming(true);
    .wait(1500);
    .takeoff_cmd(0.0, 0.0, 0.0, 0.0, 3.0);
    .print("Takeoff command sent to 3m.");
    .wait(20000);
    .set_mode("LAND");
    .print("LAND mode requested."). */

/* End of ArduPilot example 1. */

/* ArduPilot example 2: Perception examples.
   Local MAVLink equivalent:
     LOCAL_POSITION_NED -> MAVROS /mavros/local_position/pose -> belief position(...)
   Global MAVLink equivalent:
     GLOBAL_POSITION_INT -> usually a MAVROS global-position topic, which can be
     mapped to a belief such as global_position(...) if added in sample_agent.yaml.
*/

/* Existing local-position perception already available in this agent.
   This one reacts to the MAVROS local pose belief configured in sample_agent.yaml. */
+nav_pose_local(pose(position(x(X), y(Y), z(Z)),
                 orientation(x(QX), y(QY), z(QZ), w(QW))))
  <-
    .print("Local pose from MAVROS (/mavros/local_position/pose): ",
           "x=", X, ", y=", Y, ", z=", Z,
           ", qx=", QX, ", qy=", QY, ", qz=", QZ, ", qw=", QW).

/* Example if you later add a global-position belief in sample_agent.yaml.
   One common MAVROS source is /mavros/global_position/global. */
+global_position(latitude(Lat), longitude(Lon), altitude(Alt))
  <-
    .print("Global position (GLOBAL_POSITION_INT equivalent): ",
           "lat=", Lat, ", lon=", Lon, ", alt=", Alt).

/* Optional helper if you want to explicitly request MAVROS position streams first.
   STREAM_POSITION = 6 in mavros_msgs/srv/StreamRate. */
/* !request_position_streams.

+!request_position_streams
  <-
    .set_stream_rate(6, 5, true);
    .print("Requested MAVROS STREAM_POSITION at 5 Hz."). */

/* End of ArduPilot example 2. */

/* ArduPilot example 3: High-level GUIDED body-relative repositioning.
   The helper .setpoint_local(Forward, Right, Up) already converts the body-relative
   offset into an absolute local ENU target using the current nav_pose_local(...) belief.
   For ArduPilot GUIDED, a single accepted setpoint is enough; no >= 2 Hz stream is needed.
   ArduPilot still wants an explicit takeoff command before repositioning from the ground. */
!demo_ardupilot_guided_body_relative_position.

+!demo_ardupilot_guided_body_relative_position
  <-
    .print("ArduPilot GUIDED demo using fixed-yaw high-level setpoint_local(Forward, Right, Up).");
    .set_stream_rate(6, 5, true);
    .print("Requested MAVROS STREAM_POSITION at 5 Hz.");
    .wait(2000);
    .set_mode("GUIDED");
    .wait(1000);
    .arming(true);
    .wait(2000);

    // Explicit takeoff first. Use zeroed lat/lon params as in the working ArduPilot service flow.
    .takeoff_cmd(0.0, 0.0, 0.0, 0.0, 2.5);
    .print("Takeoff command sent to 2.5 m.");
    .wait(10000);

    // Lock the relative-frame yaw after takeoff, then trust the helper to use the latest local pose belief.
    .reset_setpoint_local_reference;
    .print("Locked setpoint_local reference yaw after takeoff.");
    .wait(3000);

    .print("Command: move 2 m forward.");
    .setpoint_local(2.0, 0.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m backward to return.");
    .setpoint_local(-2.0, 0.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m right.");
    .setpoint_local(0.0, 2.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m left to return.");
    .setpoint_local(0.0, -2.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m left.");
    .setpoint_local(0.0, -2.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m right to return.");
    .setpoint_local(0.0, 2.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m backward.");
    .setpoint_local(-2.0, 0.0, 0.0);
    .wait(10000);

    .print("Command: move 2 m forward to return.");
    .setpoint_local(2.0, 0.0, 0.0);
    .wait(10000);

    .set_mode("LAND");
    .print("LAND mode requested to finish GUIDED demo.").

/* End of ArduPilot example 3. */
