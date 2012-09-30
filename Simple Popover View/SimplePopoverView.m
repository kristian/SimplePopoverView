//
//  SimplePopoverView.m
//  Simple popover view replacement.
//
//  Created by Kristian KrSimplejic on 30/8/12.
//  Copyright (c) 2012 Kristian KrSimplejic (dikrypt.com, ksquared.de). Simplel rights reserved.
//
//  Permission is hereby granted, free of charge, to any person 
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deSimple in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shSimplel be
//  included in Simplel copies or substantiSimple portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHSimpleL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DESimpleINGS IN THE SOFTWARE.
//

#import "SimplePopoverView.h"

#define kArrowSize CGSizeMake(18.f,36.f)
#define kArrowClip 10.f //used for corner values
#define kMinimumSize 70.f
#define CAP(value,min,max) (value=MAX(min,MIN(max,value)))

@interface SimplePopoverView() {
    UIImageView* boxImageView;
    UIImageView* arrowImageView;
}

-(NSString*)gravityForPoint:(CGPoint)point;
-(SimplePopoverViewDirection)directionForGravity:(NSString*)gravity;
-(SimplePopoverViewDirection)oppositeDirection:(SimplePopoverViewDirection)direction;

-(UIImage*)drawBox;
-(UIImage*)drawArrow;

-(void)deviceOrientationDidChange:(NSNotification*)notification;

@end

@implementation SimplePopoverView
@synthesize direction,origin,anchor,contentView,contentSize,contentInset,tintColor,parentViewController,delegate;

-(void)layoutSubviews {
    CGPoint layoutOrigin = anchor?anchor.center:origin;
    SimplePopoverViewDirection layoutDirection = direction!=SimplePopoverViewDirectionNone?direction:[self oppositeDirection:[self directionForGravity:[self gravityForPoint:layoutOrigin]]];
    if(anchor)
        switch(layoutDirection) {
            case SimplePopoverViewDirectionUp:   layoutOrigin.y -= anchor.frame.size.height/2; break;
            case SimplePopoverViewDirectionDown: layoutOrigin.y += anchor.frame.size.height/2; break;
            case SimplePopoverViewDirectionLeft: layoutOrigin.x -= anchor.frame.size.width/2; break;
            case SimplePopoverViewDirectionRight:layoutOrigin.x += anchor.frame.size.width/2; break;
            default: break;
        }
    
    CGSize parentSize = parentViewController.view.bounds.size;
    CGRect layout=(CGRect){CGPointZero,contentSize},layoutBox=CGRectZero,layoutArrow=CGRectZero;
    layout.size.width += contentInset.left+contentInset.right;
    if(SimplePopoverViewDirectionIsHorizontal(layoutDirection))
        layout.size.width += kArrowSize.width;
    CAP(layout.size.width,kMinimumSize,parentSize.width);
    layout.size.height += contentInset.top+contentInset.bottom;
    if(SimplePopoverViewDirectionIsVertical(layoutDirection))
        layout.size.height += kArrowSize.height;
    CAP(layout.size.height,kMinimumSize,parentSize.height);
    layoutBox.size = layout.size;
    
    CGPoint shift = CGPointZero;
    if(SimplePopoverViewDirectionIsHorizontal(layoutDirection)) {
        layout.size.width += kArrowSize.width;
        layout.origin.y = layoutOrigin.y-layout.size.height/2;
             if(layout.origin.y<0) { shift.y+=/*-*/layout.origin.y; layout.origin.y = 0; }
        else if(layout.origin.y+layout.size.height>parentSize.height) {
            CGFloat shiftY = layout.origin.y+layout.size.height-parentSize.height;
            layout.origin.y -= shiftY; shift.y += shiftY;
        }
        layoutArrow.size = CGSizeMake(kArrowSize.width,kArrowSize.height);
        layoutArrow.origin.y = layout.size.height/2-layoutArrow.size.height/2+shift.y;
        switch(layoutDirection) {
            case SimplePopoverViewDirectionLeft:
                if(layout.size.width>layoutOrigin.x)
                   layoutBox.size.width=(layout.size.width=MAX(kMinimumSize,layoutOrigin.x))-layoutArrow.size.width;
                layout.origin.x = layoutOrigin.x-layout.size.width;
                layoutBox.origin.x = 0.f;
                layoutArrow.origin.x = layout.size.width-layoutArrow.size.width-kArrowClip;
                arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case SimplePopoverViewDirectionRight:
                if(layout.size.width+layoutOrigin.x>parentSize.width)
                   layoutBox.size.width=(layout.size.width=MAX(kMinimumSize,parentSize.width-layoutOrigin.x))-layoutArrow.size.width;
                layout.origin.x = layoutOrigin.x;
                layoutBox.origin.x = layoutArrow.size.width;
                layoutArrow.origin.x = 0.f;
                arrowImageView.transform = CGAffineTransformIdentity;
                break;
            default: break;
        }
        layoutArrow.size.width += kArrowClip;
    } else if(SimplePopoverViewDirectionIsVertical(layoutDirection)) {
        layout.size.height += kArrowSize.width;
        layout.origin.x = layoutOrigin.x-layout.size.width/2;
             if(layout.origin.x<0) { shift.x+=/*-*/layout.origin.x; layout.origin.x = 0; }
        else if(layout.origin.x+layout.size.width>parentSize.width) {
            CGFloat shiftX = layout.origin.x+layout.size.width-parentSize.width;
            layout.origin.x -= shiftX; shift.x += shiftX;
        }
        layoutArrow.size = CGSizeMake(kArrowSize.height,kArrowSize.width);
        layoutArrow.origin.x = layout.size.width/2-layoutArrow.size.width/2+shift.x;
        switch(layoutDirection) {
            case SimplePopoverViewDirectionUp:
                if(layout.size.height>layoutOrigin.y)
                   layoutBox.size.height=(layout.size.height=MAX(kMinimumSize,layoutOrigin.y))-layoutArrow.size.height;
                layout.origin.y = layoutOrigin.y-layout.size.height;
                layoutBox.origin.y = 0.f;
                layoutArrow.origin.y = layout.size.height-layoutArrow.size.height-kArrowClip;
                arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            case SimplePopoverViewDirectionDown:
                if(layout.size.height+layoutOrigin.y>parentSize.height)
                   layoutBox.size.height=(layout.size.height=MAX(kMinimumSize,parentSize.height-layoutOrigin.y))-layoutArrow.size.height;
                layout.origin.y = layoutOrigin.y;
                layoutBox.origin.y = layoutArrow.size.height;
                layoutArrow.origin.y = 0.f;
                arrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            default: break;
        }
        layoutArrow.size.height += kArrowClip;
    }
    
    self.frame = layout;
    boxImageView.frame = layoutBox;
    arrowImageView.frame = layoutArrow;
    [boxImageView setImage:[self drawBox]];
    [arrowImageView setImage:[self drawArrow]];
    contentView.frame = CGRectMake(contentInset.left,contentInset.right,layoutBox.size.width-contentInset.left-contentInset.right,layoutBox.size.height-contentInset.top-contentInset.bottom);
}

/*
 Determines the position of a point and returns the direction of it:
 LT-----TR
 | \ T / |
 |  \ /  |
 | L o R |
 |  / \  |
 | / B \ |
 LB-----BR
 Screen is divided into 4 parts, to determine the point position.
 The origin of the coordinate system is the middle of the screen.
 For the last division the corner position is used to determine
 the point position.
 */
-(NSString*)gravityForPoint:(CGPoint)point {
    CGSize size = parentViewController.view.frame.size;
    BOOL (^above)(NSString* corner) = ^BOOL(NSString* corner) {
        CGPoint cornerPoint = CGPointZero;
        if([kCAGravityTopRight isEqual:corner]||[kCAGravityBottomRight isEqual:corner]) //Right
            cornerPoint.x = size.width;
        if([kCAGravityBottomLeft isEqual:corner]||[kCAGravityBottomRight isEqual:corner]) //Bottom
            cornerPoint.y = size.height;
        return (size.height/2-point.y)>(point.x-size.width/2)*(size.height/2-cornerPoint.y)/(cornerPoint.x-size.width/2);
    };
    if(point.x<=size.width/2) //N, W, E, S: Determine if on the left or on the right side
        if(point.y<=size.height/2) //Left, N, W, S: Determine if at top or bottom of the screen
             return above(kCAGravityTopLeft)?kCAGravityTop:kCAGravityLeft; //Top, N, W
        else return above(kCAGravityBottomLeft)?kCAGravityLeft:kCAGravityBottom; //Bottom, S, W
    else if(point.y<=size.height/2) //Right, N, E, S: Determine if at top or bottom of the screen
             return above(kCAGravityTopRight)?kCAGravityTop:kCAGravityRight; //Top, N, E 
        else return above(kCAGravityBottomRight)?kCAGravityRight:kCAGravityBottom; //Bottom, S, E
}
-(SimplePopoverViewDirection)directionForGravity:(NSString*)gravity {
    if([kCAGravityTop    isEqual:gravity]) return SimplePopoverViewDirectionUp;
    if([kCAGravityBottom isEqual:gravity]) return SimplePopoverViewDirectionDown;
    if([kCAGravityLeft   isEqual:gravity]) return SimplePopoverViewDirectionLeft;
    if([kCAGravityRight  isEqual:gravity]) return SimplePopoverViewDirectionRight;
    return SimplePopoverViewDirectionNone;
}
-(SimplePopoverViewDirection)oppositeDirection:(SimplePopoverViewDirection)turnDirection {
    switch(turnDirection) {
        case SimplePopoverViewDirectionUp:   return SimplePopoverViewDirectionDown;
        case SimplePopoverViewDirectionDown: return SimplePopoverViewDirectionUp;
        case SimplePopoverViewDirectionLeft: return SimplePopoverViewDirectionRight;
        case SimplePopoverViewDirectionRight:return SimplePopoverViewDirectionLeft;
        default: return SimplePopoverViewDirectionNone;
    }
}

-(id)initWithOrigin:(CGPoint)newOrigin withParentViewController:(UIViewController*)newParentViewController {
    if((self=[super initWithFrame:CGRectZero])!=nil) {
        origin = newOrigin;
        parentViewController = newParentViewController;
        
        self.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
        direction = SimplePopoverViewDirectionNone;
        
        contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor whiteColor];
        contentInset = UIEdgeInsetsMake(7.f,7.f,7.f,7.f);
        contentView.clipsToBounds = YES;
        
        tintColor = nil;
        [self addSubview:(boxImageView=[[UIImageView alloc] initWithImage:[self drawBox]])];
        [self addSubview:(arrowImageView=[[UIImageView alloc] initWithImage:[self drawArrow]])];
        [boxImageView addSubview:contentView];
        [self bringSubviewToFront:contentView];
        [self sendSubviewToBack:arrowImageView];
        
        boxImageView.userInteractionEnabled=YES;
    }
    return self;
}
-(id)initFromView:(UIView*)newAnchor withParentViewController:(UIViewController*)newParentViewController {
    if((self=[self initWithOrigin:CGPointZero withParentViewController:parentViewController])!=nil) {
        self.anchor = newAnchor;
    }
    return self;
}

-(UIImage*)drawBox {
    const CGFloat radius = 10.f;
    CGSize size = CGSizeMake(kMinimumSize,kMinimumSize);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorspace,(float[]){18.0/255.0,29.0/255.0,48.0/255.0,1.0});
    CGContextSetFillColorWithColor(context,tintColor?tintColor.CGColor:color);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,.0f,radius);
    CGContextAddLineToPoint(context,.0f,size.height-radius);
    CGContextAddArc(context,radius,size.height-radius,radius,M_PI,M_PI_2,1);
    CGContextAddLineToPoint(context,size.width-radius,size.height);
    CGContextAddArc(context,size.width-radius,size.height-radius,radius,M_PI_2,.0f,1);
    CGContextAddLineToPoint(context,size.width,radius);
    CGContextAddArc(context,size.width-radius,radius,radius,.0f,-M_PI_2,1);
    CGContextAddLineToPoint(context,radius,.0f);
    CGContextAddArc(context,radius,radius,radius,-M_PI_2,M_PI,1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(radius,radius,radius,radius)];
}
-(UIImage*)drawArrow {
    UIGraphicsBeginImageContext(CGSizeMake(kArrowSize.width+kArrowClip,kArrowSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorspace,(float[]){18.0/255.0,29.0/255.0,48.0/255.0,1.0});
    CGContextSetFillColorWithColor(context,tintColor?tintColor.CGColor:color);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,0,kArrowSize.height/2);
    CGContextAddLineToPoint(context,kArrowSize.width,0);
    CGContextAddLineToPoint(context,kArrowSize.width+kArrowClip,0);
    CGContextAddLineToPoint(context,kArrowSize.width+kArrowClip,kArrowSize.height);
    CGContextAddLineToPoint(context,kArrowSize.width,kArrowSize.height);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
    return image;
}

-(void)setDirection:(SimplePopoverViewDirection)newDirection {
    if(direction!=newDirection) {
        direction = newDirection;
        [self setNeedsLayout];
    }
}
-(void)setOrigin:(CGPoint)newOrigin {
    if(!CGPointEqualToPoint(origin,newOrigin)) {
        origin = newOrigin;
        [self setNeedsLayout];
    }
}
-(void)setAnchor:(UIView*)newAnchor {
    if(anchor!=newAnchor) {
        anchor = newAnchor;
        [self setNeedsLayout];
    }
}

-(void)setContentSize:(CGSize)newContentSize {
    if(!CGSizeEqualToSize(contentSize,newContentSize)) {
        contentSize = newContentSize;
        [self setNeedsLayout];
    }
}
-(void)setContentInset:(UIEdgeInsets)newContentInset {
    if(!UIEdgeInsetsEqualToEdgeInsets(contentInset,newContentInset)) {
        contentInset = newContentInset;
        [self setNeedsLayout];
    }
}

-(void)setTintColor:(UIColor*)newTintColor {
    if(tintColor!=newTintColor) {
        tintColor = newTintColor;
        [boxImageView setImage:[self drawBox]];
        [arrowImageView setImage:[self drawArrow]];
    }
}

-(void)showPopover { [self showPopoverAnimated:NO completion:nil]; }
-(void)showPopoverAnimated:(BOOL)animated completion:(void(^)(void))completion; {
    if(self.superview) { if(completion) completion(); return; }
    void (^completed)(BOOL finished) = ^(BOOL finished) {
        self.alpha = 1;
        if(delegate&&[delegate respondsToSelector:@selector(popoverDidShowPopover:)])
            [delegate popoverDidShowPopover:self];
        if(completion) completion();
    };
    [self setNeedsLayout];
    self.alpha = 0; [parentViewController?parentViewController.view:anchor.superview addSubview:self];
    if(animated)
         [UIView animateWithDuration:.3f animations:^{ self.alpha = 1; } completion:completed];
    else completed(YES);
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)dismissPopover { [self dismissPopoverAnimated:NO completion:nil]; }
-(void)dismissPopoverAnimated:(BOOL)animated completion:(void(^)(void))completion {
    if(!self.superview) { if(completion) completion(); return; }
    if([delegate respondsToSelector:@selector(popoverShouldDismissPopover:)]&&![delegate popoverShouldDismissPopover:self]) return;
    void (^completed)(BOOL finished) = ^(BOOL finished) {
        self.alpha = 0;
        [self removeFromSuperview];
        if(delegate&&[delegate respondsToSelector:@selector(popoverDidDismissPopover:)]) [delegate popoverDidDismissPopover:self];
        if(completion) completion();
    };
    if(animated)
         [UIView animateWithDuration:.3f animations:^{ self.alpha = 0; } completion:completed];
    else completed(YES);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)deviceOrientationDidChange:(NSNotification*)notification {
    [self setNeedsLayout];
}

@end