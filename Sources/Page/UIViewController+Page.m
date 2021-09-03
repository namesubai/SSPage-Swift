//
//  UIViewController+Page.m
//  SSPage-Swift
//
//  Created by yangsq on 2021/9/3.
//

#import "UIViewController+Page.h"
#import <objc/runtime.h>
@implementation UIViewController (Page)
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(ss_viewDidLoad) with:@selector(viewDidLoad)];
        [self swizzleInstanceMethod:@selector(ss_viewWillAppear:) with:@selector(viewWillAppear:)];
    });
}

- (void)setTrigger:(Trigger)trigger{
    objc_setAssociatedObject(self, @selector(trigger), trigger, OBJC_ASSOCIATION_COPY);
    
}
- (Trigger)trigger{
    return objc_getAssociatedObject(self, _cmd);
}


- (void)ss_viewDidLoad {
    [self ss_viewDidLoad];
    if (self.trigger) {
        self.trigger();
    }
}

- (void)ss_viewWillAppear:(BOOL)animated {
    [self ss_viewWillAppear: animated];
    if (self.trigger) {
        self.trigger();
    }
}

- (void)viewDidLoadTrigger:(Trigger)trigger{
    self.trigger = trigger;
}

@end
