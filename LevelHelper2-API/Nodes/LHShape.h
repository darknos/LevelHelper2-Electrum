//
//  LHShape.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"

/**
 LHShape class is used to load and display a shape from a level file.
 Users can retrieve a shape objects by calling the scene (LHScene) childNodeWithName: method.
 Note: While the class cannot yet display textures but only colored shape, I hope that in the future Apple will add this functionality into SpriteKit.
 */


@interface LHShape : CCDrawNode <CCTextureProtocol, LHNodeProtocol, LHNodeAnimationProtocol>
{
    CCTexture *_texture; // Texture used to render the shape
    
}
+ (instancetype)shapeNodeWithDictionary:(NSDictionary*)dict
                                 parent:(CCNode*)prnt;


/**
 Returns the triangle points used in the drawing of the shape and the physical body. Array with NSValue with CGPoint.
 */
-(NSMutableArray*)trianglePoints;

/**
 Returns the outline points of the shape. Array with NSValue with CGPoint.
 */
-(NSMutableArray*)outlinePoints;


@end
