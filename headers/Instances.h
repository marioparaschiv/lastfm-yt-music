#import "Main.h"
#import "./YouTube/YTQueueController.h"
#import "./YouTube/YTMContentViewController.h"


static YTQueueController *g_ytQueueController;
static YTMContentViewController *g_ytRootViewController;

@interface LFMYouTubeInstances : NSObject

+ (YTQueueController*) queueController;
+ (YTMContentViewController*) rootViewController;


@end