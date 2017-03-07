
#import "AppDelegate.h"
#import "MainScene.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet CCGLView *glView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

    [director setDisplayStats:YES];

    // Set a default window size
    CGSize defaultWindowSize = CGSizeMake(480.0f, 320.0f);
    [self.window setFrame:CGRectMake(0.0f, 0.0f, defaultWindowSize.width, defaultWindowSize.height) display:true animate:false];
    [self.glView setFrame:self.window.frame];

    // connect the OpenGL view with the director
    [director setView:self.glView];

    // 'Effects' don't work correctly when autoscale is turned on.
    // Use kCCDirectorResize_NoScale if you don't want auto-scaling.
    //[director setResizeMode:kCCDirectorResize_NoScale];

    // Enable "moving" mouse event. Default no.
    [self.window setAcceptsMouseMovedEvents:NO];
    self.window.delegate = self;

    // Center main window
    [self.window center];

    // Notice that I deliberately added some of the artwork without extensions
    [CCFileUtils sharedFileUtils].suffixesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  @"-2x", CCFileUtilsSuffixiPad,
                                                  @"-4x", CCFileUtilsSuffixiPadHD,
                                                  @"-1x", CCFileUtilsSuffixiPhone,
                                                  @"-1x", CCFileUtilsSuffixiPhoneHD,
                                                  @"-1x", CCFileUtilsSuffixiPhone5,
                                                  @"-2x", CCFileUtilsSuffixiPhone5HD,
                                                  @"", CCFileUtilsSuffixDefault,
                                                  nil];

    CCScene *main = [MainScene new];
    [director runWithScene:main];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[CCDirector sharedDirector] end];
}

@end
