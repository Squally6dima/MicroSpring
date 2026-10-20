#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

// Implemented and exported by the MicroSpring host.
extern void MSReportGuestRootViewController(
    UIViewController *rootViewController
);

@interface MSGuestTestViewController : UIViewController
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, strong) UILabel *counterLabel;
@end

@implementation MSGuestTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.055
                                                green:0.063
                                                 blue:0.090
                                                alpha:1.0];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"Guest App Active";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.accessibilityIdentifier = @"guest.title";

    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = @"MicroSpring · Guest Adapter";
    subtitleLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1.0];
    subtitleLabel.font = [UIFont systemFontOfSize:14
                                           weight:UIFontWeightMedium];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;

    self.counter = 0;
    self.counterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.counterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.counterLabel.text = @"Button presses: 0";
    self.counterLabel.textColor = UIColor.whiteColor;
    self.counterLabel.font =
        [UIFont monospacedDigitSystemFontOfSize:18
                                         weight:UIFontWeightSemibold];
    self.counterLabel.textAlignment = NSTextAlignmentCenter;
    self.counterLabel.accessibilityIdentifier = @"guest.counter";

    UIButton *counterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    counterButton.translatesAutoresizingMaskIntoConstraints = NO;
    counterButton.backgroundColor =
        [UIColor colorWithRed:0.35 green:0.30 blue:0.95 alpha:1.0];
    counterButton.layer.cornerRadius = 14.0;
    counterButton.layer.masksToBounds = YES;
    [counterButton setTitle:@"Increment Counter"
                   forState:UIControlStateNormal];
    [counterButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    counterButton.titleLabel.font =
        [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    counterButton.accessibilityIdentifier = @"guest.increment";
    [counterButton addTarget:self
                      action:@selector(incrementCounter:)
            forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel, subtitleLabel, self.counterLabel, counterButton
    ]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentFill;
    stack.distribution = UIStackViewDistributionFill;
    stack.spacing = 22.0;

    [self.view addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stack.leadingAnchor
            constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor
                                         constant:24.0],
        [stack.trailingAnchor
            constraintLessThanOrEqualToAnchor:self.view.trailingAnchor
                                      constant:-24.0],
        [counterButton.heightAnchor constraintEqualToConstant:52.0],
        [counterButton.widthAnchor
            constraintGreaterThanOrEqualToConstant:220.0]
    ]];

    NSLog(@"[GuestAdapter] Test interface created.");
}

- (void)incrementCounter:(UIButton *)sender {
    self.counter += 1;
    self.counterLabel.text =
        [NSString stringWithFormat:@"Button presses: %ld",
                                   (long)self.counter];
    NSLog(@"[GuestAdapter] Counter incremented to %ld", (long)self.counter);
}

@end

// Required guest adapter entry point.
// A return value of 0 means delivery was scheduled, not that display succeeded.
__attribute__((visibility("default")))
int MicroSpringGuestEntry(const char *containerPath) {
    if (containerPath == NULL) {
        NSLog(@"[GuestAdapter] Error: containerPath is NULL.");
        return -1;
    }

    NSString *guestPath = [NSString stringWithUTF8String:containerPath];
    if (guestPath == nil) {
        NSLog(@"[GuestAdapter] Error: containerPath is invalid UTF-8.");
        return -1;
    }

    NSLog(@"[GuestAdapter] Received containerPath: %@", guestPath);

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            MSGuestTestViewController *guestController =
                [[MSGuestTestViewController alloc] init];
            [guestController loadViewIfNeeded];
            MSReportGuestRootViewController(guestController);
            NSLog(@"[GuestAdapter] Root view controller delivery requested.");
        }
    });

    return 0;
}
