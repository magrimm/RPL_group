note
	description: "Main class of path planning."
	author: "Xiaote Zhu"

class
	PATH_PLANNER

inherit
	GRAPH_MAKER

create
	make

feature {NONE} -- Initialization

	make (c_strategy: separate GRID_CONNECTIVITY_STRATEGY; s_strategy: SEARCH_STRATEGY; params: PATH_PLANNER_PARAMETER)
			-- Create a path planner.
		local
			count : INTEGER_32
			start_i, start_j, goal_i, goal_j : INTEGER_32
		do
			create occupancy_grid_signaler.make_with_topic ({MAP_TOPICS}.map)
			create path_publisher.make_with_topic ({MAP_TOPICS}.path)
			path_publisher.advertize (1, False)

			grid_graph := make_grid_graph (occupancy_grid_signaler, c_strategy, params.inflate_radius)

			start_i := convert_x_coord_to_x_index (occupancy_grid_signaler, params.start_x)
			start_j := convert_y_coord_to_y_index (occupancy_grid_signaler, params.start_y)
			start_node := grid_graph.node_at (start_i, start_j, 1)

			goal_i := convert_x_coord_to_x_index (occupancy_grid_signaler, params.goal_x)
			goal_j := convert_y_coord_to_y_index (occupancy_grid_signaler, params.goal_y)
			goal_node := grid_graph.node_at (goal_i, goal_j, 1)

			debug
				io.put_string ("start_i: " + start_i.out + " start_j: " + start_j.out + "%N")
				io.put_string ("goal_i: " + goal_i.out + " goal_j: " + goal_j.out + "%N")
			end

			search_strategy := s_strategy
		end

feature -- Access

	search_path
			-- Search path.
		local
			path : LINKED_LIST [SPATIAL_GRAPH_NODE]
			poses : ARRAY[POSE_STAMPED_MSG]
			header: HEADER_MSG
			pose: POSE_MSG
			pose_stamped_msg : POSE_STAMPED_MSG
			i : INTEGER
		do
			path := search_strategy.search_path (grid_graph, start_node, goal_node)
			create poses.make_filled (create {POSE_STAMPED_MSG}.make_empty, 1, path.count)

			if path.count = 0 then
				io.put_string ("NO PATH EXISTS.")
				io.put_new_line
			end

			from
				path.start
			until
				path.exhausted
			loop
				i := i + 1
				header := create {HEADER_MSG}.make_now ("/map")
				pose := create {POSE_MSG}.make_with_values (path.item.position, create {QUATERNION_MSG}.make_empty)
				pose_stamped_msg := create {POSE_STAMPED_MSG}.make_with_values (header, pose)
				poses.put (pose_stamped_msg, i)
				path.forth
			end
			path_publisher.publish (create {PATH_MSG}.make_with_values (create {HEADER_MSG}.make_now ("/map"), poses))
		end

feature {NONE}

	grid_graph : GRID_GRAPH
			-- 2D grid graph.

	occupancy_grid_signaler: separate OCCUPANCY_GRID_SIGNALER
			-- 2D grid map.

	path_publisher: ROS_PUBLISHER [PATH_MSG]
			-- Publisher object.

	start_node, goal_node : SPATIAL_GRAPH_NODE
			-- Graph nodes of the start position and the goal position

	search_strategy: SEARCH_STRATEGY
			-- Strategy used for searching a path.
end
