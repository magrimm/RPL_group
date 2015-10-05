note
	description: "Example application of Thymio-II in Roboscoop."
	author: "Rusakov Andrey"
	date: "10.09.2014"

class
	APP

inherit
	ROS_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Create and launch the robot.
		local
			robo_node: separate ROBOSCOOP_NODE
			ros_spinner: separate ROS_SPINNER
			thymio: separate THYMIO_ROBOT
		do
			-- Initialize this application as a ROS node.
			robo_node := (create {ROS_NODE_STARTER}).roboscoop_node
			synchronize (robo_node)

			-- Listen to ROS.
			create ros_spinner.make
			start_spinning (ros_spinner)

			-- Create a robot object.
			create thymio.make

			-- Launch Thymio.
			separate thymio as t do
				t.start_discovering
			end
		end
end
