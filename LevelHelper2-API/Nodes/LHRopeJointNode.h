//
//  LHRopeJointNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 27/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
/**
 LHRopeJointNode class is used to load a LevelHelper rope joint.
 The equivalent in Cocos2d/Chipmunk is a distance CCPhysicsJoint object with minimum distance of 0 and maximum equal with the rope length.
 */

@interface LHRopeJointNode : CCNode <LHNodeProtocol>

+(instancetype)ropeJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(CCNode*)prnt;

/**
 Returns the point where the joint is connected by the first body. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the point where the joint is connected by the second body. In scene coordinates.
 */
-(CGPoint)anchorB;

/**
 Returns whether or not this rope joint can be cut.
 */
-(BOOL)canBeCut;

/**
 If the line described by ptA and ptB intersects with the rope joint, the rope will be cut in two. This method ignores "canBeCut".
 @param ptA The start point of the line used to cut the rope. In scene coordinates.
 @param ptB The end point of the line used to cut the rope. In scene coordinates.
 */
-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB;

@end
