note
	description: "Behavior that moves the robot towards a goal position with obstacle avoidance"
	author: "Xiaote Zhu"

class
	MOVING_TO_GOAL_BEHAVIOR

inherit
	BEHAVIOUR

create
	make_with_attributes

feature {NONE} -- Initialization

	make_with_attributes (robot: separate ROBOT; planner: separate PATH_PLANNER; tangent_bug_params: TANGENT_BUG_PARAMETERS)
			-- Create current with given attributes.
		do
			path_planner := planner
			algorithm_params := tangent_bug_params

			state_sig := robot.robot_state
			odometry_sig := robot.get_odometry_signaler
			diff_drive := robot.get_diff_drive
			r_sens := robot.get_range_sensors
			r_sens_wrapper := robot.get_range_group_wrapper

			create stop_sig.make
			create moving_to_goal_sig.make

			create vleave_pub.make_with_attributes ("vleave_point")
			create cur_goal_pub.make_with_attributes ("cur_goal")
			create search_vleave_pub.make_with_attributes ("search_vleave_point")

			create controller_params.make
			create controller_parser
			controller_parser.parse_file (algorithm_params.controller_file_name, controller_params)
		end

feature -- Access

	start
			-- Start the behaviour.
		local
			a, b, c, d, e, f, g: separate MOVING_TO_GOAL_CONTROLLER
		do
			separate path_planner as pp do
				pp.search_path
			end

			create a.make (stop_sig, controller_params)
			create b.make (stop_sig, controller_params)
			create c.make (stop_sig, controller_params)
			create d.make (stop_sig, controller_params)
			create e.make (stop_sig, controller_params)

			sep_stop (stop_sig, False)
			sep_start (a, b, c, d, e)
		end

	stop
			-- Stop the behaviour.
		do
			sep_stop (stop_sig, True)
		end

feature {NONE} -- Implementation

	odometry_sig: separate ODOMETRY_SIGNALER
			-- Current state of the odometry.		

	stop_sig: separate STOP_SIGNALER
			-- Signaler for stopping the behaviour.

	state_sig: separate STATE_SIGNALER
			-- Robot current state.

	moving_to_goal_sig: separate MOVING_TO_GOAL_SIGNALER
			-- Current state of the behavior.

	diff_drive: separate DIFFERENTIAL_DRIVE
			-- Object to control robot's speed.

	r_sens: separate RANGE_GROUP
			-- Horizontal range sensors.

	r_sens_wrapper: separate RANGE_GROUP_WRAPPER
			-- Wrapper on range sensors.

	path_planner: separate PATH_PLANNER
			-- Path planner for optimal path.

	cur_goal_pub: separate POINT_MSG_PUBLISHER
				-- The current goal in go state

	search_vleave_pub : separate POINT_MSG_PUBLISHER
				-- The current searched vleave point to go to

	vleave_pub : separate POINT_MSG_PUBLISHER
				-- The vleave point transiting to

	algorithm_params: TANGENT_BUG_PARAMETERS
		-- Parameters for tangent bug algorithm.

	controller_params: CONTROLLER_PARAMETERS
		-- Parameters for pid controller.

	controller_parser: PARSER[CONTROLLER_PARAMETERS]
		-- Parser for pid controller parameters.

	sep_start (a, b, c, d, e: separate MOVING_TO_GOAL_CONTROLLER)
			-- Start controllers asynchronously.
		do
			a.repeat_until_stop_requested (
					-- Perform step 1. going to goal.
				agent a.go (state_sig,
							 moving_to_goal_sig,
							 odometry_sig,
							 stop_sig,
							 diff_drive,
							 path_planner,
							 cur_goal_pub,
							 algorithm_params))

			b.repeat_until_stop_requested (
					-- Perform step 2. following obstacle.
				agent b.follow_wall (state_sig,
									  moving_to_goal_sig,
									  odometry_sig,
									  stop_sig,
									  diff_drive,
									  r_sens,
									  r_sens_wrapper,
									  algorithm_params))

			c.repeat_until_stop_requested (
					-- Look for transition to step 3.
				agent c.look_for_vleave (state_sig,
										  moving_to_goal_sig,
										  odometry_sig,
										  stop_sig,
										  r_sens,
										  r_sens_wrapper,
										  search_vleave_pub,
										  path_planner))

			d.repeat_until_stop_requested (
					-- Perform step 3. go towards intermediate point
					-- (closer to goal than current minimum).
				agent d.transit_to_vleave (state_sig,
											moving_to_goal_sig,
											odometry_sig,
											stop_sig,
											diff_drive,
											vleave_pub,
											algorithm_params))

			e.repeat_until_stop_requested (
					-- Terminate task at goal.
				agent e.stop_when_goal_reached (state_sig,
												 odometry_sig,
												 stop_sig,
												 diff_drive,
												 algorithm_params,
												 path_planner))
		end

	sep_stop (s_sig: separate STOP_SIGNALER; val: BOOLEAN)
			-- Signal behavior for a stop.
		do
			s_sig.set_stop_requested (val)
		end

end -- class
