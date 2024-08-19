#import <SafariServices/SafariServices.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface YTMContentViewController : UIViewController <SFSafariViewControllerDelegate>

- (void) safariViewControllerDidFinish:(SFSafariViewController*) controller;

@end
