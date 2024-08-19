#import "Main.h"
#import <CommonCrypto/CommonDigest.h>


@interface LFMClient : NSObject

+ (void) scrobble:(NSString*)track artist:(NSString*)artist duration:(double)duration elapsed:(double)elapsed;
+ (void) setNowPlaying:(NSString*)track artist:(NSString*)artist duration:(double)duration;
+ (NSString*) makeSignature:(NSDictionary<NSString*, NSString*>*)parameters secret:(NSString*)secret;
+ (NSString *) urlEncodedString:(NSString *)str;
+ (void) postSongDataToAPI:(NSDictionary*)data;
+ (NSString *) md5:(NSString*)string;
+ (NSString*) createSession;
+ (void) handleBrowserExit;
+ (NSString*) createToken;
+ (void) authorize;

@end