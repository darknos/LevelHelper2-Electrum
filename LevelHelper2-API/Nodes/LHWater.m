//
//  LHWater.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHWater.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

@interface LHWave : NSObject
{
    float wavelength, amplitude, startAmplitude, offset, increment, velocity;
    float left, right, halfWidth, middle;
    int currentStep, totalSteps;
    
    float(^decayBlock)(float, float, float, float);
    float(^clampBlock)(float, float, float, float);
    float(^waveBlock)(float);
}

@property float wavelength, amplitude, startAmplitude, offset, increment, velocity;
@property float left, right, halfWidth, middle;
@property int currentStep, totalSteps;

-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))decayBlock;
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))clampBlock;
-(void)setWaveBlock:(float(^)(float val))waveBlock;

- (float(^)(float, float, float, float))decayBlock;
- (float(^)(float, float, float, float))clampBlock;
- (float(^)(float))waveBlock;

+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d;
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d;
-(float)valueAt:(float)positionX;
-(void)step;
@end
@implementation LHWave
@synthesize wavelength, amplitude, startAmplitude, currentStep, totalSteps,
offset, increment, velocity, left, right, halfWidth, middle;
-(id)init{
    if(self = [super init]){
        waveBlock = nil;
        wavelength= 0;
        amplitude = 0;
        startAmplitude = 0;
        currentStep = 0;
        totalSteps = 0;
        offset = 0;
        increment = 0;
        decayBlock = nil;
        clampBlock = nil;
        velocity = 0;
        left = 0;
        right = 1000;
        halfWidth = 0;
        middle = 0;
    }
    return self;
}
-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))_decayBlock{
    decayBlock = _decayBlock;
}
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))_clampBlock{
    clampBlock = _clampBlock;
}
-(void)setWaveBlock:(float(^)(float val))_waveBlock{
    waveBlock = _waveBlock;
}
- (float(^)(float, float, float, float))decayBlock{
    return decayBlock;
}
- (float(^)(float, float, float, float))clampBlock{
    return clampBlock;
}
- (float(^)(float))waveBlock{
    return waveBlock;
}
+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d{
    return b + c * t  / d;
}
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d{
    return -c * cos(t/d * (M_PI / 2)) + c + b;
}
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d{
    return c * sin(t / d * (M_PI / 2)) + b;
}
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d{
    return -c / 2 * (cos(M_PI * t / d) - 1) + b;
}
-(float)valueAt:(float)position {
    if(position < left || position > right) {
        return 0.0f;
    }
    float v = (waveBlock != nil ? waveBlock((position - left + offset) / wavelength) : 1.0f) * amplitude;
    if(clampBlock != nil) {
        v = clampBlock(abs(position - middle), v, -v, halfWidth);
    }
    return v;
}
-(void) step{
    if(decayBlock != nil) {
        amplitude = decayBlock(currentStep, startAmplitude, -startAmplitude, totalSteps);
        currentStep++;
    }
    offset += increment;
    left += velocity;
    right += velocity;
    halfWidth = (right - left) / 2;
    middle = left + halfWidth;
}
@end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//! a Point with a vertex point and a color 4F
typedef struct _LH_V3F_C4F
{
	//! vertices (3F)
	ccVertex3F		vertices;
	//! colors (4F)
	ccColor4F		colors;
} _LH_V3F_C4F;

//! A Triangle of _LH_V3F_C4F
typedef struct _LH_V2F_C4B_Triangle
{
	//! Point A
	_LH_V3F_C4F a;
	//! Point B
	_LH_V3F_C4F b;
	//! Point B
	_LH_V3F_C4F c;
} _LH_V2F_C4B_Triangle;



@implementation LHWater
{
    LHNodeProtocolImpl* _nodeProtocolImp;
        
    float width, height;
    float numLines;
    NSMutableArray* waves;
    float lineWidth;

    float waterDensity;
    BOOL turbulence;
    float turbulenceL;
    float turbulenceH;
    float turbulenceV;
    float turbulenceVelocity;
    
    BOOL splashCollision;
    float splashHeight;
    float splashWidth;
    float splashTime;
    NSMutableDictionary* bodySplashes;
    
    BOOL test;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(bodySplashes);
    LH_SAFE_RELEASE(waves);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)waterNodeWithDictionary:(NSDictionary*)dict
                                 parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWaterNodeWithDictionary:dict
                                                               parent:prnt]);
}

- (instancetype)initWaterNodeWithDictionary:(NSDictionary*)dict
                                     parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        self.contentSize = [dict sizeForKey:@"size"];
        
        width = [dict floatForKey:@"width"];
        height = [dict floatForKey:@"height"];
        numLines = [dict floatForKey:@"numLines"];
        waves = [[NSMutableArray alloc] init];
        waterDensity = [dict floatForKey:@"waterDensity"];
        lineWidth = width / numLines;
        
        turbulence = [dict boolForKey:@"turbulence"];
        turbulenceL= [dict floatForKey:@"turbulenceL"];
        turbulenceH= [dict floatForKey:@"turbulenceH"];
        turbulenceV= [dict floatForKey:@"turbulenceV"];
        turbulenceVelocity = [dict floatForKey:@"turbulenceVelocity"];
        
        splashCollision = [dict boolForKey:@"splash"];
        splashHeight    = [dict floatForKey:@"splashH"];
        splashWidth     = [dict floatForKey:@"splashW"];
        splashTime      = [dict floatForKey:@"splashT"];
        
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setScaleX:scl.x];
        [self setScaleY:scl.y];

        bodySplashes = [[NSMutableDictionary alloc] init];
        
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

        
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
        
        [self setColor:[dict colorForKey:@"colorOverlay"]];
                
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
        
        
        [self createTurbulence];
    }
    
    return self;
}

-(void)createTurbulence{
    [self clearWaves];
    if(turbulence)
        [self createTurbulance:turbulenceH v:turbulenceV l:turbulenceL];
}
-(void)clearWaves{
    [waves removeAllObjects];
}
-(LHWave*)createTurbulance:(float)h v:(float)v l:(float)l
{
    LHWave* wv = LH_AUTORELEASED([[LHWave alloc] init]);
    [wv setWaveBlock:^float (float val){
        return sinf(val);
    }];
    
    wv.left = 0;
    wv.right = width;
    wv.wavelength = l;
    wv.increment = v;
    wv.amplitude = h;
    [self addWave:wv];
    return wv;
}
-(void)addWave:(LHWave*)w
{
    w.startAmplitude = w.amplitude;
    [waves addObject:w];
}

-(float)valueAt:(float)pos
{
    float y = 0;
    for(int i = 0; i < [waves count]; ++i) {
        y += [[waves objectAtIndex:i] valueAt:pos];
    }
    return y;
}


-(float)globalXToWaveX:(float)pointX{
    
    CGSize sizet = [self contentSize];
    CGPoint pos = [self position];
    
    float fullWidth = sizet.width*self.scaleX;
    float halfWidth = fullWidth*0.5;
    
    float val = (pointX - pos.x) + halfWidth;
    float percent = val/fullWidth;
    
    return width*percent;
}

-(float)waveYToGlobalY:(float)waveY{
    
    CGSize sizet = [self contentSize];
    CGPoint pos = [self position];
    
    float waveHeight = sizet.height-waveY;
    float percent = waveHeight/sizet.height;
    
    float fullHeight = sizet.height;
    float halfHeight = fullHeight*0.5;
    
    return pos.y - fullHeight*percent + halfHeight;
}


-(NSMutableArray*)createSplash:(float)pos h:(float)h w:(float)w t:(float)t
{
    LHWave* w1 = LH_AUTORELEASED([[LHWave alloc] init]);
    LHWave* w2 = LH_AUTORELEASED([[LHWave alloc] init]);
    
    [w1 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    [w2 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    
    [w1 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    [w2 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    
    [w1 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    [w2 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    
    w1.amplitude = w2.amplitude = h / 2;
    float hw = w / 2;
    w1.left = w2.left = pos - hw;
    w1.right = w2.right = w1.left + w;
    w1.totalSteps = w2.totalSteps = t;
    w1.wavelength = w2.wavelength = hw / (3 * M_PI);
    float v = hw / t;
    w1.velocity = v;
    w2.velocity = -v;
    [self addWave:w1];
    [self addWave:w2];
    return [NSMutableArray arrayWithObjects:w1, w2, nil];
}

//-(CGRect)waveRect{
//    
//    CGRect wavesRect = CGPathGetBoundingBox(self.path);
//    
//    CGPoint scenePosition = [[self scene] convertPoint:CGPointZero
//                                              fromNode:self];
//    
//    return CGRectMake(scenePosition.x - wavesRect.size.width*0.5,
//                      scenePosition.y - wavesRect.size.height*0.5,
//                      wavesRect.size.width,
//                      wavesRect.size.height);
//}

-(void)ensureCapacity:(NSUInteger)count
{
	if(_bufferCount + count > _bufferCapacity){
		_bufferCapacity += MAX(_bufferCapacity, count);
		_buffer = realloc(_buffer, _bufferCapacity*sizeof(ccV2F_C4B_T2F));
		
        //		NSLog(@"Resized vertex buffer to %d", _bufferCapacity);
	}
}

-(void)render
{
	if( _dirty ) {
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(ccV2F_C4B_T2F)*_bufferCapacity, _buffer, GL_STREAM_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		_dirty = NO;
	}
	
	ccGLBindVAO(_vao);
	glDrawArrays(GL_TRIANGLES, 0, _bufferCount);
	
	CC_INCREMENT_GL_DRAWS(1);
	
	CHECK_GL_ERROR();
}

-(void)draw
{
	ccGLBlendFunc(_blendFunc.src, _blendFunc.dst);
    
    [_shaderProgram use];
	[_shaderProgram setUniformsForBuiltins];
	
	[self render];
}


-(void)visit
{
    NSMutableArray* toRemove = [NSMutableArray array];
    for(LHWave* w in waves){
        [w step];
        
        BOOL done = [w decayBlock] != nil && (w.currentStep >= w.totalSteps);
        BOOL outBounds = (w.right <= 0 && w.velocity <= 0) || (w.left >= width && w.velocity >= 0);
        if(done || outBounds) {
            [toRemove addObject:w];
        }
    }
    [waves removeObjectsInArray:toRemove];
    

    NSMutableArray* points = [NSMutableArray array];
    for(int i = 0; i <= numLines; ++i) {
        [points addObject:[NSNumber numberWithFloat:[self valueAt:(i * lineWidth)]]];
    }

    [self clear];//clear the geometry in the node buffer
    
    
    float ox = -width*0.5;
    float oy = -height*0.5;
    
    if([points count] > 0)
    {
        NSMutableArray* trianglePts = [NSMutableArray array];

        float firstX = -width*0.5;
        float firstY = height*0.5;
        NSValue* first = LHValueWithCGPoint(CGPointMake(firstX, firstY));
        [trianglePts addObject:first];
        
        NSValue* prevDown = first;
        
        float x = -width*0.5;
        float y = [[points objectAtIndex:0] floatValue] + oy;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, y))];
        
        NSValue* prev = nil;
        for(int i = 1; i < (int)[points count]; ++i)
        {
            x = lineWidth*i - width*0.5;
            y = [[points objectAtIndex:i] floatValue] - height*0.5;
            
            if(prev){
                [trianglePts addObject:first];
                [trianglePts addObject:prev];
            }
            NSValue* curValue = LHValueWithCGPoint(CGPointMake(x, y));
            [trianglePts addObject:curValue];

            [trianglePts addObject:curValue];
            
            
            NSValue* down = LHValueWithCGPoint(CGPointMake(x, firstY));
            [trianglePts addObject:down];
            [trianglePts addObject:prevDown];
            prevDown = down;
            first = down;
            
            prev = curValue;
        }
        
        x = width*0.5;
        y = height*0.5;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, y))];
        
        x = width + ox;
        y = -height*0.5;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, y))];
        [trianglePts addObject:first];
        
        
        [self ensureCapacity:[trianglePts count]];
        for(int i = 0; i < [trianglePts count]; i+=3)
        {
            NSValue* valA = [trianglePts objectAtIndex:i];
            NSValue* valB = [trianglePts objectAtIndex:i+1];
            NSValue* valC = [trianglePts objectAtIndex:i+2];
            
            CCColor* color = [self color];
            
            CGPoint posA =  CGPointFromValue(valA);
            posA.y = -posA.y;

            
            CGPoint posB = CGPointFromValue(valB);
            posB.y = -posB.y;

            
            CGPoint posC = CGPointFromValue(valC);
            posC.y = -posC.y;
            
            
            ccV2F_C4B_T2F a = {{posA.x, posA.y}, {color.red*255.0f, color.green*255.0f, color.blue*255.0f, color.alpha*255.0f}};
            ccV2F_C4B_T2F b = {{posB.x, posB.y}, {color.red*255.0f, color.green*255.0f, color.blue*255.0f, color.alpha*255.0f}};
            ccV2F_C4B_T2F c = {{posC.x, posC.y}, {color.red*255.0f, color.green*255.0f, color.blue*255.0f, color.alpha*255.0f}};
            
            ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
            triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
            
            _bufferCount += 3;
        }
    }

    
    [super visit];

//    CGRect wavesRect = [self waveRect];
//
    
    CCPhysicsNode* world = [[self scene] physicsNode];
//    CGPoint gravity = [world gravity];


    for(CCNode* node in [world children])
    {
        CCPhysicsBody* body = [node physicsBody];
        if(body && [body type] == CCPhysicsBodyTypeDynamic)
        {
            CGPoint pos = [node position];
            
            float x = pos.x;
            float y = [self valueAt:[self globalXToWaveX:x]];
            y = [self waveYToGlobalY:y];
            
            if(pos.y < self.position.y + [self contentSize].height*0.5 + y)
            {
                
//                CGPoint buoyancyForce = CGPointMake(10*waterDensity*gravity.x, waterDensity*500.0f);
  
//                CGPoint curForce = body.force;
//                CGPoint buoyancyForce = CGPointMake(10*waterDensity*gravity.x, (-2.1*gravity.y));
                
//                [body applyImpulse:buoyancyForce];
                
//                NSLog(@"BODY FORCE %f", body.force.y);
                
                
//                if(turbulence){
//                    float vdirection = 1.0f;
//                    if(turbulenceV > 0)
//                        vdirection = -1.0f;
//                    
//                    CGPoint vector = CGPointMake(vdirection*turbulenceVelocity/10.0f, 0);
//                    [body applyImpulse:vector];
//                }
                
                
                NSString* hadSplash = [bodySplashes objectForKey:[NSString stringWithFormat:@"%p", body]];
                if(hadSplash == nil && splashCollision){

                    float splashX = [self globalXToWaveX:x];
                    
                    NSArray* splashes = [self createSplash:splashX
                                                         h:splashHeight*node.scaleY
                                                         w:splashWidth*node.scaleX
                                                         t:splashTime];
                    int i = 0;
                    for(LHWave* wave in splashes){
                        [wave step];
                        ++i;
                        // if(i > 2)break;
                    }
                    [bodySplashes setObject:[NSNumber numberWithBool:YES]
                                     forKey:[NSString stringWithFormat:@"%p", body]];
                }
            }
            else{
                [bodySplashes removeObjectForKey:[NSString stringWithFormat:@"%p", body]];
            }

        }
    }
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
