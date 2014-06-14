//
//  LHSprite.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHUserPropertyProtocol.h"
/**
 LHSprite class is used to load textured rectangles that are found in a level file.
 Users can retrieve a sprite object by calling the scene (LHScene) childNodeWithName: method.
 */

@interface LHSprite : CCSprite <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt;


-(void)setSpriteFrameWithName:(NSString*)spriteFrame;

@end
