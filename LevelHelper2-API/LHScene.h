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
#endif

/**
 LHScene class is used to load a level file into Cocos2d v3 engine.
 End users will have to subclass this class in order to add they're own game logic.
 */

@class LHCamera;

@interface LHScene : CCScene <LHNodeProtocol>

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;

/**
 Returns a CCTexture object that was previously loaded or a new one.
 @param imagePath The path of the image that needs to get returned as a texture.
 @return An initialized CCTexture Object.
 */
-(CCTexture*)textureWithImagePath:(NSString*)imagePath;


/**
 Returns the game world rectangle or CGRectZero if the game world rectangle is not set in the level file.
 */
-(CGRect)gameWorldRect;

/**
 Returns the informations that can be used to create an asset dynamically by specifying the file name. 
 The asset file must be in the same folder as the scene file.
 If the asset file is not found it will return nil.
 
 @param assetFileName The name of the asset that. Do not provide an extension. E.g If file is named "myAsset.lhasset.plist" then yous should pass @"myAsset.lhasset"
 @return A dictionary containing the asset information or nil.
 */
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;

@end