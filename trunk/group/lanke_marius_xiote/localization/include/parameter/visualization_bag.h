/*
 * visualization_bag.h
 *
 *  Created on: Dec 6, 2015
 *      Author: marius
 */

#ifndef _VISUALIZATION_BAG_H_
#define _VISUALIZATION_BAG_H_

#include <string>

struct visualization_bag
{
	std::string frame_id, ns, mesh_resource , class_header_frame;
	float color_alpha;
	float color_r,color_g,color_b;
};



#endif /* _VISUALIZATION_BAG_H_ */
