//
//  AIAModalView.h
//  AirAlertView
//
//  Created by Oleg Lobachev aironik@gmail.com on 21.05.14.
//  Copyright © 2014 aironik. All rights reserved.
//


/**
 * @brief The view that can shows as modal view or alert window.
 */
@interface AIAModalView : UIView

/**
 * @brief The color for painting background view.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 * @brief The radius to use when drawing background view.
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 * @brief Check if view shown now.
 */
@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

/**
 * @brief If YES the AIAModalView hides if user tap outside of contentView.
 * @details default value is YES.
 */
@property (nonatomic, assign) BOOL hideOnTapOutside;

/**
 * @brief The view that represent content.
 * @details This view defines size and content.
 */
@property (nonatomic, strong) UIView *contentView;

/**
 * @brief Show view in new modal window.
 */
- (void)show;

/**
 * @brief Show view in appropriate window.
 */
- (void)showInWindow:(UIWindow *)parentWindow;

/**
 * @brief Dismiss shown view and restore previous windows state.
 */
- (void)dismiss;


@end
