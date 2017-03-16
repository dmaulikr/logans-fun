
#import "CCPhysics.h"

@interface MainScene : CCScene <CCPhysicsCollisionDelegate> {
    
    CCPhysicsNode *_physicsWorld;

    CCSprite * background;
    CCSprite *_activeSprite;

    NSArray *_shapeNames;
    NSArray *_sourceSprites;
    NSArray *_targetSprites;
    NSArray *_menuButtons;
}

@end
