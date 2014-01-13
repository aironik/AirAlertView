//
//  AIATestsHelpers.m
//  AirAlertView
//
//  Created by Oleg Lobachev aironik@gmail.com on 13.01.14.
//  Copyright © 2014 aironik. All rights reserved.
//

#import "AIATestsHelpersSwizzleImpls.h"

#import <objc/runtime.h>


#if !(__has_feature(objc_arc))
#error ARC required. Add -fobjc-arc compiler flag for this file.
#endif


@interface AIATestsHelpersSwizzleImpls ()

@property (nonatomic, assign) Class targetMetaClass;
@property (nonatomic, assign) SEL sourceSelector;
@property (nonatomic, assign) SEL targetSelector;
@property (nonatomic, assign) Method sourceClassMethod;
@property (nonatomic, assign) Method targetClassMethod;
@property (nonatomic, assign) BOOL methodWasReplaced;
@property (nonatomic, assign) Class sourceClass;
@property (nonatomic, assign) Class targetClass;
@property (nonatomic, assign) IMP oldTargetImp;

@end


#pragma mark - Implementation

@implementation AIATestsHelpersSwizzleImpls

- (void)dealloc {
    [self revert];
}

+ (instancetype)replaceSourceSelector:(SEL)sourceSelector
                          sourceClass:(Class)sourceClass
                       targetSelector:(SEL)targetSelector
                          targetClass:(Class)targetClass;
{
    AIATestsHelpersSwizzleImpls *result = [[[self class] alloc] init];
    [result replaceSourceSelector:sourceSelector
                      sourceClass:sourceClass
                   targetSelector:targetSelector
                      targetClass:targetClass];
    return result;
}

//- (void)replaceSourceSelector:(SEL)sourceSelector
//                  sourceClass:(Class)sourceClass
//               targetSelector:(SEL)targetSelector
//                  targetClass:(Class)targetClass
//{
//    self.sourceSelector = sourceSelector;
//    self.sourceClass = sourceClass;
//    self.targetSelector = targetSelector;
//    self.targetClass = targetClass;
//
//    self.sourceClassMethod = class_getClassMethod(self.sourceClass, self.sourceSelector);
//    self.targetClassMethod = class_getClassMethod(self.targetClass, self.targetSelector);
//
//    self.sourceImp = method_getImplementation(self.sourceClassMethod);
//    self.targetImp = method_getImplementation(self.targetClassMethod);
//
//    [self replace];
//}
- (void)replaceSourceSelector:(SEL)sourceSelector
                  sourceClass:(Class)sourceClass
               targetSelector:(SEL)targetSelector
                  targetClass:(Class)targetClass
{
    self.sourceClass = sourceClass;
    self.targetClass = targetClass;
    self.sourceSelector = sourceSelector;
    self.targetSelector = targetSelector;
    self.sourceClassMethod = class_getClassMethod(self.sourceClass, self.sourceSelector);
    self.targetClassMethod = class_getClassMethod(self.targetClass, self.targetSelector);

    self.targetMetaClass =
            objc_getMetaClass([NSStringFromClass(self.targetClass) cStringUsingEncoding:NSUTF8StringEncoding]);

//    BOOL methodWasAdded =
    class_addMethod(self.targetMetaClass,
                    sourceSelector,
                    method_getImplementation(self.targetClassMethod),
                    method_getTypeEncoding(self.targetClassMethod));
//    if (!methodWasAdded) {
//        self.oldTargetImp = method_setImplementation(self.targetClassMethod, method_getImplementation(self.sourceClassMethod));
//    }
    [self replace];
}

- (void)replace {
    class_replaceMethod(self.targetMetaClass,
                        self.targetSelector,
                        method_getImplementation(self.sourceClassMethod),
                        method_getTypeEncoding(self.sourceClassMethod));
    self.methodWasReplaced = YES;
}

- (void)revert {
    if (self.methodWasReplaced) {
//        if (self.oldTargetImp) {
//            method_setImplementation(self.targetClassMethod, self.oldTargetImp);
//        }
        class_replaceMethod(self.targetMetaClass,
                            self.targetSelector,
                            method_getImplementation(self.targetClassMethod),
                            method_getTypeEncoding(self.targetClassMethod));
        self.methodWasReplaced = NO;
    }
}


@end
