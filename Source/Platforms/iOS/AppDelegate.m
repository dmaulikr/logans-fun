
#import "cocos2d.h"
#import "AppDelegate.h"
#import "MainScene.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSMutableDictionary *cocos2dSetup = [NSMutableDictionary dictionary];
    
    [CCFileUtils sharedFileUtils].suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  @"-4x", CCFileUtilsSuffixiPad,
                                                  @"-4x", CCFileUtilsSuffixiPadHD,
                                                  @"-3x", CCFileUtilsSuffixiPhone,
                                                  @"-4x", CCFileUtilsSuffixiPhoneHD,
                                                  @"-3x", CCFileUtilsSuffixiPhone5,
                                                  @"-3x", CCFileUtilsSuffixiPhone5HD,
                                                  @"", CCFileUtilsSuffixDefault,
                                                  nil];
    
    //[cocos2dSetup setObject:@(YES) forKey:CCSetupShowDebugStats];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    CCDirectorIOS *director = (CCDirectorIOS *)[CCDirector sharedDirector];
    CCScene *main = [MainScene new];
    [director runWithScene:main];
    
    return YES;
}

@end
