//
//  AIAAlertView.m
//  AirAlertView
//
//  Created by Oleg Lobachev aironik@gmail.com on 13.01.14.
//  Copyright © 2014 aironik. All rights reserved.
//

#import "AIAAlertView.h"

#import <UIKit/UIKit.h>


#if !(__has_feature(objc_arc))
#error ARC required. Add -fobjc-arc compiler flag for this file.
#endif


@interface AIAAlertView ()<UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *nativeAlertView;

@end


#pragma mark - Implementation

@implementation AIAAlertView


+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message {
    return [[self alloc] initWithTitle:title message:message];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    if (self = [super init]) {
        NSAssert([title length] + [message length], @"Title and message are empty. This case is obscure.");
        _title = [title copy];
        _message = [message copy];
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title actionBlock:(AIAAlertViewActionBlock)actionBlock {

}

- (void)addCancelButtonWithTitle:(NSString *)title actionBlock:(AIAAlertViewActionBlock)actionBlock {

}

- (void)show {
    if (!self.nativeAlertView) {
        self.nativeAlertView = [[UIAlertView alloc] initWithTitle:self.title
                                                          message:self.message
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:nil];
        [self.nativeAlertView show];
    }
}

- (void)hide {
//    [self.nativeAlertView dismissWithClickedButtonIndex:self.cancelButtonIndex animated:YES];
}

@end
