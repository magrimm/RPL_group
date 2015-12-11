/*
 * localization_processor.cpp
 *
 *  Created on: Dec 4, 2015
 *      Author: marius
 */

#include <localization_processor.h>

localization_processor::localization_processor (ros::NodeHandle nodehandle, parameter_bag params_bag)
{
	nh = nodehandle;
	parameter = params_bag;
	// First run odometry callback
	sig_odom = true;
	sig_scan = false;

	// Create a ROS publisher
	pub = nh.advertise<geometry_msgs::PoseArray> ("particles_tf",//parameter.pub_topic_particles,
							  	  	  	  	  	  parameter.queue_size_pub_particles,
												  true);
	// Create a ROS publisher
	pub_points = nh.advertise<visualization_msgs::Marker> ("points_particle", 1, true);

	// Initialize robot control, initial and current pose
	control.odometry[0].position.x = parameter.control_odom_prev_pos_x;
	control.odometry[0].position.y = parameter.control_odom_prev_pos_y;
	control.odometry[0].position.z = parameter.control_odom_prev_pos_z;
	control.odometry[0].orientation.x = parameter.control_odom_prev_orient_x;
	control.odometry[0].orientation.y = parameter.control_odom_prev_orient_y;
	control.odometry[0].orientation.z = parameter.control_odom_prev_orient_z;
	control.odometry[0].orientation.w = parameter.control_odom_prev_orient_w;
	control.odometry[0].theta = parameter.control_odom_prev_theta;

	control.odometry[1].position.x = parameter.control_odom_cur_pos_x;
	control.odometry[1].position.y = parameter.control_odom_cur_pos_y;
	control.odometry[1].position.z = parameter.control_odom_cur_pos_z;
	control.odometry[1].orientation.x = parameter.control_odom_cur_orient_x;
	control.odometry[1].orientation.y = parameter.control_odom_cur_orient_y;
	control.odometry[1].orientation.z = parameter.control_odom_cur_orient_z;
	control.odometry[1].orientation.w = parameter.control_odom_cur_orient_w;
	control.odometry[1].theta = parameter.control_odom_cur_theta;
}

void localization_processor::Callback_map (const nav_msgs::OccupancyGrid::ConstPtr& map_msg)
{
	// Save map data and info
	map.height = map_msg->info.height;
	map.width = map_msg->info.width;
	map.resolution = map_msg->info.resolution;

	// Save the map.data as integer 0 or 100
	for (int i=0; i < map_msg->data.size(); ++i)
	{
		map.data.push_back(map_msg->data.at(i));
	}

	// Create the set of particles
	get_particles();
}

void localization_processor::Callback_odom (const nav_msgs::OdometryConstPtr& odom_msg)
{
	// After call set sig_odom == false to sequentially synchronize the callback on
	// odometry and the laser scan
	if (sig_odom == true)
	{
		// Update previous odometry and get new current odometry
//		control.odometry[0] = control.odometry[1];
		control.odometry[1].position.x = odom_msg->pose.pose.position.x;
		control.odometry[1].position.y = odom_msg->pose.pose.position.y;
		control.odometry[1].position.z = odom_msg->pose.pose.position.z;
		control.odometry[1].orientation.x = odom_msg->pose.pose.orientation.x;
		control.odometry[1].orientation.y = odom_msg->pose.pose.orientation.y;
		control.odometry[1].orientation.z = odom_msg->pose.pose.orientation.z;
		control.odometry[1].orientation.w = odom_msg->pose.pose.orientation.w;

		// Transform quaternion orientation to theta (yaw)
		tf::Quaternion q(control.odometry[1].orientation.x,
						 control.odometry[1].orientation.y,
						 control.odometry[1].orientation.z,
						 control.odometry[1].orientation.w);

		tf::Matrix3x3 m(q);
		double roll, pitch, yaw;
		m.getRPY(roll, pitch, yaw);

		control.odometry[1].theta = (float) yaw;

		//Set signaler such that callbacks of odom and scan wait for each other
		sig_scan = true;
//		sig_odom = false;
	}
}

void localization_processor::Callback_scan (const sensor_msgs::LaserScanConstPtr& scan_msg)
{
	// Wait unitl odometry first changed
	if ((control.odometry[0].position.x == control.odometry[1].position.x) && (control.odometry[0].position.y == control.odometry[1].position.y))
	{
		sig_scan = false;
//		sig_odom	 = true;
//		break;
	}

	// After call set sig_scan == false to sequentially synchronize the callback on
	// odometry and the laser scan
	if (sig_scan == true)
	{
		// Construct motion_update
		motion_update motion_upd(parameter.motion_update, parameter.distribution);

		//Construct sensor_update class
		sensor_update sensor_upd(parameter.sensor_update);

		// Construct resample
		roulette_sampling roulette_samp(parameter.resample);

		// Construct visualization class
		visualization vis(parameter.visualization);

		// Clear the weights
		weights.clear();
		norm_weights.clear();

		for (int i = 0; i < particles.size(); ++i)
		{
			// Update motion
			motion_upd.particle_motion(control, particles.at(i));

			// Sensor update: Get weights of particles
			weights.push_back(sensor_upd.get_particle_weight(scan_msg, particles.at(i), map));

			// TEST DEBUG specif weights
//			if (i == 10)
//			{
//				weights.push_back(1.0);
//			}
//			else
//			{
//				weights.push_back(0.1);
//			}
		}

		// Get approximation of the robots position
		pose robot_pose = motion_upd.approximate_robot_pose(particles);

		// Sum of weights
		float sum_of_weights = std::accumulate(weights.begin(), weights.end(), 0.0);

		// Normalize weights
		norm_weights.resize(weights.size());
		std::transform(weights.begin(), weights.end(), norm_weights.begin(), std::bind1st(std::multiplies<float>(), (1/sum_of_weights)));

		// Resample the particles
		roulette_samp.resample_distribution(particles, norm_weights);

		// Create particle visualization
		geometry_msgs::PoseArray::Ptr pose_array (new geometry_msgs::PoseArray);
		vis.visualize_particle_pose(pose_array, particles);

		// Publish the marker array of the particles
		pub.publish(pose_array);

//		------------------------------------------------------------------------------------

		// Create points seen by the particle with the highest weight
		visualization_msgs::Marker::Ptr points_particle (new visualization_msgs::Marker);
		std::vector<position3D> points;

		int most_important_particle_index = std::distance(weights.begin(), std::max_element(weights.begin(), weights.end()));
		pose most_important_particle = particles.at(most_important_particle_index);

		// Get points of most important particle
		sensor_upd.convert_sensor_measurement_to_points(scan_msg, most_important_particle, points);

		vis.visualize_points(points_particle, 0, 0.0, 1.0, 0.0, 0.01, 0.01, 0.01);

		// Add points to geometry_msgs
		for (int i = 0; i < points.size(); ++i)
		{
			geometry_msgs::Point p;

			p.x = points.at(i).x;
			p.y = points.at(i).y;
			p.z = points.at(i).z;

			points_particle->points.push_back(p);
		}

		// Publish the points seen by the particle with the highest weight
		pub_points.publish(points_particle);

//		----------------------------------------------------------------------------------------

		//Set signaler such that callbacks of odom and scan wait for each other
//		sig_scan = false;
//		sig_odom = true;

		// Update odometry control of period t-1
		control.odometry[0] = control.odometry[1];
	}
}

void localization_processor::get_particles ()
{
	int count;
	// Put particles in x-coordinate in each it_cell_x cell
//	for (int i = 130; i < 200; i += 10)//(int i = 0; i < map.width; i += parameter.it_cell_x)//
//	{
//		// Put particles in y-coordinate in each it_cell_y cell
//		for (int j = 0; j < 90; j += 10)//(int j = 0; j < map.height; j += parameter.it_cell_y)//
//		{
//			// Distribute particles with different theta orientation
//			for (float theta = 0; theta < 2*M_PI; theta += 2*M_PI/parameter.it_theta)
//			{
//				if (map.data.at(i+j*map.width) == 0)
//				{
//					pose a_particle;
//
//					// Get particle position from grid
//					a_particle.position.x = i*map.resolution;
//					a_particle.position.y = j*map.resolution;
//					a_particle.position.z = 0;
//
//					// Save theta of particles
//					a_particle.theta = theta;
//
//					// Convert theta to quaternion
//					a_particle.orientation.x = tf::createQuaternionFromYaw(theta).getX();
//					a_particle.orientation.y = tf::createQuaternionFromYaw(theta).getY();
//					a_particle.orientation.z = tf::createQuaternionFromYaw(theta).getZ();
//					a_particle.orientation.w = tf::createQuaternionFromYaw(theta).getW();
//
//					// Add particle to set of particles
//					particles.push_back(a_particle);
//
//					// Count number of particles
//					count += 1;
//				}
//			}
//		}
//	}


	// TEST DEBUG

//	for (int i = 0; i < 200; i += 20)//(int i = 0; i < map.width; i += parameter.it_cell_x)//
//	{
//		// Put particles in y-coordinate in each it_cell_y cell
//		for (int j = 0; j < 200; j += 20)//(int j = 0; j < map.height; j += parameter.it_cell_y)//
//		{
//			// Distribute particles with different theta orientation
////			for (float theta = 0; theta < 2*M_PI; theta += 2*M_PI/parameter.it_theta)
////			{
//			if (map.data.at(i+j*map.width) == 0)
//			{
//				pose a_particle;
//
//				// Get particle position from grid
//				a_particle.position.x = i*map.resolution;
//				a_particle.position.y = j*map.resolution;
//				a_particle.position.z = 0;
//
//				// Save theta of particles
//				a_particle.theta = 0.0;
//
//				// Convert theta to quaternion
//				a_particle.orientation.x = tf::createQuaternionFromYaw(a_particle.theta).getX();
//				a_particle.orientation.y = tf::createQuaternionFromYaw(a_particle.theta).getY();
//				a_particle.orientation.z = tf::createQuaternionFromYaw(a_particle.theta).getZ();
//				a_particle.orientation.w = tf::createQuaternionFromYaw(a_particle.theta).getW();
//
//				// Add particle to set of particles
//				particles.push_back(a_particle);
//
////					// Count number of particles
////					count += 1;
//			}
////			}
//		}
//	}


//	pose a_particle;
//
//	// Get particle position from grid
//	a_particle.position.x = 1.6;
//	a_particle.position.y = 0.35;
//	a_particle.position.z = 0.0;
//
//	// Save theta of particles
//	a_particle.theta = M_PI*0.68;
//
//	// Convert theta to quaternion
//	a_particle.orientation.x = tf::createQuaternionFromYaw(a_particle.theta).getX();
//	a_particle.orientation.y = tf::createQuaternionFromYaw(a_particle.theta).getY();
//	a_particle.orientation.z = tf::createQuaternionFromYaw(a_particle.theta).getZ();
//	a_particle.orientation.w = tf::createQuaternionFromYaw(a_particle.theta).getW();
//
//	// Add particle to set of particles
//	particles.push_back(a_particle);

	for (int i = 0; i < 5; ++i)
	{
		for (int j = 0; j < 5; ++j)
		{
			for (float theta = 0.0; theta < 2*M_PI; theta += 2*M_PI/16)
			{
				pose a_particle;

				// Get particle position from grid
				a_particle.position.x = 1.4 + i*0.1;//1.6;
				a_particle.position.y = 0.15 + j*0.1;//0.35;
				a_particle.position.z = 0.0;

				// Save theta of particles
				a_particle.theta = theta;//M_PI*0.68;

				// Convert theta to quaternion
				a_particle.orientation.x = tf::createQuaternionFromYaw(a_particle.theta).getX();
				a_particle.orientation.y = tf::createQuaternionFromYaw(a_particle.theta).getY();
				a_particle.orientation.z = tf::createQuaternionFromYaw(a_particle.theta).getZ();
				a_particle.orientation.w = tf::createQuaternionFromYaw(a_particle.theta).getW();

				// Add particle to set of particles
				particles.push_back(a_particle);
			}
		}
	}

}


