note
	description: "Summary description for {APP_PARAMETERS}."
	author: "Lanke Frank Tarimo Fu"
	date: "$28.10.2015$"
	revision: "$1$"

class
	ROBOT_PARAMETERS

inherit
	PARAMETERS

create
	make

feature {NONE} -- Initialization

	make

	do
		create variable_name_setter_map.make(5)
		create variable_name_getter_map.make(12)

		BEHAVIOR_FILE_NAME := "NULL"
		BEHAVIOR_NAME := "NULL"
		ROBOT_NAME := "NULL"
		TOTAL_NUMBER_OF_SENSORS := "NULL"
		NUMBER_OF_FRONT_SENSORS := "NULL"
		NUMBER_OF_BACK_SENSORS := "NULL"
		FRONT_SENSOR_DISTANCE := "NULL"
		BACK_SENSOR_DISTANCE := "NULL"
		SENSOR_ANGLE_NORTH := "NULL"
		SENSOR_ANGLE_NORTHWEST := "NULL"
		SENSOR_ANGLE_WEST := "NULL"
		SENSOR_ANGLE_NORTHEAST := "NULL"
		SENSOR_ANGLE_EAST := "NULL"

		variable_name_setter_map.put(agent set_behavior_name() , "BEHAVIOR_NAME")
		variable_name_setter_map.put(agent set_behavior_filename() , "BEHAVIOR_FILE_NAME")
		variable_name_setter_map.put(agent set_total_number_of_sensors() , "TOTAL_NUMBER_OF_SENSORS")
		variable_name_setter_map.put(agent set_number_of_front_sensors() , "NUMBER_OF_FRONT_SENSORS")
		variable_name_setter_map.put(agent set_number_of_back_sensors() , "NUMBER_OF_BACK_SENSORS")
		variable_name_setter_map.put(agent set_front_sensor_distance() , "FRONT_SENSOR_DISTANCE")
		variable_name_setter_map.put(agent set_back_sensor_distance() , "BACK_SENSOR_DISTANCE")
		variable_name_setter_map.put(agent set_sensor_angle_north() , "SENSOR_ANGLE_NORTH")
		variable_name_setter_map.put(agent set_sensor_angle_northwest() , "SENSOR_ANGLE_NORTHWEST")
		variable_name_setter_map.put(agent set_sensor_angle_west() , "SENSOR_ANGLE_WEST")
		variable_name_setter_map.put(agent set_sensor_angle_northeast() , "SENSOR_ANGLE_NORTHEAST")
		variable_name_setter_map.put(agent set_sensor_angle_east() , "SENSOR_ANGLE_EAST")
	end

feature	 -- Access

	ROBOT_NAME : STRING

	BEHAVIOR_FILE_NAME : STRING 			-- File names of the parameters to be parsed

	BEHAVIOR_NAME : STRING

	TOTAL_NUMBER_OF_SENSORS : STRING

	NUMBER_OF_FRONT_SENSORS : STRING

	NUMBER_OF_BACK_SENSORS : STRING

	FRONT_SENSOR_DISTANCE : STRING

	BACK_SENSOR_DISTANCE : STRING

	SENSOR_ANGLE_NORTH : STRING

	SENSOR_ANGLE_NORTHWEST : STRING

	SENSOR_ANGLE_WEST : STRING

	SENSOR_ANGLE_NORTHEAST : STRING

	SENSOR_ANGLE_EAST : STRING

	set_robot_name (rob : STRING)

		do
			ROBOT_NAME := rob
		end

	set_behavior_filename (file : STRING)

		do
			BEHAVIOR_FILE_NAME := file
		end

	set_behavior_name (behavior : STRING)

		do
			BEHAVIOR_NAME := behavior
		end

	set_total_number_of_sensors (number : STRING)
		do
			TOTAL_NUMBER_OF_SENSORS := number
		end

	set_number_of_front_sensors (number : STRING)
		do
			NUMBER_OF_FRONT_SENSORS := number
		end

	set_number_of_back_sensors (number : STRING)
		do
			NUMBER_OF_BACK_SENSORS := number
		end

	set_front_sensor_distance (distance : STRING)
		do
			FRONT_SENSOR_DISTANCE := distance
		end

	set_back_sensor_distance (distance : STRING)
		do
			BACK_SENSOR_DISTANCE := distance
		end

	set_sensor_angle_north (angle : STRING)
		do
			SENSOR_ANGLE_NORTH := angle
		end

	set_sensor_angle_northwest (angle : STRING)
		do
			SENSOR_ANGLE_NORTHWEST := angle
		end

	set_sensor_angle_west (angle : STRING)
		do
			SENSOR_ANGLE_WEST := angle
		end

	set_sensor_angle_northeast (angle : STRING)
		do
			SENSOR_ANGLE_NORTHEAST := angle
		end

	set_sensor_angle_east (angle : STRING)
		do
			SENSOR_ANGLE_EAST := angle
		end

end -- class
