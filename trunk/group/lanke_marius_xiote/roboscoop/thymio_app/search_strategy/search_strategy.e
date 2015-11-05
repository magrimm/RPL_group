note
	description: "Strategy for finding a path from start node to goal node."
	author: "Xiaote Zhu"

deferred class
	SEARCH_STRATEGY

feature -- Access

	search_path (graph: SPATIAL_GRAPH;
					start_node, goal_node: SPATIAL_GRAPH_NODE) : LINKED_LIST [SPATIAL_GRAPH_NODE]
		-- Search a shortest path from start node to goal node.
		deferred
		end
end
