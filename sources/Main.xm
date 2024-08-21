#import "../headers/Main.h"

%hook YTMContentViewController

- (void) viewDidLoad {
	%orig;

	NSLog(@"Started.");

	if(![[NSUserDefaults standardUserDefaults] stringForKey:@"lfmSessionKey"]) {
		@try {
			[LFMClient createToken];
		} @catch (NSError *error) {
			NSLog(@"Faced an issue while getting signature: %@", error.localizedDescription);

			YTAlertView *alertView = [%c(YTAlertView) infoDialog];
			alertView.title = @"Warning";
			alertView.subtitle = [NSString stringWithFormat: @"Faced an issue while getting signature: %@", error.localizedDescription];
			[alertView show];
		}
	};
}

%end

%hook YTMQueueModificationNotifier

- (void) queueController:(id)controller didReplacePlaylistWithPlaylistPanel:(id)panel {
	%orig;

	[LFMScrobbler poll];
}

- (void) queueControllerDidRemoveAllItems:(id)items {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didAddItemsFromResponse:(id)response {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didUpdateVideoAtIndex:(unsigned long long)index {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didRemoveVideoAtIndexPath:(id)path {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller numberOfItemsDidChangeFrom:(unsigned long long)from to:(unsigned long long)to nowPlayingIndexChanged:(_Bool)changed {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didInsertVideoCount:(unsigned long long)count atIndex:(unsigned long long)index {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didInsertAutoplayRenderersAtIndexes:(id)indexes {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didRemoveAutoplayRenderersAtIndexes:(id)indexes {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didPromoteAutoplayItemsAtIndexPaths:(id)paths userTriggered:(_Bool)triggered {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didMoveVideoAtIndexPath:(id)prevPath toIndexPath:(id)toPath {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didUpdateUserContentMode:(unsigned long long)mode {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didUpdateShuffleMode:(unsigned long long)mode {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller didUpdateLoopMode:(unsigned long long)mode {
	%orig;

	[LFMScrobbler poll];
};

- (void) queueController:(id)controller nowPlayingItemAtIndex:(unsigned long long)index {
	%orig;

	[LFMScrobbler poll];
};

%end