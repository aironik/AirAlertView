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

@end


#pragma mark - AIAAlertView friends category


@interface AIAAlertView (AIATestsFriend)
- (UIAlertView *)nativeAlertView;
@end

@interface UIAlertViewMock : UIAlertView
@end

@implementation UIAlertViewMock

+ (id)allocAlertView {
    return [UIAlertViewMock allocWithZone:NULL];
}

- (void)show {

}

@end



#pragma mark - Implementation

@implementation AIAAlertViewTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
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
    AIATestsHelpersSwizzleImpls *helper = [AIATestsHelpersSwizzleImpls replaceSourceSelector:@selector(allocAlertView)
                                                                                 sourceClass:[UIAlertViewMock class]
                                                                              targetSelector:@selector(alloc)
                                                                                 targetClass:[UIAlertView class]];

    NSString *title = @"test title";
    NSString *message = @"test message";
    AIAAlertView *alertView = [AIAAlertView alertViewWithTitle:title message:message];
    [alertView show];
    UIAlertView *nativeAlertView = [alertView nativeAlertView];

    XCTAssertNotNil(nativeAlertView, @"Shown nativeAlertView is empty");
    XCTAssertEqualObjects(nativeAlertView.title, title, @"AIAAlertView created with different title");
    XCTAssertEqualObjects(nativeAlertView.message, message, @"AIAAlertView created with different title");

    [helper revert];
}

- (void)testCreateAlertViewWithCancelButton {
    NSString *title = @"test title";
    NSString *message = @"test message";
    AIAAlertView *alertView = [AIAAlertView alertViewWithTitle:title message:message];
    XCTAssertNotNil(alertView, @"Cannot create AIAAlertView");
    XCTAssertEqualObjects(alertView.title, title, @"AIAAlertView created with different title");
    XCTAssertEqualObjects(alertView.message, message, @"AIAAlertView created with different title");
}

@end
