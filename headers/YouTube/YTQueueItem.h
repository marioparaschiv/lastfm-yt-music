#import <Foundation/Foundation.h>
#import "YTIPlaylistPanelVideoRenderer.h"


@interface YTQueueItem : NSObject

@property (retain, nonatomic) YTIPlaylistPanelVideoRenderer *videoRenderer;
@property (retain, nonatomic) NSString *localID;

@end