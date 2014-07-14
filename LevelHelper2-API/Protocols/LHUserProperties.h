//This file was generated automatically by LevelHelper 2
//based on the class template defined by the user.
//For more info please visit: http://www.gamedevhelper.com

#import "LHNodeProtocol.h"
#import "LHUserPropertyProtocol.h"


@interface RobotUserProperty : NSObject<LHUserPropertyProtocol>

@property float life;
@property (nonatomic, weak) id<LHNodeProtocol> connection;
@property BOOL activated;
@property (nonatomic, retain) NSString* model;

+(id) customClassInstanceWithNode:(id<LHNodeProtocol>)node;

-(id) initWithNode:(id<LHNodeProtocol>)node;

-(NSString*) className;

-(id<LHNodeProtocol>) node;

-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;

@end


@interface OtherPropertyClass : NSObject<LHUserPropertyProtocol>

@property (nonatomic, retain) NSString* memberA;
@property float memberB;
@property (nonatomic, retain) NSString* memberC;

+(id) customClassInstanceWithNode:(id<LHNodeProtocol>)node;

-(id) initWithNode:(id<LHNodeProtocol>)node;

-(NSString*) className;

-(id<LHNodeProtocol>) node;

-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;

@end

