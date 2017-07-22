
#import "cocos2d.h"
#import "AppDelegate.h"
#import "MainScene.h"

@implementation AppController


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSMutableDictionary *cocos2dSetup = [NSMutableDictionary dictionary];
    
    NSString *scale = @"-4x";
    [CCFileUtils sharedFileUtils].suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  scale, CCFileUtilsSuffixiPad,
                                                  scale, CCFileUtilsSuffixiPadHD,
                                                  scale, CCFileUtilsSuffixiPhone,
                                                  scale, CCFileUtilsSuffixiPhoneHD,
                                                  scale, CCFileUtilsSuffixiPhone5,
                                                  scale, CCFileUtilsSuffixiPhone5HD,
                                                  scale, CCFileUtilsSuffixDefault,
                                                  nil];
    
    //[cocos2dSetup setObject:@(YES) forKey:CCSetupShowDebugStats];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    CCDirectorIOS *director = (CCDirectorIOS *)[CCDirector sharedDirector];
    CCScene *main = [MainScene new];
    [director runWithScene:main];
    
    return YES;
}

@end
