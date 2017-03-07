
#import "CCPhysics.h"

@interface MainScene : CCScene <CCPhysicsCollisionDelegate> {
    
    CCPhysicsNode *_physicsWorld;

    CCSprite * background;
    CCSprite *_activeSprite;
    CCSprite *_playButton;

    CCSprite *_source1;
    CCSprite *_target1;
    CCSprite *_source2;
    CCSprite *_target2;
    CCSprite *_source3;
    CCSprite *_target3;    
}

@end
