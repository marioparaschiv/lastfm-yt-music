#include "../headers/Instances.h"

static YTMContentViewController *g_ytRootViewController = nil;
static YTQueueController *g_ytQueueController = nil;

@implementation LFMYouTubeInstances

+ (YTQueueController*) queueController {
	return g_ytQueueController;
}

+ (YTMContentViewController*) rootViewController {
	return g_ytRootViewController;
}

@end

%hook YTQueueController

- (id) initWithAccountID:(id)accountId restorableQueueState:(id)state {
	YTQueueController *orig = %orig;

	if (orig) {
		g_ytQueueController = orig;
	}

	return orig;
}

%end

%hook YTMContentViewController

- (void) loadView {
	%orig;

	if (self) {
		g_ytRootViewController = self;
	}
}

%new
- (void) safariViewControllerDidFinish:(SFSafariViewController*) controller {
	[LFMClient handleBrowserExit];
};

%end