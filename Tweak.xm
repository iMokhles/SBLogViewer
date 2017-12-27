/**
 * Created by Xcode.
 * User: imokhles
 * Date: 26/12/2017
 * Time: 21:52
 */

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%config(generator=internal)


@interface FBWindow : UIWindow
- (id)recursiveDescription;
@end

@interface SBWindow : FBWindow
@end

@interface SBMainScreenActiveInterfaceOrientationWindow : SBWindow
- (_Bool)isActive;
@end

@interface SBLogWindowController : UIViewController
+ (id)sharedInstanceIfAvailable;
+ (id)sharedInstance;
@property(retain, nonatomic) SBMainScreenActiveInterfaceOrientationWindow *logWindow;
@property(retain, nonatomic) UITextView *logTextView;
- (void)hide;
- (void)show;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
@end

#pragma mark - Hooks
%hook UIStatusBar

- (id)initWithFrame:(CGRect)frame {
    
    id selfObject = %orig();
    if (selfObject) {
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapped:)];
        tapGesture.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:tapGesture];
    }
    return selfObject;
}
%new
- (void)statusBarTapped:(UIPanGestureRecognizer *)gesture {
    
    SBLogWindowController *logWindowInstance = [objc_getClass("SBLogWindowController") sharedInstance];
    SBMainScreenActiveInterfaceOrientationWindow *logWindowObject = logWindowInstance.logWindow;
    
    if (logWindowObject.isActive == true) {
        [logWindowInstance hide];
    } else {
        [logWindowInstance show];
    }
}
%end

#pragma mark - Ctor
%ctor {
    %init();
}
