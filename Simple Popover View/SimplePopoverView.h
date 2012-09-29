//
//  SimplePopoverView.h
//  Simple popover view replacement.
//
//  Created by Kristian Kraljic on 30/8/12.
//  Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de). All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person 
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    SimplePopoverViewDirectionNone,
    SimplePopoverViewDirectionLeft,
    SimplePopoverViewDirectionRight,
    SimplePopoverViewDirectionUp,
    SimplePopoverViewDirectionDown
} SimplePopoverViewDirection;

#define SimplePopoverViewDirectionIsHorizontal(direction) (direction==SimplePopoverViewDirectionLeft||direction==SimplePopoverViewDirectionRight)
#define SimplePopoverViewDirectionIsVertical(direction) (direction==SimplePopoverViewDirectionUp||direction==SimplePopoverViewDirectionDown)

@protocol SimplePopoverViewDelegate;

@interface SimplePopoverView : UIView

@property(assign,nonatomic) SimplePopoverViewDirection direction;
@property(assign,nonatomic) CGPoint origin;
@property(strong,nonatomic) UIView* anchor;

@property(nonatomic,readonly) UIView* contentView;
@property(assign,nonatomic) CGSize contentSize;
@property(assign,nonatomic) UIEdgeInsets contentInset;

@property(strong,nonatomic) UIColor* tintColor;

@property(nonatomic,readonly) UIViewController* parentViewController;
@property(weak,nonatomic) id<SimplePopoverViewDelegate> delegate;

-(id)initWithOrigin:(CGPoint)origin withParentViewController:(UIViewController*)parentViewController;
-(id)initFromView:(UIView*)anchor withParentViewController:(UIViewController*)parentViewController;

-(void)showPopover;
-(void)showPopoverAnimated:(BOOL)animated completion:(void(^)(void))completion;
-(void)dismissPopover;
-(void)dismissPopoverAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end

@protocol SimplePopoverViewDelegate<NSObject>
@optional
-(BOOL)popoverShouldDismissPopover:(SimplePopoverView*)popoverView;
-(void)popoverDidDismissPopover:(SimplePopoverView*)popoverView;
-(void)popoverDidShowPopover:(SimplePopoverView*)popoverView;

@end