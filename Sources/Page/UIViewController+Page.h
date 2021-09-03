//
//  UIViewController+Page.h
//  SSPage-Swift
//
//  Created by yangsq on 2021/9/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^Trigger)(void);

@interface UIViewController (Page)
- (void)viewDidLoadTrigger:(Trigger)trigger;
@property (nonatomic, copy) Trigger trigger;
@end

NS_ASSUME_NONNULL_END
