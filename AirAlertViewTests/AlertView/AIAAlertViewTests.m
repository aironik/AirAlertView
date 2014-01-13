//
//  AIAAlertViewTests.m
//  AirAlertView
//
//  Created by Oleg Lobachev aironik@gmail.com on 13.01.14.
//  Copyright © 2014 aironik. All rights reserved.
//


#import "AIAAlertView.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "AIATestsHelpersSwizzleImpls.h"


#if !(__has_feature(objc_arc))
#error ARC required. Add -fobjc-arc compiler flag for this file.
#endif


@interface AIAAlertViewTests : XCTestCase

@property (nonatomic, strong) AIATestsHelpersSwizzleImpls *swizzleImplsHelper;

@end


#pragma mark - AIAAlertView friends category


@interface AIAAlertView (AIATestsFriend)
- (UIAlertView *)nativeAlertView;
@end

@interface UIAlertViewMock : UIAlertView
@property (nonatomic, assign) BOOL viewShown;
@end

@implementation UIAlertViewMock

+ (id)allocAlertView {
    return [UIAlertViewMock allocWithZone:NULL];
}

- (void)show {
    self.viewShown = YES;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    self.viewShown = NO;
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}


@end


#pragma mark - Implementation

@implementation AIAAlertViewTests

- (void)setUp {
    [super setUp];
    self.swizzleImplsHelper = [AIATestsHelpersSwizzleImpls replaceSourceSelector:@selector(allocAlertView)
                                                                     sourceClass:[UIAlertViewMock class]
                                                                  targetSelector:@selector(alloc)
                                                                     targetClass:[UIAlertView class]];
}

- (void)tearDown {
    [self.swizzleImplsHelper revert];
    [super tearDown];
}

- (void)testCreateEmptyAlertView {
    NSString *title = @"test title";
    NSString *message = @"test message";
    AIAAlertView *alertView = [AIAAlertView alertViewWithTitle:title message:message];
    XCTAssertNotNil(alertView, @"Cannot create AIAAlertView");
    XCTAssertEqualObjects(alertView.title, title, @"AIAAlertView created with different title");
    XCTAssertEqualObjects(alertView.message, message, @"AIAAlertView created with different title");
}

- (void)testShownAlertViewWithoutButtonsShouldHaveCancelButton {
    NSString *title = @"test title";
    NSString *message = @"test message";
    AIAAlertView *alertView = [AIAAlertView alertViewWithTitle:title message:message];
    [alertView show];
    UIAlertView *nativeAlertView = [alertView nativeAlertView];

    XCTAssertNotNil(nativeAlertView, @"Shown nativeAlertView is empty");
    XCTAssertEqualObjects(nativeAlertView.title, title, @"AIAAlertView created with different title");
    XCTAssertEqualObjects(nativeAlertView.message, message, @"AIAAlertView created with different title");
    XCTAssert(nativeAlertView.numberOfButtons == 1, @"AIAAlertView should add only Cancel button");
    XCTAssert(nativeAlertView.cancelButtonIndex == 0, @"AIAAlertView should add only Cancel button");
    XCTAssertEqual(nativeAlertView.delegate, alertView, @"AIAAlertView should set self as UIAlertView delegate");
}

- (void)testCreateAlertViewWithCancelButton {
    NSString *title = @"test title";
    NSString *message = @"test message";
    NSString *buttonTitle = @"CancelButton";
    AIAAlertView *alertView = [AIAAlertView alertViewWithTitle:title message:message];
    [alertView addCancelButtonWithTitle:buttonTitle actionBlock:NULL];
    [alertView show];
    UIAlertView *nativeAlertView = [alertView nativeAlertView];

    XCTAssertNotNil(nativeAlertView, @"Shown nativeAlertView is empty");
    XCTAssert(nativeAlertView.numberOfButtons == 1, @"AIAAlertView should add only Cancel button");
    XCTAssert(nativeAlertView.cancelButtonIndex == 0, @"AIAAlertView should add only Cancel button");
    XCTAssertEqualObjects([nativeAlertView buttonTitleAtIndex:0], buttonTitle, @"AIAAlertView should add Cancel button with title");
    XCTAssertEqual(nativeAlertView.delegate, alertView, @"AIAAlertView should set self as UIAlertView delegate");
}

@end
