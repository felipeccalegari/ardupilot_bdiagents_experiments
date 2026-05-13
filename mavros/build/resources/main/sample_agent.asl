/* Takeoff example */
/* !setmode.
!arm.

+!setmode
   <- 
      .set_mode("AUTO.TAKEOFF");
      .wait(1000);
      .print("Set mode to AUTO.TAKEOFF.").

+!arm
   <- 
      .arming(true);
      .wait(1000);
      .print("Armed the drone."). */

/* End of takeoff example*/

/* Mission example */
/* !start.
+!start <-
    // 1. Clear 
    .time(_, M, S, MS);
    .print("Starting clearing mission at: ", M, ":", S, ":", MS);
    .mission_clear;
    .time(_, M1, S1, MS1);
    .print("Finishing clearing mission at: ", M1, ":", S1, ":", MS1);
    .wait(1500);
    .time(_, M2, S2, MS2);
    .print("Starting mission push at: ", M2, ":", S2, ":", MS2);
    .mission_push([0], [
      [0, 22, true, true, 0, 0, 0, 0, 47.3977419, 8.5455938, 7],
      [0, 16, false, true, 0, 0, 0, 0, 47.3977569, 8.5456338, 7],
      [0, 16, false, true, 0, 0, 0, 0, 47.3977919, 8.5456438, 7],
      [0, 16, false, true, 0, 0, 0, 0, 47.3977869, 8.5456538, 7],
      [0, 16, false, true, 0, 0, 0, 0, 47.3978959, 8.5456638, 7]
      ]);
    .time(_, M3, S3, MS3);
    .print("Finishing mission push at: ", M3, ":", S3, ":", MS3);
    .wait(500);
    .time(_, M4, S4, MS4);
    .print("Starting set mode at: ", M4, ":", S4, ":", MS4);
    .set_mode("AUTO.MISSION");
    .time(_, M5, S5, MS5);
    .print("Finishing set mode at: ", M5, ":", S5, ":", MS5);
    .wait(1000);
    .time(_, M6, S6, MS6);
    .print("Starting arming at: ", M6, ":", S6, ":", MS6);
    .arming(true);
    .time(_, M7, S7, MS7);
    .print("Finishing arming at: ", M7, ":", S7, ":", MS7). */

/* End of mission example */

/* Offboard Mode example*/

/* !pub_waypoints.
+!pub_waypoints : true
   <- .setpoint_local([[0,0], 'map'],[[10.0, 5.0, 8.0], [0.0, 0.0, 0.0, 1.0]]);
      
      .wait(100);
      !pub_waypoints.

!mode.
+!mode : true
   <- .set_mode("OFFBOARD").

!arm.
+!arm : true
   <- .arming(true).  */

/* End of Offboard Mode example */

/* Battery monitoring example. Used alongside the Mission example*/
/* +battery(percentage(P))
   <- 
      .nano_time(T);
      if (P < 0.55) {
         .nano_time(T1);
         .print("Total Time after agent percepted: ", T1 - T);
         .print("Battery level getting low: ", P);
         .nano_time(T2);
         .set_mode("AUTO.LAND");
         .nano_time(T3);
         .print("Total time to enter AUTO.LAND mode: ", T3 - T2);
         .print("Entered AUTO.LAND mode");
         }
      
      .wait(5000). */

/* End of Battery monitoring example */

/* Reposition counter example
Agent sends initial takeoff to Z = 1.0m, then percepts position updates and if the Z value is within
0.35m of the target, it sends a new coordinate incrementing Z value in 1 unit until it reaches Z = 10m.
 */
/* !start.

+!start <-
    -awaiting_z(_);
    -step_transitioning(_);
    .print("Starting TAKEOFF + REPOSITION Z counter...");
    .arming(true);
    .wait(300);
    -+awaiting_z(1.0);
    .takeoff_cmd(0.0, 0.0, 47.3979710, 8.5461637, 1.0).

+position(pose(position(x(_), y(_), z(Z)), orientation(x(_), y(_), z(_), w(_))))
  : awaiting_z(Target)
    & not step_transitioning(true)
  <-
    -+step_transitioning(true);
    if (Z >= (Target - 0.35) & Z <= (Target + 0.35)) {
        -awaiting_z(_);
        .nano_time(T);
        .print(T,";",Z);
        if (Target < 10.0) {
            Next = Target + 1.0;
            -+awaiting_z(Next);
            .reposition(false, 3, 192, 0, 0, -1.0, 1.0, 0.0, 0.0, 473979710, 85461637, Next);
        } else {
            .print("Reposition Z counter finished.");
        };
    };
    -step_transitioning(_). */
/* End of Reposition counter example */


/* MAVROS parameter counter.

Starts at 1 and only sends the next increment after PX4 confirms
the last published value through /mavros/param/event.
*/
/* !demo_param_counter.

+!demo_param_counter <-
    -counter_step(_);
    -expected_param_value(_);
    -awaiting_readback(_);
    +counter_step(0);
    +expected_param_value(1.0);
    +awaiting_readback(true);
    .print("Starting MAVROS parameter counter at 1.");
    .wait(500);
    .param_set("MPC_Z_VEL_MAX_UP", 1.0).

+param_event(param_id("MPC_Z_VEL_MAX_UP"),
             value(type(_),
                   bool_value(_),
                   integer_value(_),
                   double_value(DoubleValue),
                   string_value(_),
                   byte_array_value(_),
                   bool_array_value(_),
                   integer_array_value(_),
                   double_array_value(_),
                   string_array_value(_)))
  : expected_param_value(Expected) & counter_step(Step) & awaiting_readback(true)
  <-
    if (DoubleValue == Expected) {
      -awaiting_readback(_);
      .nano_time(Timestamp);
      .print(Timestamp, ";", Step, ";", DoubleValue);
      if (Step < 100) {
        NextStep = Step + 1;
        NextValue = Expected + 1.0;
        -counter_step(_);
        +counter_step(NextStep);
        -expected_param_value(_);
        +expected_param_value(NextValue);
        +awaiting_readback(true);
        .param_set("MPC_Z_VEL_MAX_UP", NextValue);
        .wait(120)
      } else {
        .print("MAVROS parameter counter finished at value ", DoubleValue, ".");
        -counter_step(_);
        -expected_param_value(_)
      }
    }. */

/* End of MAVROS parameter counter. */

/* "High-level" Offboard example for PX4. */
/* !demo_offboard_body_relative_position.
+!demo_offboard_body_relative_position
  : not position(pose(position(x(_), y(_), z(_)), orientation(x(_), y(_), z(_), w(_))))
  <-
    .print("Waiting for local position...");
    .wait(500);
    !demo_offboard_body_relative_position.

+!demo_offboard_body_relative_position
  : position(pose(position(x(_), y(_), z(_)), orientation(x(_), y(_), z(_), w(_))))
  <-
    .print("Demo: Offboard mode using high-level setpoint local with (Forward, Right, Up).");
    -offboard_body_relative_stream_enabled;
    +offboard_body_relative_stream_enabled;
    -body_relative_target(_,_,_);
    +body_relative_target(0.0, 0.0, 2.0); // take off 2 m relative to the current pose
    !!offboard_body_relative_position_stream;
    .wait(1200);
    .set_mode("OFFBOARD");
    .wait(500);
    .arming(true);
    .wait(5000);
    -body_relative_target(_,_,_);
    +body_relative_target(0.0, -3.0, 0.0); // move 3 m to the drone's current left
    .wait(5000);
    -body_relative_target(_,_,_);
    +body_relative_target(2.0, 0.0, 0.0); // then move 2 m forward from the drone's current heading
    .wait(5000);
    -body_relative_target(_,_,_);
    +body_relative_target(2.0, 2.0, 0.0); // forward-right
    .wait(5000);
    -body_relative_target(_,_,_);
    +body_relative_target(0.0, 3.0, 0.0); // move 3 m to the drone's current right
    .wait(5000);
    -body_relative_target(_,_,_);
    +body_relative_target(-2.0, 0.0, 0.0); // move 2 m backward from the drone's current heading
    .wait(5000);
    .set_mode("AUTO.RTL");
    .wait(500);
    -offboard_body_relative_stream_enabled;
    -body_relative_target(_,_,_);
    .print("Returning to launch and finishing flight.").

+!offboard_body_relative_position_stream
  : body_relative_target(Forward, Right, Up) & offboard_body_relative_stream_enabled
  <-
    .setpoint_local(Forward, Right, Up);
    .wait(100);
    !offboard_body_relative_position_stream.

+!offboard_body_relative_position_stream
  : not offboard_body_relative_stream_enabled
  <-
    true. */
/* End of "High-level" Offboard example for PX4. */

/* ArduPilot example 1: GUIDED takeoff, wait 20 s, then land.
   This uses ArduPilot's GUIDED mode instead of PX4 OFFBOARD and does not
   require a continuous setpoint stream once the command is accepted. */
/* !demo_ardupilot_takeoff_wait_land.

+!demo_ardupilot_takeoff_wait_land
  <-
    .print("ArduPilot demo: switch to GUIDED, arm, take off, wait, and land.");
    .set_mode("GUIDED");
    .wait(1000);
    .arming(true);
    .wait(1500);
    .takeoff_cmd(0.0, 0.0, 0.0, 0.0, 3.0);
    .print("Takeoff command sent to 3 m AGL.");
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
