
#import "StarExplosion.h"
#import "CCTextureCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"

@implementation StarExplosion

- (id)initWithTotalParticles:(NSUInteger)p point:(CGPoint)point {
    if ((self = [super initWithTotalParticles:p])) {
        
        // _duration
        _duration = 0.1f;
        
        self.emitterMode = CCParticleSystemModeGravity;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0,0);
        
        // Gravity Mode: speed of particles
        self.speed = 70;
        self.speedVar = 40;
        
        // Gravity Mode: radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        // Gravity Mode: tagential
        self.tangentialAccel = 0;
        self.tangentialAccelVar = 0;
        
        // _angle
        _angle = 90;
        _angleVar = 360;
        
        // emitter position
        self.position = point;
        self.posVar = CGPointZero;
        
        // _life of particles
        _life = 1.0f;
        _lifeVar = 0.5f;
        
        // size, in pixels
        _startSize = 30.0f;
        _startSizeVar = 5.0f;
        _endSize = CCParticleSystemStartSizeEqualToEndSize;
        
        // emits per second
        _emissionRate = _totalParticles/_duration;
        
        // color of particles
        _startColor.r = 1.0f;
        _startColor.g = 1.0f;
        _startColor.b = 1.0f;
        _startColor.a = 1.0f;
        _startColorVar.r = 0.0f;
        _startColorVar.g = 0.0f;
        _startColorVar.b = 0.0f;
        _startColorVar.a = 0.0f;
        _endColor.r = 1.0f;
        _endColor.g = 1.0f;
        _endColor.b = 1.0f;
        _endColor.a = 0.0f;
        _endColorVar.r = 0.0f;
        _endColorVar.g = 0.0f;
        _endColorVar.b = 0.0f;
        _endColorVar.a = 0.0f;
        
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"mascot.png"];
        
        // additive
        self.blendAdditive = NO;
    }
    
    return self;
}

@end
