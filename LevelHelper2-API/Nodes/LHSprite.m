//
//  LHSprite.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimation.h"

@implementation LHSprite
{
    NSTimeInterval lastTime;
    
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;

    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;
}

-(void)dealloc{

    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    LH_SAFE_RELEASE(_animations);
    activeAnimation = nil;
    LH_SUPER_DEALLOC();
}

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initSpriteNodeWithDictionary:dict
                                                               parent:prnt]);
}


- (instancetype)initSpriteNodeWithDictionary:(NSDictionary*)dict
                                      parent:(CCNode*)prnt{

    LHScene* scene = (LHScene*)[prnt scene];
    
    NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:NO]];

    NSString* plistPath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:YES]];
    
    CCTexture* texture = [scene textureWithImagePath:imagePath];
    
    CCSpriteFrame* spriteFrame = nil;
    
    NSString* spriteName = [dict objectForKey:@"spriteName"];
    if(spriteName){
        NSString* atlasName = [[plistPath lastPathComponent] stringByDeletingPathExtension];
        atlasName = [[scene relativePath] stringByAppendingPathComponent:atlasName];
        atlasName = [atlasName stringByAppendingPathExtension:@"plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:atlasName texture:texture];
        spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName];
    }
    else{
        spriteFrame = [texture createSpriteFrame];
    }

    
    
    
    
    if(self = [super initWithSpriteFrame:spriteFrame]){
        
        [prnt addChild:self];
        
        [self setName:[dict objectForKey:@"name"]];
        
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {

            #if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
            #else
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
            #endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }

        [self setColor:[dict colorForKey:@"colorOverlay"]];
        
        float alpha = [dict floatForKey:@"alpha"];
        [self setOpacity:alpha/255.0f];
        
        
        float rot = [dict floatForKey:@"rotation"];
        [self setRotation:rot];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZOrder:z];
        
        [LHUtils loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"]
                             forNode:self];
        
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setScaleX:scl.x];
        [self setScaleY:scl.y];
        
        
        CGPoint anchor = [dict pointForKey:@"anchor"];
        anchor.y = 1.0f - anchor.y;
        [self setAnchorPoint:anchor];
        
        [self setPosition:pos];

        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
                CCNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                            parent:self];
                #pragma unused (node)
            }
        }
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];
        
        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrame{
//    if(atlas){
//        SKTexture* texture = [atlas textureNamed:spriteFrame];
//        if(texture){
//            [self setTexture:texture];
//            
//            float xScale = [self xScale];
//            float yScale = [self yScale];
//            
//            [self setXScale:1];
//            [self setYScale:1];
//            
//            [self setSize:texture.size];
//            
//            [self setXScale:xScale];
//            [self setYScale:yScale];
//        }
//    }
}

-(CCNode <LHNodeProtocol>*)childNodeWithName:(NSString*)name{
    return [LHScene childNodeWithName:name
                              forNode:self];
}

-(CCNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues containsAny:any forNode:self];
}

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

- (void)visit
{
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    float dt = thisTime - lastTime;
    
    if(activeAnimation){
        [activeAnimation updateTimeWithDelta:dt];
    }
    
    [super visit];
    
    lastTime = thisTime;
}

#pragma mark - 
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}

@end
