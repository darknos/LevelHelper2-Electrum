//
//  LHGravityArea.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGravityArea.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

@implementation LHGravityArea
{
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    BOOL _radial;
    float _force;
    CGPoint _direction;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    LH_SUPER_DEALLOC();
}


+ (instancetype)gravityAreaWithDictionary:(NSDictionary*)dict
                                   parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initGravityAreaWithDictionary:dict
                                                                parent:prnt]);
}

- (instancetype)initGravityAreaWithDictionary:(NSDictionary*)dict
                                       parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];

        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
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
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        CGPoint scl = [dict pointForKey:@"scale"];
        CGSize size = [dict sizeForKey:@"size"];
        size.width *= scl.x;
        size.height *= scl.y;
        self.contentSize = size;
        
        
        _direction = [dict pointForKey:@"direction"];
        _force = [dict floatForKey:@"force"];
        _radial = [dict intForKey:@"type"] == 1;
    }
    
    return self;
}

-(BOOL)isRadial{
    return _radial;
}

-(CGPoint)direction{
    return _direction;
}

-(float)force{
    return _force;
}

#pragma mark LHNodeProtocol Required
-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(CGRect)globalRect{
    
    CGPoint pos = [self convertToWorldSpaceAR:CGPointZero];
    
    CGSize size = self.contentSize;
    return CGRectMake(pos.x - size.width*0.5,
                      pos.y - size.height*0.5,
                      size.width,
                      size.height);
}

-(void)visit
{
    CGRect rect = [self globalRect];
    
    CCPhysicsNode* world = [[self scene] physicsNode];
    for(CCNode* node in [world children])
    {
        CCPhysicsBody* body = [node physicsBody];
        if(body && [body type] == CCPhysicsBodyTypeDynamic)
        {
            CGPoint pos = [node convertToWorldSpaceAR:CGPointZero];

            
            if(CGRectContainsPoint(rect, pos))
            {
                if([self isRadial])
                {
                    CGPoint position = [self position];
                    
                    float maxDistance = self.contentSize.width*0.5f;
                    CGFloat distance = LHDistanceBetweenPoints(position, pos);
                    
                    if(distance < maxDistance)
                    {
                        float maxForce = -[self force]*3;
                        CGFloat strength = (maxDistance - distance) / maxDistance;
                        float force = strength * maxForce;
                        CGFloat angle = atan2f(pos.y - position.y, pos.x - position.x);
                        
                        [body applyImpulse:CGPointMake(cosf(angle) * force,
                                                        sinf(angle) * force)];
                    }
                }
                else{
                    float force = [self force]*3;
                    float directionX = [self direction].x;
                    float directionY = [self direction].y;
                    
                    CGPoint pt = CGPointMake(directionX * force, directionY * force);
                    [body applyImpulse:pt];
                }
            }
        }
    }
    
    [super visit];
}



@end
