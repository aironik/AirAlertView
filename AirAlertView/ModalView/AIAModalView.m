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
static const CGFloat kLineWidth = 2.;

@interface AIAModalView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *darkeningBackView;
@property (nonatomic, strong) UIWindow *parentWindow;

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
        [self showInWindow:[[UIApplication sharedApplication] keyWindow]];
    }
}

- (void)showInWindow:(UIWindow *)parentWindow {
    if (![self isVisible]) {
        self.parentWindow = parentWindow;
        
        [self copyTintColorFromView:[[UIApplication sharedApplication] keyWindow] toView:self.parentWindow];
        
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

- (void)copyTintColorFromView:(UIView *)fromView toView:(UIView *)toView {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if ([fromView respondsToSelector:@selector(tintColor)] && [toView respondsToSelector:@selector(setTintColor)]) {
        [toView setTintColor:fromView.tintColor];
    }
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
}

- (void)prepareViewsForAppear {
    self.darkeningBackView = [self createDarkeningBackView];

    UIView *parentView = [[self.parentWindow subviews] count] ? [self.parentWindow subviews][0] : self.parentWindow;
    self.darkeningBackView.frame = parentView.bounds;
    [parentView addSubview:self.darkeningBackView];

    self.center = self.darkeningBackView.center;
    self.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                             | UIViewAutoresizingFlexibleBottomMargin
                             | UIViewAutoresizingFlexibleLeftMargin
                             | UIViewAutoresizingFlexibleRightMargin);
    [self.darkeningBackView addSubview:self];
}

- (void)prepareTransformsForAppear {
    self.darkeningBackView.alpha = 0.;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.1, 1.1);
    self.transform = transform;
}

- (void)prepareTransformsAfterAppear {
    self.darkeningBackView.alpha = 1.;
    self.transform = CGAffineTransformIdentity;
}

- (void)hideOnDismiss {
    self.darkeningBackView.alpha = 0.;
    CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
    self.transform = transform;
}

- (void)finalizeOnDismiss {
    self.parentWindow = nil;
    
    [self.darkeningBackView removeFromSuperview];
    self.hideOnDarkeningBackViewGestureRecognizer = nil;
    self.darkeningBackView = nil;
    
    [self removeFromSuperview];
}

- (BOOL)isVisible {
    return self.parentWindow != nil;
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

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawBorderInContext:ctx];
}

- (void)drawBorderInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);

    const CGFloat inset = kLineWidth / 2.;
    CGRect borderRect = CGRectInset(self.bounds, inset, inset);
    [self.borderColor setStroke];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:self.layer.cornerRadius];
    borderPath.lineWidth = kLineWidth;
    [borderPath stroke];
    
    CGContextRestoreGState(ctx);
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
        
        [super addSubview:_contentView];
    }
}

- (void)addSubview:(UIView *)view {
    NSAssert(NO, @"you should use -setContentView: instead");
    [self setContentView:view];
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
