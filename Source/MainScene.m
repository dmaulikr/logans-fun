
#import "MainScene.h"
#import "OALSimpleAudio.h"
#import "CCParticles.h"
#import "CCTextureCache.h"
#import "StarExplosion.h"
#import "NSMutableArray+Shuffling.h"
#import <sys/utsname.h> // import it in your header or implementation file.

// 0,0 at bottom-left

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
    
    CGFloat targetAreaHeight = self.contentSize.height / 2.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        targetAreaHeight = self.contentSize.height / 4.0f;
    }
    
    // add some background colors
    CCNodeColor *bottomBackground = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f]];
    bottomBackground.contentSize = CGSizeMake(self.contentSize.width, targetAreaHeight);
    bottomBackground.position = ccp(0, 0);
    [self addChild:bottomBackground];
    
    CCNodeColor *topBackground = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];
    topBackground.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height - targetAreaHeight);
    topBackground.position = ccp(0, targetAreaHeight);
    [self addChild:topBackground];
    
    // create our physics world
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    //_physicsWorld.debugDraw = YES;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    // add the border
    [self addBorders];
    
    // start with the menu
    [self showMenu:0.5f];
    
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

- (void)addSources:(CGFloat)y reset:(BOOL)reset {
    
    // create the sprites for our current set of shapes
    NSMutableArray *sprites = [NSMutableArray new];
    int index = 1;
    for (NSString *shapeName in _shapeNames) {
        NSString *fileName = [NSString stringWithFormat:@"%@.png", shapeName];
        NSString *groupName = [NSString stringWithFormat:@"source%dGroup", index];
        [sprites addObject:[self addSprite:fileName groupName:groupName typeName:@"sourceCollision" isTarget:NO]];
        index += 1;
    }
    
    NSMutableArray *positions = [self calculateHorizontalSpritePositions:sprites y:y];
    [positions shuffle];
    
    // assign a position to each sprite
    for(int index = 0; index < sprites.count; index++) {
        CCSprite *sprite = sprites[index];
        sprite.position = [positions[index] CGPointValue];
    }
    
    if(reset == YES) {
        _sourceSprites = sprites;
    }
    else {
        _sourceSprites = [sprites arrayByAddingObjectsFromArray:_sourceSprites];
    }
}

- (void)addTargets {
    
    // create the sprites for our current set of shapes
    NSMutableArray *sprites = [NSMutableArray new];
    int index = 1;
    for (NSString *shapeName in _shapeNames) {
        NSString *fileName = [NSString stringWithFormat:@"%@-hole.png", shapeName];
        NSString *groupName = [NSString stringWithFormat:@"sink%dGroup", index];
        [sprites addObject:[self addSprite:fileName groupName:groupName typeName:@"sinkCollision" isTarget:YES]];
        index += 1;
    }
    
    CGFloat y = (self.contentSize.height/2.0f) / 2.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        y = (self.contentSize.height / 4.0f) / 2.0f;
    }
    
    NSMutableArray *positions = [self calculateHorizontalSpritePositions:sprites y:y];
    [positions shuffle];
    
    // assign a position to each sprite
    for(int index = 0; index < sprites.count; index++) {
        CCSprite *sprite = sprites[index];
        sprite.position = [positions[index] CGPointValue];
    }
    
    _targetSprites = sprites;
}

- (CGFloat)scaleForScreenSize {
    CGFloat scale;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenSize = MAX(screenRect.size.width, screenRect.size.height) * [[UIScreen mainScreen] scale];
    if(screenSize > 0 && screenSize <= 1136) {
        scale = 0.50; // iPhone 5/SE
    }
    else if(screenSize > 1136 && screenSize <= 1600) {
        scale = 0.65; // medium phones
    }
    else if(screenSize > 1600 && screenSize <= 2048) {
        scale = 0.75; // iPads
    }
    else {
        scale = 1.0; // iPad Pro 13", iPhone Plus
    }
    
    NSString *device = deviceName();
    if([device isEqualToString:@"iPad3,3"] == YES) {
        scale /= 2;
    }

    return scale;
}

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (CCSprite *)addSprite:(NSString *)imageName groupName:(NSString *)groupName typeName:(NSString *)typeName isTarget:(BOOL)isTarget {
    CCSprite *player = [CCSprite spriteWithImageNamed:imageName];
    player.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    player.scale = [self scaleForScreenSize];
    
    CGFloat x;
    CGFloat y;
    CGSize hitSize;
    if(isTarget == YES) {
        hitSize = CGSizeMake(player.contentSize.width * 0.10, player.contentSize.height * 0.10);
        x = (player.contentSize.width / 2.0f) - (hitSize.width / 2.0f);
        y = 0;
        player.opacity = 0.85;
    }
    else {
        hitSize = player.contentSize;
        x = (player.contentSize.width / 2.0f) - (hitSize.width / 2.0f);
        y = (player.contentSize.height / 2.0f) - (hitSize.height / 2.0f);
    }
    
    player.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){ccp(x,y), hitSize} cornerRadius:0];
    player.physicsBody.collisionGroup = groupName;
    player.physicsBody.collisionType  = typeName;
    player.physicsBody.allowsRotation = NO;
    
    [_physicsWorld addChild:player];
    return player;
}

#pragma mark - Sprite Layout

- (NSMutableArray *)calculateHorizontalSpritePositions:(NSArray *)sprites y:(CGFloat)y {
    
    // calculate the width of the sprites
    CGFloat spritesWidth = 0;
    for(CCSprite *sprite in sprites) {
        spritesWidth += (sprite.contentSize.width * sprite.scale);
    }
    
    CGFloat spacing = (self.contentSize.width - spritesWidth) / (CGFloat)(sprites.count + 1);
    
    // calculate the sprite positions along a horizontal line
    NSMutableArray *positions = [NSMutableArray new];
    CGFloat x = spacing;
    for(CCSprite *sprite in sprites) {
        [positions addObject:[NSValue valueWithCGPoint:ccp(x + (sprite.contentSize.width * sprite.scale) / 2.0f, y)]];
        x += (sprite.contentSize.width * sprite.scale);
        x += spacing;
    }
    
    return positions;
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
    
    for (CCSprite *sprite in _menuButtons) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            [self menuButtonClicked:[_menuButtons indexOfObject:sprite]];
            return;
        }
    }
    
    _activeSprite = nil;
    
    for (CCSprite *sprite in _sourceSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            _activeSprite = sprite;
        }
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _activeSprite = nil;
}

#endif

#pragma mark - Handling Collisions

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair sourceCollision:(CCNode *)source sinkCollision:(CCNode *)sink {
    for (int sourceIndex = 0; sourceIndex<_sourceSprites.count; sourceIndex++) {
        if(source == _sourceSprites[sourceIndex] && sink == _targetSprites[sourceIndex % _targetSprites.count]) {
            return [self checkCollision:source sink:sink];
        }
    }
    return NO;
}

- (BOOL)checkCollision:(CCNode *)source sink:(CCNode *)sink {
    [[OALSimpleAudio sharedInstance] playEffect:@"pop.wav"];
    
    [source removeFromParent];
    StarExplosion *explosion = [[StarExplosion node] initWithTotalParticles:50 point:sink.position];
    [self addChild:explosion];
    
    //CCAction *actionRemove = [CCActionFadeTo actionWithDuration:1.0f opacity:0.05];
    //[sink runAction:[CCActionSequence actionWithArray:@[actionRemove]]];
    
    [self checkForWin];
    return NO;
}

#pragma mark - Playing and Winning

- (void)checkForWin {
    
    BOOL anySourcesActive = NO;
    for (CCSprite *sprite in _sourceSprites) {
        if(sprite.isRunningInActiveScene == YES) {
            anySourcesActive = YES;
            break;
        }
    }
    
    if(anySourcesActive == NO) {
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
        
        for (CCSprite *target in _targetSprites) {
            [target removeFromParent];
        }
        
        [self showMenu:2.5f];
    }
}

- (void)menuButtonClicked:(NSInteger)index {
    
    for (CCSprite *sprite in _menuButtons) {
        [sprite removeFromParent];
    }
    _menuButtons = nil;
    
    switch(index) {
        case 0:
            _shapeNames = [NSMutableArray arrayWithArray:@[@"circle", @"square", @"triangle"]];
            break;
        case 1:
            _shapeNames = [NSMutableArray arrayWithArray:@[@"heart", @"hexagon", @"rectangle"]];
            break;
        case 2:
            _shapeNames = [NSMutableArray arrayWithArray:@[@"octagon", @"diamond", @"cloud"]];
            break;
        case 3:
            _shapeNames = [NSMutableArray arrayWithArray:@[@"moon", @"rounded", @"trapezoid"]];
            break;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        CGFloat targetAreaHeight = self.contentSize.height / 4.0f;
        CGFloat y = targetAreaHeight + ((self.contentSize.height - targetAreaHeight) / 3.0f) * 2;
        
        [self addSources:y reset:YES];
        
        y = targetAreaHeight + ((self.contentSize.height - targetAreaHeight) / 3.0f) * 1;
        [self addSources:y reset:NO];
        
        // randomly offset the source positions
        int lowerBound = -100;
        int upperBound = 100;
        for (CCSprite *sprite in _sourceSprites) {
            int xOffset = lowerBound + arc4random() % (upperBound - lowerBound);
            int yOffset = lowerBound + arc4random() % (upperBound - lowerBound);
            sprite.position = ccp(sprite.position.x + xOffset, sprite.position.y + yOffset);
        }
    }
    else {
        CGFloat y = self.contentSize.height - ((self.contentSize.height/2.0f) / 2.0f);
        [self addSources:y reset:YES];
    }
    
    [self addTargets];
    
    for (CCSprite *source in _sourceSprites) {
        [source setZOrder:0];
    }
}

- (void)showMenu:(CGFloat)delay {
    NSMutableArray *menuButtons = [NSMutableArray new];
    for(int index = 1; index <= 4; index++) {
        CCSprite *button = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"menu_%d.png", index]];
        button.scale = [self scaleForScreenSize];
        button.position = CGPointMake(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
        button.opacity = 0.0f;
        [self addChild:button];
        CCAction *actionFadeInPlay = [CCActionFadeTo actionWithDuration:0.25f opacity:1.0];
        [button runAction:[CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:delay], actionFadeInPlay]]];
        [menuButtons addObject:button];
    }
    
    // assign a position to each menu button sprite
    NSArray *positions = [self calculateHorizontalSpritePositions:menuButtons y:self.contentSize.height / 2.0f];
    for(int index = 0; index < menuButtons.count; index++) {
        CCSprite *sprite = menuButtons[index];
        sprite.position = [positions[index] CGPointValue];
    }
    
    _menuButtons = menuButtons;
}

@end
