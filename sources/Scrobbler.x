#import "../headers/Scrobbler.h"

static NSString *currentSongLocalID = @"";
static double currentTotalMediaTime = 0;
static BOOL currentSongReplayed = NO;
static NSTimer *timer = nil;
static BOOL scrobbled = NO;
static BOOL isPlaying = NO;

@implementation LFMScrobbler

+ (void) poll {
	dispatch_async(dispatch_get_main_queue(), ^{
		YTQueueController *controller = [LFMYouTubeInstances queueController];
		YTQueueItem *item = [controller nowPlayingMusicQueueItem];
		YTIPlaylistPanelVideoRenderer *renderer = [item videoRenderer];

		NSString *artist = [[renderer shortBylineText] stringWithFormattingRemoved];
		NSString *track = [[renderer title] stringWithFormattingRemoved];
		double mediaTime = [controller nowPlayingVideoMediaTime];
		NSString *localID = [item localID];


		if ((!currentSongReplayed && currentSongLocalID == localID && mediaTime < 1) && isPlaying) {
			currentSongReplayed = YES;
		}

		if ((localID != currentSongLocalID || mediaTime > 1) && isPlaying) {
			currentSongReplayed = NO;
		}

		if ((localID != currentSongLocalID || currentSongReplayed) && isPlaying) {
			NSLog(@"Now Playing: %@ - %@", artist, track);

			scrobbled = NO;
			currentSongLocalID = localID;
			[LFMClient setNowPlaying:track artist:artist duration:currentTotalMediaTime];
		}

		if (!scrobbled && isPlaying && mediaTime >= (currentTotalMediaTime / 2)) {
			NSLog(@"Scrobbling: %@ - %@", artist, track);

			[LFMClient scrobble:track artist:artist duration:currentTotalMediaTime elapsed:mediaTime];
			scrobbled = YES;
		}
	});
}

@end

%hook MLHAMPlayerItem

- (void) playerStateDidChangeFrom:(NSInteger*)from to:(NSInteger*)to {
	%orig;

	// 3 - Playing
	if ((int)(size_t)to == 3) {
		isPlaying = TRUE;

		dispatch_async(dispatch_get_main_queue(), ^{
			timer = [NSTimer
				scheduledTimerWithTimeInterval:1.0f
				target:[NSBlockOperation blockOperationWithBlock:^{ [LFMScrobbler poll]; }]
				selector:@selector(main)
				userInfo:nil
				repeats:YES
			];
		});
	} else {
		if (timer) {
			[timer invalidate];
		}

		isPlaying = FALSE;
	}

	currentTotalMediaTime = [self totalMediaTime];
}

%end