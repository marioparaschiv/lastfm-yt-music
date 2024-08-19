#import <Foundation/Foundation.h>
#import "YTQueueItem.h"


@interface YTQueueController : NSObject

@property (readonly, nonatomic) YTQueueItem *nowPlayingMusicQueueItem;
@property (nonatomic) double nowPlayingVideoMediaTime;

@end
