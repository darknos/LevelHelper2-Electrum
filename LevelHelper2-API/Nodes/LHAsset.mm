//
//  LHAsset.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAsset.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;
@end

@implementation LHAsset
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_physicsProtocolImp);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)assetWithDictionary:(NSDictionary*)dict
                             parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initAssetWithDictionary:dict
                                                          parent:prnt]);
}

- (instancetype)initAssetWithDictionary:(NSDictionary*)dict
                                 parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        LHScene* scene = (LHScene*)[self scene];
        
        NSDictionary* assetInfo = [scene assetInfoForFile:[dict objectForKey:@"assetFile"]];
        
        if(assetInfo)
        {
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];            
        }
        else{
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
        }
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

    }
    
    return self;
}

+(instancetype)createWithName:(NSString*)assetName
                assetFileName:(NSString*)fileName
                       parent:(CCNode*)prnt
{
    return LH_AUTORELEASED([[self alloc] initWithName:assetName
                                        assetFileName:fileName
                                               parent:prnt]);
}

- (instancetype)initWithName:(NSString*)newName
               assetFileName:(NSString*)fileName
                      parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:newName];
        
        LHScene* scene = (LHScene*)[prnt scene];
        
        NSDictionary* assetInfo = [scene assetInfoForFile:fileName];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithNode:self];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolWithNode:self];
        
        if(assetInfo)
        {
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];
        }
        else{
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
        }
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:nil
                                                                                                      node:self];
    }
    
    return self;
}

- (void)visit
{
    [_animationProtocolImp visit];
    [_physicsProtocolImp visit];
    
    [super visit];
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION


@end
