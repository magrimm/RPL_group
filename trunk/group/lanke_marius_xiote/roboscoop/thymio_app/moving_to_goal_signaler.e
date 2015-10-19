note
	description: "State of MOVING_TO_GOAL_BEHAVIOR"
	author: "Xiaote Zhu"

class
	MOVING_TO_GOAL_SIGNALER

create
	make

feature

	make (goal_x, goal_y : REAL_64)
		do
			create goal_point.make_with_values (goal_x, goal_y, 0.0)
			create v_leave.make_empty
			create wall_following_start_point.make_empty

			d_min := 2^2000
		end

feature -- Access

	is_goal_reached: BOOLEAN
			-- Is the goal reached?

	is_goal_unreachable: BOOLEAN
			-- Is the goal unreachable?

	is_wall_following_start_set: BOOLEAN
			-- Is wall_following_start_point and wall_following_start_theta set yet?

	is_v_leave_found: BOOLEAN
			-- Is v_leave found yet?

	is_go_pending: BOOLEAN
			-- Has the state "go" been handled by the algorithm?

	is_wall_following: BOOLEAN
			-- Has the state "turn" been handled by the algorithm?

	is_transiting: BOOLEAN
			-- Has the state "transit" been handled by the algorithm?

	d_min: REAL_64
			-- Minimum distance between robot and the goal so far.

	goal_point: POINT_MSG
			-- goal position

	v_leave: POINT_MSG
			-- v_leave for transition state.

	wall_following_start_point: POINT_MSG
			-- start_point for wall following

	wall_following_start_theta: REAL_64
			-- start_theta for wall following

	set_is_goal_reached (a_val: BOOLEAN)
			-- Set is_goal_reached value to a_val
		do
			is_goal_reached := a_val
		end

	set_is_goal_unreachable (a_val: BOOLEAN)
			-- Set is_goal_unreachable value to a_val
		do
			is_goal_unreachable := a_val
		end

	set_is_wall_following_start_set (a_val: BOOLEAN)
			-- Set is_wall_following_start_set value to a_val
		do
			is_wall_following_start_set := a_val
		end

	set_is_v_leave_found (a_val: BOOLEAN)
			-- Set is_v_leave_found value to a_val
		do
			is_v_leave_found := a_val
		end

	set_is_go_pending (a_val: BOOLEAN)
			-- Set is_go_pending value equal to a_val.
		do
			is_go_pending := a_val
		end

	set_is_wall_following (a_val: BOOLEAN)
			-- Set is_turn_pending value equal to a_val.
		do
			is_wall_following := a_val
		end

	set_is_transiting (a_val: BOOLEAN)
			-- Set is_transiting value equal to a_val
		do
			is_transiting := a_val
		end

	set_d_min (a_val: REAL_64)
			-- Set d_min value equal to a_val
		do
			d_min := a_val
		end

	set_v_leave (a_val: separate POINT_MSG)
			-- Set v_leave value equal to a_val
		do
			create v_leave.make_from_separate (a_val)
		end

	set_wall_following_start_point (a_val: separate POINT_MSG)
			-- Set wall_following_start_point
		do
			create wall_following_start_point.make_from_separate (a_val)
		end

	set_wall_following_start_theta (a_val: REAL_64)
			-- Set wall_following_start_theta
		do
			wall_following_start_theta := a_val
		end

	clear_all_pendings
			-- Set all pending flags to False.
		do
			is_go_pending := False
			is_wall_following := False
			is_transiting := False
		end
end