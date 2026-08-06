
#import <UIKit/UIKit.h>

@interface NRequestDiamondsController : UIViewController



@property(nonatomic, copy)NSString *  tickCommentsObjectStr;
@property(nonatomic, assign)BOOL  is_Original;
@property(nonatomic, assign)long  session_count;
@property(nonatomic, assign)BOOL  isLinks;




-(int)lineOptionError:(int)completionsDetails;


@end

