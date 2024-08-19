#import <Foundation/Foundation.h>
#import "YTIFormattedString.h"


@interface YTIPlaylistPanelVideoRenderer : NSObject

@property (retain, nonatomic) YTIFormattedString *title;
@property (retain, nonatomic) YTIFormattedString *longBylineText;
@property (retain, nonatomic) YTIFormattedString *shortBylineText;

@end
