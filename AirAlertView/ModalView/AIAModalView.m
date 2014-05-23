//
//  AIAModalView.m
//  AirAlertView
//
//  Created by Oleg Lobachev aironik@gmail.com on 21.05.14.
//  Copyright © 2014 aironik. All rights reserved.
//

#import "AIAModalView.h"


#if !(__has_feature(objc_arc))
#error ARC required. Add -fobjc-arc compiler flag for this file.
#endif


static const NSTimeInterval kAnimationDuration = 0.2;


@interface AIAModalView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *darkeningBackView;
@property (nonatomic, strong) UIWindow *parentWindow;
@property (nonatomic, strong) UIWindow *previouslyShownWindow;

@property (nonatomic, strong) UITapGestureRecognizer *hideOnDarkeningBackViewGestureRecognizer;

@end


#pragma mark - Implementation


@implementation AIAModalView


- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    _cornerRadius = 10.;
    _hideOnTapOutside = YES;

    super.backgroundColor = _backgroundColor;
    self.layer.cornerRadius = _cornerRadius;
    self.clipsToBounds = YES;
}

- (void)show {
    if (![self isVisible]) {
        [self showInWindow:[self createParentWindow]];
    }
}

- (void)showInWindow:(UIWindow *)parentWindow {
    if (![self isVisible]) {
        self.previouslyShownWindow = [[UIApplication sharedApplication] keyWindow];
        self.parentWindow = parentWindow;
        
        [self prepareViewsForAppear];
        [self prepareTransformsForAppear];
        
        [self.parentWindow makeKeyAndVisible];
        AIA_WEAK_SELF;
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{ AIA_STRONG_SELF; [strongSelf prepareTransformsAfterAppear]; }
                         completion:NULL];
    }
}

- (void)dismiss {
    if ([self isVisible]) {
        AIA_WEAK_SELF;
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ AIA_STRONG_SELF; [strongSelf hideOnDismiss]; }
                         completion:^(BOOL finished) { AIA_STRONG_SELF; [strongSelf finalizeOnDismiss]; }];
    }
}

- (void)prepareViewsForAppear {
    self.darkeningBackView = [self createDarkeningBackView];
    self.darkeningBackView.frame = self.parentWindow.bounds;
    [self.parentWindow addSubview:self.darkeningBackView];
    
    self.center = CGPointMake(CGRectGetMidX(self.parentWindow.bounds), CGRectGetMidY(self.parentWindow.bounds));
    [self.darkeningBackView addSubview:self];
}

- (void)prepareTransformsForAppear {
    self.parentWindow.alpha = 0.;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.transform = transform;
}

- (void)prepareTransformsAfterAppear {
    self.parentWindow.alpha = 1.;
    self.transform = CGAffineTransformIdentity;
}

- (void)hideOnDismiss {
    self.parentWindow.alpha = 0.;
    CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
    self.transform = transform;
}

- (void)finalizeOnDismiss {
    self.parentWindow.alpha = 1.;
    if (self.previouslyShownWindow != self.parentWindow) {
        [self.previouslyShownWindow makeKeyAndVisible];
    }
    self.previouslyShownWindow = nil;
    self.parentWindow = nil;
    
    [self.darkeningBackView removeFromSuperview];
    self.hideOnDarkeningBackViewGestureRecognizer = nil;
    self.darkeningBackView = nil;
    
    [self removeFromSuperview];
}

- (BOOL)isVisible {
    return self.parentWindow != nil;
}

- (UIWindow *)createParentWindow {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

    UIWindow *result = [[UIWindow alloc] initWithFrame:keyWindow.frame];
    result.windowLevel = UIWindowLevelAlert;
    result.transform = keyWindow.transform;
    return result;
}

- (UIView *)createDarkeningBackView {
    UIView *result = [[UIView alloc] initWithFrame:self.frame];
    result.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    result.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    self.hideOnDarkeningBackViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapDidRecognize:)];
    self.hideOnDarkeningBackViewGestureRecognizer.numberOfTapsRequired = 1;
    self.hideOnDarkeningBackViewGestureRecognizer.numberOfTouchesRequired = 1;
    self.hideOnDarkeningBackViewGestureRecognizer.delegate = self;
    
    [result addGestureRecognizer:self.hideOnDarkeningBackViewGestureRecognizer];
    
    return result;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        super.backgroundColor = _backgroundColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];

        _contentView = contentView;
        _contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        CGRect frame = contentView.frame;
        frame.origin = CGPointZero;
        _contentView.frame = frame;

        self.frame = frame;
        
        [self addSubview:_contentView];
    }
}

- (IBAction)tapDidRecognize:(UITapGestureRecognizer *)gestureRecognizer {
    NSParameterAssert(gestureRecognizer == self.hideOnDarkeningBackViewGestureRecognizer);
    if (self.hideOnTapOutside) {
        [self dismiss];
    }
}


#pragma mark - UIGestureRecognizerDelegate protocol implementation

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL result = YES;
    NSParameterAssert(gestureRecognizer == self.hideOnDarkeningBackViewGestureRecognizer);
    if (gestureRecognizer == self.hideOnDarkeningBackViewGestureRecognizer) {
        CGPoint tapLocation = [gestureRecognizer locationInView:self];
        result = !CGRectContainsPoint(self.bounds, tapLocation);
    }
    return result;
}

@end
