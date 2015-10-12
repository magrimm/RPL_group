note
	description: "Summary description for {RELATIVE_SPACE_FRAMEWORK}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RELATIVE_SPACE_FRAMEWORK

feature

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
