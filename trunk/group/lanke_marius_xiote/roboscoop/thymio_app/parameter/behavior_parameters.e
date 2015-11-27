note
	description: "Parameter class BEHAVIOR_PARAMETERS."
	author: "Lanke Frank Tarimo Fu"
	date: "09.11.15"

class
	BEHAVIOR_PARAMETERS


inherit
	PARAMETERS

create
	make

feature {NONE} -- Initialization

	make
		do
			BEHAVIOR_NAME := "NULL"
			ALGORITHM_FILE_NAME := "NULL"
			ALGORITHM_NAME := "NULL"
			ROBOT_FILE_NAME := "NULL"

			create variable_name_setter_map.make(6)

			variable_name_setter_map.put(agent set_behavior_name() , "BEHAVIOR_NAME")
			variable_name_setter_map.put(agent set_algorithm_name() , "ALGORITHM_NAME")
			variable_name_setter_map.put(agent set_algorithm_filename() , "ALGORITHM_FILE_NAME")
			variable_name_setter_map.put(agent set_robot_file_name() , "ROBOT_FILE_NAME")

			variable_name_setter_map.put (agent convert_set_REAL64(? , agent set_goal_x() ), "goal_x")
			variable_name_setter_map.put (agent convert_set_REAL64(? , agent set_goal_y() ), "goal_y")
			variable_name_setter_map.put (agent convert_set_REAL64(? , agent set_vx() ), "vx")
		end



feature -- Access	

		-- File names of the parameters to be parsed
	BEHAVIOR_NAME : STRING

	ALGORITHM_FILE_NAME : STRING

	ALGORITHM_NAME : STRING

	ROBOT_FILE_NAME: STRING

	goal_x: REAL_64

	goal_y: REAL_64

	vx: REAL_64


		-- SETTERS
	set_behavior_name (beh : STRING)

		do
			BEHAVIOR_NAME := beh
		end

	set_algorithm_filename (file : STRING)

		do
			ALGORITHM_FILE_NAME := file
		end

	set_robot_file_name (file : STRING)

		do
			ROBOT_FILE_NAME := file
		end

	set_algorithm_name (alg : STRING)

		do
			ALGORITHM_NAME := alg
		end

	set_goal_x (a_val: REAL_64)
		do
			goal_x := a_val
		end

	set_goal_y (a_val: REAL_64)
		do
			goal_y := a_val
		end

	set_vx (a_val: REAL_64)
		do
			vx := a_val
		end

end -- class
