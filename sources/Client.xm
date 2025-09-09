#import "../headers/Client.h"
#import <SafariServices/SafariServices.h>

static NSString* const LFMBaseURL = @"https://ws.audioscrobbler.com/2.0";

@implementation LFMClient
	+ (NSString*) makeSignature:(NSDictionary<NSString*, NSString*>*)parameters secret:(NSString*)secret {
		NSArray *sortedParamKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *signature = [[NSMutableString alloc] init];

		for (NSString *key in sortedParamKeys) {
			if ([key isEqualToString:@"format"]) continue;

			NSString *str = [NSString stringWithFormat:@"%@%@", key, [parameters objectForKey:key]];
			[signature appendString:str];
    }

    [signature appendString:secret];

    return [LFMClient md5:signature];
	}

	+ (void) handleBrowserExit {
		[LFMClient createSession];
	}

	+ (void) setNowPlaying:(NSString*)track artist:(NSString*)artist duration:(double)duration {
		[LFMClient postSongDataToAPI:@{
			@"artist": artist,
			@"track": track,
			@"duration": [NSNumber numberWithDouble:duration],
			@"album": @"",
			@"album_artist": artist,
			@"method": @"track.updateNowPlaying"
		}];
	}

	+ (void) scrobble:(NSString*)track artist:(NSString*)artist duration:(double)duration elapsed:(double)elapsed {
		NSDate *date = [NSDate date];
		NSTimeInterval unix = [date timeIntervalSince1970];

		double fixed = trunc((unix - elapsed));

		[LFMClient postSongDataToAPI:@{
			@"artist": artist,
			@"track": track,
			@"duration": [NSNumber numberWithDouble:duration],
			@"timestamp": [NSNumber numberWithDouble:fixed],
			@"album": @"",
			@"album_artist": artist,
			@"method": @"track.scrobble"
		}];
	}

	+ (void) postSongDataToAPI:(NSDictionary*)data {
		NSString *sessionKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"lfmSessionKey"];
		NSMutableDictionary *postedData = [[NSMutableDictionary alloc] init];

		postedData[@"api_key"] = API_KEY;
		postedData[@"sk"] = sessionKey ? sessionKey : @"invalid_key";
		postedData[@"format"] = @"json";

		for (id key in data) {
			postedData[key] = data[key];
		}

		postedData[@"api_sig"] = [LFMClient makeSignature:postedData secret:API_SECRET];

		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ws.audioscrobbler.com/2.0/"]
			cachePolicy:NSURLRequestUseProtocolCachePolicy
			timeoutInterval:10.0
		];

		NSDictionary *headers = @{
			@"Content-Type": @"application/x-www-form-urlencoded"
		};

		[request setAllHTTPHeaderFields:headers];

		NSMutableData *body = [[NSMutableData alloc] initWithData:[@"format=json" dataUsingEncoding:NSUTF8StringEncoding]];

		for (id key in postedData) {
			[body appendData:[[NSString stringWithFormat:@"&%@=%@", key, [LFMClient urlEncodedString:postedData[key]]] dataUsingEncoding:NSUTF8StringEncoding]];
		}

		[request setHTTPBody:body];
		[request setHTTPMethod:@"POST"];

		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
			completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
				if (error) {
					NSLog(@"Error while posting data: %@", error);
					dispatch_semaphore_signal(sema);
				} else {
					NSError *parseError = nil;
					NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
					NSLog(@"Response: %@", responseDictionary);

					id error = responseDictionary[@"error"];
					if ([error isEqual:@9] || [error isEqual:@4]) {
						[LFMClient createToken];
					}

					dispatch_semaphore_signal(sema);
				}
			}
		];

		[dataTask resume];
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	}

	+ (NSString*) createToken {
		NSString *signature = [LFMClient makeSignature:@{
			@"format": @"json",
			@"api_key": API_KEY,
			@"method": @"auth.gettoken"
		} secret:API_SECRET];

		NSString *_url = [NSString stringWithFormat:@"%@/?method=auth.gettoken&api_key=%@&api_sig=%@&format=json", LFMBaseURL, API_KEY, signature];
		NSURL *url = [NSURL URLWithString:_url];

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block NSURLResponse *response;
		__block NSError *error;
		__block NSData *data;

		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
			completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
				data = d;
				response = r;
				error = e;

				dispatch_semaphore_signal(semaphore);
			}
		];

		[dataTask resume];
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

		if (error) {
			NSLog(@"Faced error while creating token: %@", error);
			return nil;
		}

		if (data) {
			id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

			if (json[@"error"] && json[@"message"]) {
				NSLog(@"Faced an error while getting token: %@", json[@"message"]);

				YTAlertView *alertView = [%c(YTAlertView) infoDialog];
				alertView.title = @"Warning";
				alertView.subtitle = [NSString stringWithFormat: @"Failed to get last.fm token: %@", json[@"message"]];
				[alertView show];

				return nil;
			}

			[[NSUserDefaults standardUserDefaults] setObject:json[@"token"] forKey:@"lfmToken"];
			NSLog(@"Token fetched: %@", json[@"token"]);

			[LFMClient authorize];

			return json[@"token"];
		}

		return nil;
	}

	+ (void) authorize {
		NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"lfmToken"];
		NSString *_url = [NSString stringWithFormat:@"https://www.last.fm/api/auth/?api_key=%@&token=%@", API_KEY, token];
		NSURL *url = [NSURL URLWithString:_url];

		dispatch_async(dispatch_get_main_queue(), ^{
			SFSafariViewController *view = [[SFSafariViewController alloc] initWithURL:url];
			YTMContentViewController *controller = [LFMYouTubeInstances rootViewController];
			[view setModalPresentationStyle:UIModalPresentationFullScreen];

			view.delegate = controller;

			[controller presentViewController:view animated:YES completion:nil];
		});
	}

	+ (NSString*) createSession {
		NSString *cached = [[NSUserDefaults standardUserDefaults] stringForKey:@"lfmToken"];
		NSString *token = cached ? cached : [LFMClient createToken];

		NSLog(@"https://www.last.fm/api/auth/?api_key=%@&token=%@", API_KEY, token);

		NSString *signature = [LFMClient makeSignature:@{
			@"format": @"json",
			@"api_key": API_KEY,
			@"token": token,
			@"method": @"auth.getsession"
		} secret:API_SECRET];

		NSString *_url = [NSString stringWithFormat:@"%@/?method=auth.getsession&api_key=%@&api_sig=%@&token=%@&format=json", LFMBaseURL, API_KEY, signature, token];
		NSURL *url = [NSURL URLWithString:_url];

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block NSURLResponse *response;
    __block NSError *error;
    __block NSData *data;

		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
			completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
				data = d;
				response = r;
				error = e;

				dispatch_semaphore_signal(semaphore);
			}
		];

		[dataTask resume];
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

		id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error) {
			NSLog(@"Faced error while creating session: %@", error);

			return nil;
		}

		if (data) {
			if (json[@"error"] && json[@"message"]) {
				NSLog(@"Faced an error while getting session: %@", json[@"message"]);

				YTAlertView *alertView = [%c(YTAlertView) infoDialog];
				alertView.title = @"Warning";
				alertView.subtitle = [NSString stringWithFormat: @"Failed to create last.fm session: %@", json[@"message"]];
				[alertView show];

				[LFMClient createToken];

				return nil;
			}

			[[NSUserDefaults standardUserDefaults] setObject:json[@"session"][@"key"] forKey:@"lfmSessionKey"];
			NSLog(@"Session key fetched: %@", json[@"session"][@"key"]);

			return json[@"session"][@"key"];
		}

		return nil;
	}

	+ (NSString *)urlEncodedString:(NSString *)str {
		if ([str isKindOfClass:[NSString class]]) {
			NSCharacterSet *allowed = [[NSCharacterSet characterSetWithCharactersInString:@"&+, \"#%<>[\\]^`{|}"] invertedSet];
			return [str stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    }

    return str;
	}

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	+ (NSString *)md5:(NSString*)string {
		unsigned char digest[CC_MD5_DIGEST_LENGTH], i;

		CC_MD5([string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);

		NSMutableString *ms = [NSMutableString string];
		for (i=0; i < CC_MD5_DIGEST_LENGTH; i++) {
			[ms appendFormat: @"%02x", (int)(digest[i])];
		}

		return [ms copy];
	}
	#pragma clang diagnostic pop
@end