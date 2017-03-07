
#import "MainScene.h"
#import "OALSimpleAudio.h"
#import "CCParticles.h"
#import "CCTextureCache.h"
#import "StarExplosion.h"
#import "NSMutableArray+Shuffling.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

@implementation MainScene

#pragma mark - Setup

- (id)init {
    self = [super init];

    self.userInteractionEnabled = YES;

    // add some background colors
    CCNodeColor *topBackground = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    topBackground.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height / 2.0f);
    topBackground.position = ccp(0, 0);
    [self addChild:topBackground];
    
    CCNodeColor *bottomBackground = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f]];
    bottomBackground.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height / 2.0f);
    bottomBackground.position = ccp(0, self.contentSize.height / 2.0f);
    [self addChild:bottomBackground];
    
    // create our physics world
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    //_physicsWorld.debugDraw = YES;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    // add all the sprites
    [self addTargets];
    [self addSources];
    [self addBorders];
    
    return self;
}

#pragma mark - Sprite Creation

- (void)addBorders {

    CCSprite *left = [CCSprite spriteWithImageNamed:@"border.png"];
    left.position  = ccp(0,0);
    left.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(0,0), CGSizeMake(left.contentSize.width, self.contentSize.height)} cornerRadius:0];
    left.physicsBody.collisionGroup = @"source4Group";
    left.physicsBody.collisionType  = @"sourceCollision";
    left.physicsBody.type = CCPhysicsBodyTypeStatic;
    [_physicsWorld addChild:left];
    
    CCSprite *top = [CCSprite spriteWithImageNamed:@"border.png"];
    top.position  = ccp(0,0);
    top.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(0,0), CGSizeMake(self.contentSize.width, top.contentSize.height)} cornerRadius:0];
    top.physicsBody.collisionGroup = @"source4Group";
    top.physicsBody.collisionType  = @"sourceCollision";
    top.physicsBody.type = CCPhysicsBodyTypeStatic;
    [_physicsWorld addChild:top];
    
    CCSprite *right = [CCSprite spriteWithImageNamed:@"border.png"];
    right.position  = ccp(0,0);
    right.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(self.contentSize.width,0), CGSizeMake(right.contentSize.width, self.contentSize.height)} cornerRadius:0];
    right.physicsBody.collisionGroup = @"source4Group";
    right.physicsBody.collisionType  = @"sourceCollision";
    right.physicsBody.type = CCPhysicsBodyTypeStatic;
    [_physicsWorld addChild:right];
    
    CCSprite *bottom = [CCSprite spriteWithImageNamed:@"border.png"];
    bottom.position  = ccp(0,self.contentSize.height);
    bottom.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(0,0), CGSizeMake(self.contentSize.width, bottom.contentSize.height)} cornerRadius:0];
    bottom.physicsBody.collisionGroup = @"source4Group";
    bottom.physicsBody.collisionType  = @"sourceCollision";
    bottom.physicsBody.type = CCPhysicsBodyTypeStatic;
    [_physicsWorld addChild:bottom];
}

- (void)addSources {
    _source1 = [self addSprite:@"circle.png" groupName:@"source1Group" typeName:@"sourceCollision" isTarget:NO];
    _source2 = [self addSprite:@"square.png" groupName:@"source2Group" typeName:@"sourceCollision" isTarget:NO];
    _source3 = [self addSprite:@"triangle.png" groupName:@"source3Group" typeName:@"sourceCollision" isTarget:NO];
    
    CGFloat spritesWidth = _source1.contentSize.width + _source2.contentSize.width + _source3.contentSize.width;
    CGFloat spacing = (self.contentSize.width - spritesWidth) / 4.0f;
    CGFloat fromBottom = self.contentSize.height - ((self.contentSize.height/2.0f) / 2.0f);
    
    CGPoint posA = ccp(spacing * 1 + _source1.contentSize.width * 0 + _source1.contentSize.width / 2.0f, fromBottom);
    CGPoint posB = ccp(spacing * 2 + _source1.contentSize.width * 1 + _source1.contentSize.width / 2.0f, fromBottom);
    CGPoint posC = ccp(spacing * 3 + _source1.contentSize.width * 2 + _source1.contentSize.width / 2.0f, fromBottom);
    
    NSMutableArray *pos = [NSMutableArray new];
    [pos addObject:[NSValue valueWithCGPoint:posA]];
    [pos addObject:[NSValue valueWithCGPoint:posB]];
    [pos addObject:[NSValue valueWithCGPoint:posC]];
    
    [pos shuffle];
    
    _source1.position  = [[pos objectAtIndex:0] CGPointValue];
    _source2.position  = [[pos objectAtIndex:1] CGPointValue];
    _source3.position  = [[pos objectAtIndex:2] CGPointValue];
}

- (void)addTargets {
    _target1 = [self addSprite:@"circle-hole.png" groupName:@"sink1Group" typeName:@"sinkCollision" isTarget:YES];
    _target2 = [self addSprite:@"square-hole.png" groupName:@"sink2Group" typeName:@"sinkCollision" isTarget:YES];
    _target3 = [self addSprite:@"triangle-hole.png" groupName:@"sink3Group" typeName:@"sinkCollision" isTarget:YES];
    
    CGFloat spritesWidth = _target1.contentSize.width + _target1.contentSize.width + _target1.contentSize.width;
    CGFloat spacing = (self.contentSize.width - spritesWidth) / 4.0f;
    CGFloat fromBottom = (self.contentSize.height/2.0f) / 2.0f;
    
    CGPoint posA= ccp(spacing * 1 + _target1.contentSize.width * 0 + _target1.contentSize.width / 2.0f, fromBottom);
    CGPoint posB =ccp(spacing * 2 + _target1.contentSize.width * 1 + _target1.contentSize.width / 2.0f, fromBottom);
    CGPoint posC  = ccp(spacing * 3 + _target1.contentSize.width * 2 + _target1.contentSize.width / 2.0f, fromBottom);

    NSMutableArray *pos = [NSMutableArray new];
    [pos addObject:[NSValue valueWithCGPoint:posA]];
    [pos addObject:[NSValue valueWithCGPoint:posB]];
    [pos addObject:[NSValue valueWithCGPoint:posC]];
    
    [pos shuffle];

    _target1.position =[[pos objectAtIndex:0] CGPointValue];
    _target2.position  =[[pos objectAtIndex:1] CGPointValue];
    _target3.position =[[pos objectAtIndex:2] CGPointValue];
}

- (CCSprite *)addSprite:(NSString *)imageName groupName:(NSString *)groupName typeName:(NSString *)typeName isTarget:(BOOL)isTarget {
    CCSprite *player = [CCSprite spriteWithImageNamed:imageName];
    player.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    
    CGFloat x;
    CGFloat y;
    CGFloat hitSize;
    if(isTarget == YES) {
        hitSize = player.contentSize.width * 0.10;
        x = (player.contentSize.width / 2.0f) - (hitSize / 2.0f);
        y = 0;
        player.opacity = 0.85;
    }
    else {
        hitSize = player.contentSize.width;
        x = (player.contentSize.width / 2.0f) - (hitSize / 2.0f);
        y = (player.contentSize.height / 2.0f) - (hitSize / 2.0f);
    }
    
    player.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(x,y), CGSizeMake(hitSize, hitSize)} cornerRadius:0]; // 1
    player.physicsBody.collisionGroup = groupName; // 2
    player.physicsBody.collisionType  = typeName;
    player.physicsBody.allowsRotation = NO;
    
    [_physicsWorld addChild:player];
    return player;
}

#pragma mark - Moving Sprites

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = self.contentSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -background.contentSize.width+winSize.width);
    retval.y = self.position.y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint newPos = ccpAdd(_activeSprite.position, translation);
    if(newPos.x < 0 ||
       newPos.y < 0 ||
       newPos.x > self.contentSize.width ||
       newPos.y > self.contentSize.height) {
        return;
    }
    _activeSprite.position = newPos;
}

#pragma mark - Handling Touches

#if TARGET_OS_IPHONE

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self panForTranslation:translation];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];

    if (_playButton != nil && CGRectContainsPoint(_playButton.boundingBox, touchLocation)) {
        [self playButtonClicked:self];
        return;
    }

    if (CGRectContainsPoint(_source1.boundingBox, touchLocation)) {
        _activeSprite = _source1;
    }
    else if (CGRectContainsPoint(_source2.boundingBox, touchLocation)) {
        _activeSprite = _source2;
    }
    else if (CGRectContainsPoint(_source3.boundingBox, touchLocation)) {
        _activeSprite = _source3;
    }
    else {
        _activeSprite = nil;
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _activeSprite = nil;
}

#endif

#pragma mark - Handling Collisions

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair sourceCollision:(CCNode *)source sinkCollision:(CCNode *)sink {
    if((source == _source1 && sink == _target1) ||
       (source == _source2 && sink == _target2) ||
       (source == _source3 && sink == _target3)) {
    return [self checkCollision:source sink:sink];
    }
    else {
        return NO;
    }
}

- (BOOL)checkCollision:(CCNode *)source sink:(CCNode *)sink {
    [[OALSimpleAudio sharedInstance] playEffect:@"pop.wav"];
    
    [source removeFromParent];
    StarExplosion *explosion = [[StarExplosion node] initWithTotalParticles:50 point:sink.position];
    [self addChild:explosion];
    
    CCAction *actionRemove = [CCActionFadeTo actionWithDuration:1.0f opacity:0.10];
    [sink runAction:[CCActionSequence actionWithArray:@[actionRemove]]];
    
    [self checkForWin];
    return NO;
}

#pragma mark - Playing and Winning

-(void)checkForWin {
    if(_source1.isRunningInActiveScene == NO && _source2.isRunningInActiveScene == NO && _source3.isRunningInActiveScene == NO) {
        [[OALSimpleAudio sharedInstance] playEffect:@"cheer.wav"];
        
        CCSprite *star = [CCSprite spriteWithImageNamed:@"mascot.png"];
        star.position = CGPointMake(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
        star.opacity = 0;
        star.scale = 0;
        [self addChild:star];

        CCAction *actionFadeIn = [CCActionFadeTo actionWithDuration:1.25f opacity:1.0];
        CCAction *actionFadeOut = [CCActionFadeTo actionWithDuration:1.25f opacity:0.0];
        [star runAction:[CCActionSequence actionWithArray:@[actionFadeIn, actionFadeOut]]];
        CCAction *actionScale = [CCActionScaleTo actionWithDuration:2.5f scale:1.5f];
        [star runAction:actionScale];

        _playButton = [CCSprite spriteWithImageNamed:@"button.png"];
        _playButton.position = CGPointMake(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
        _playButton.opacity = 0.0f;
        [self addChild:_playButton];
        CCAction *actionFadeInPlay = [CCActionFadeTo actionWithDuration:0.25f opacity:1.0];
        [_playButton runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:2.5f], actionFadeInPlay]]];
        
        [_target1 removeFromParent];
        [_target2 removeFromParent];
        [_target3 removeFromParent];
    }
}

-(void)playButtonClicked:(id)sender {
    
    [_playButton removeFromParent];
    _playButton = nil;
    
    [self addSources];
    [self addTargets];
    
    [_source1 setZOrder:0];
    [_source2 setZOrder:0];
    [_source3 setZOrder:0];
}

@end
