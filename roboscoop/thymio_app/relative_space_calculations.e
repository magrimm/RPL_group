note
	description: "Summary description for {RELATIVE_SPACE_CALCULATIONS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RELATIVE_SPACE_CALCULATIONS

create
	make

feature

	make
		do
			initialize_constants
		end

	initialize_constants
			-- Initialize sensor_distances and sensor_angles
		do
			create sensor_distances.make(1, 7)
			across 1 |..| 5 as i
			loop
				sensor_distances.put (8.25, i.item)
			end
			across 6 |..| 7 as i
			loop
				sensor_distances.put (0.0, i.item)  -- PLACEHOLDER
			end

			create sensor_angles.make(1, 7)
			sensor_angles.put(0.672, 1)
			sensor_angles.put(0.336, 2)
			sensor_angles.put(0.0, 3)
			sensor_angles.put(-0.336, 4)
			sensor_angles.put(-0.672, 5)
			sensor_angles.put(0.0, 6)  -- PLACEHOLDER
			sensor_angles.put(0.0, 7)  --PLACEHOLDER
		end

feature -- Constants

	sensor_distances: ARRAY[REAL_64]
			-- Each sensor's distance to (0, 0).
	sensor_angles: ARRAY[REAL_64]
			-- Each sensor's angle to the positive x-axis.

feature  -- Access

	get_relative_coordinates_with_sensor(distance: REAL_64; sensor_i: INTEGER): POINT_MSG
			-- calculate the relative coordinate of a point given its distance to a sensor and the sensor's index.
			do
				Result := get_relative_coordinates(distance + sensor_distances[sensor_i], sensor_angles[sensor_i])
			end

	get_relative_coordinates(distance, angle: REAL_64): POINT_MSG
			-- calculate the relative coordinate of a point given its distance to (0, 0) and the angle.
		local
			relative_coord: POINT_MSG
		do
			-- PLACEHOLDER
			create relative_coord.make_with_values(0, 0, 0)
			Result := relative_coord
		end

	get_relative_angle(points: ARRAY[POINT_MSG]): REAL_64
			-- get the angle between the line that best fits the given points and the positive x-axis.
		do
			-- PLACEHOLDER
			Result := 0
		end
end
