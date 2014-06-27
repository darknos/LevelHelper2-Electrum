//
//  LHUINode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHUINode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@implementation LHUINode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)uiNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initUINodeWithDictionary:dict
                                                           parent:prnt]);
}

- (instancetype)initUINodeWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        [self setPosition:CGPointZero];

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
    }
    
    return self;
}


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
