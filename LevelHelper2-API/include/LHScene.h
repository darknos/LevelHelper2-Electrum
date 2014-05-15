//
//  LHScene.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

/**
 LHScene class is used to load a level file into Cocos2d v3 engine.
 End users will have to subclass this class in order to add they're game logic.
 */

@class LHCamera;

@interface LHScene : CCScene <LHNodeProtocol>

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;

/**
 Returns a SKTextureAtlas object that was previously loaded or a new one.
 */
//-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath;

/**
 Returns a CCTexture object that was previously loaded or a new one.
 */
-(CCTexture*)textureWithImagePath:(NSString*)imagePath;


/**
Returns the camera with the specifier name or nil if no camera having the specified name is found;
 */
-(LHCamera*)cameraWithName:(NSString*)name;

/**
 Returns all the cameras in the current scene.
 */
-(NSMutableArray*)cameras;

/**
 Returns the game world rectangle or CGRectZero if the game world rectangle is not set in the level file.
 */
-(CGRect)gameWorldRect;

/**
 Returns the informations that can be used to create an asset dynamically by specifying the file name. 
 The asset file must be in the same folder as the scene file.
 If the asset file is not found it will return nil.
 Do not provide an extension for the assetFileName. E.g if file is named "myAsset.lhasset.plist" the assetFileName must be "myAsset.lhasset"
 */
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;


/**
 Returns the unique identifier of this scene node.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
//-(NSArray*)tags;

/**
 Returns the user property object assigned to this object or nil.
 */
//-(id<LHUserPropertyProtocol>)userProperty;

@end
