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

#define kCornerRadius 9.f
#define kArrowSize CGSizeMake(18.f,36.f)
#define kMinimumSize 70.f
#define CAP(value,min,max) (value=MAX(min,MIN(max,value)))

@interface SimplePopoverView() {
    CGPathRef draw;
}

-(NSString*)gravityForPoint:(CGPoint)point;
-(SimplePopoverViewDirection)directionForGravity:(NSString*)gravity;
-(SimplePopoverViewDirection)oppositeDirection:(SimplePopoverViewDirection)direction;

-(CGPathRef)drawBox:(CGSize)size;
-(CGPathRef)drawBox:(CGSize)size sharpCornerAtGravity:(NSString*)gravity;
-(CGPathRef)drawArrow:(CGAffineTransform)rotate;

-(void)deviceOrientationDidChange:(NSNotification*)notification;

@end

@implementation SimplePopoverView
@synthesize direction,origin,anchor,contentView,contentSize,contentInset,popoverPadding,popoverColor,parentViewController,delegate;

-(void)layoutSubviews {
    CGPoint layoutOrigin = anchor?anchor.center:origin;
    SimplePopoverViewDirection layoutDirection = direction!=SimplePopoverViewDirectionAny?direction:[self oppositeDirection:[self directionForGravity:[self gravityForPoint:layoutOrigin]]];
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
    CAP(layout.size.width,kMinimumSize,parentSize.width-popoverPadding.left-popoverPadding.right);
    layout.size.height += contentInset.top+contentInset.bottom;
    CAP(layout.size.height,kMinimumSize,parentSize.height-popoverPadding.top-popoverPadding.bottom);
    layoutBox.size = layout.size;
    if(layoutDirection==SimplePopoverViewDirectionNone) {
        draw = [self drawBox:(self.frame=(CGRect){CGPointMake(layoutOrigin.x-layout.size.width/2,layoutOrigin.y-layout.size.height/2),layout.size}).size];
        contentView.frame = CGRectMake(contentInset.left,contentInset.right,layout.size.width-contentInset.left-contentInset.right,layout.size.height-contentInset.top-contentInset.bottom);
        [self setNeedsDisplay];
        return;
    }
    
    CGAffineTransform layoutRotate = CGAffineTransformIdentity; NSString* layoutSharp = nil;
    if(SimplePopoverViewDirectionIsHorizontal(layoutDirection)) {
        CGPoint shift = CGPointZero;
        layout.size.width += kArrowSize.width;
        layout.origin.y = layoutOrigin.y-layout.size.height/2;
             if(layout.origin.y<popoverPadding.top) { shift.y+=/*-*/layout.origin.y-popoverPadding.top; layout.origin.y = popoverPadding.top; }
        else if(layout.origin.y+layout.size.height>parentSize.height-popoverPadding.bottom) {
            CGFloat shiftY = layout.origin.y+layout.size.height-parentSize.height+popoverPadding.bottom;
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
                layoutArrow.origin.x = layout.size.width-layoutArrow.size.width;
                layoutRotate = CGAffineTransformMakeRotation(M_PI);
                     if(layoutArrow.origin.y<7.5f) layoutSharp = kCAGravityTopRight;
                else if(layoutArrow.origin.y+layoutArrow.size.height>layout.size.height-7.5f) layoutSharp = kCAGravityBottomRight;
                break;
            case SimplePopoverViewDirectionRight:
                if(layout.size.width+layoutOrigin.x>parentSize.width)
                   layoutBox.size.width=(layout.size.width=MAX(kMinimumSize,parentSize.width-layoutOrigin.x))-layoutArrow.size.width;
                layout.origin.x = layoutOrigin.x;
                layoutBox.origin.x = layoutArrow.size.width;
                layoutArrow.origin.x = 0.f;
                layoutRotate = CGAffineTransformIdentity;
                     if(layoutArrow.origin.y<7.5f) layoutSharp = kCAGravityTopLeft;
                else if(layoutArrow.origin.y+layoutArrow.size.height>layout.size.height-7.5f) layoutSharp = kCAGravityBottomLeft;
                break;
            default: break;
        }
    } else if(SimplePopoverViewDirectionIsVertical(layoutDirection)) {
        CGPoint shift = CGPointZero;
        layout.size.height += kArrowSize.width;
        layout.origin.x = layoutOrigin.x-layout.size.width/2;
             if(layout.origin.x<popoverPadding.left) { shift.x+=/*-*/layout.origin.x-popoverPadding.left; layout.origin.x = popoverPadding.left; }
        else if(layout.origin.x+layout.size.width>parentSize.width-popoverPadding.right) {
            CGFloat shiftX = layout.origin.x+layout.size.width-parentSize.width+popoverPadding.right;
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
                layoutArrow.origin.y = layout.size.height-layoutArrow.size.height;
                layoutRotate = CGAffineTransformMakeRotation(-M_PI_2);
                     if(layoutArrow.origin.x<7.5f) layoutSharp = kCAGravityBottomLeft;
                else if(layoutArrow.origin.x+layoutArrow.size.width>layout.size.width-7.5f) layoutSharp = kCAGravityBottomRight;
                break;
            case SimplePopoverViewDirectionDown:
                if(layout.size.height+layoutOrigin.y>parentSize.height)
                   layoutBox.size.height=(layout.size.height=MAX(kMinimumSize,parentSize.height-layoutOrigin.y))-layoutArrow.size.height;
                layout.origin.y = layoutOrigin.y;
                layoutBox.origin.y = layoutArrow.size.height;
                layoutArrow.origin.y = 0.f;
                layoutRotate = CGAffineTransformMakeRotation(M_PI_2);
                     if(layoutArrow.origin.x<7.5f) layoutSharp = kCAGravityTopLeft;
                else if(layoutArrow.origin.x+layoutArrow.size.width>layout.size.width-7.5f) layoutSharp = kCAGravityTopRight;
                break;
            default: break;
        }
    }
    
    CGPathRef drawBox=[self drawBox:layoutBox.size sharpCornerAtGravity:layoutSharp],drawArrow=[self drawArrow:layoutRotate];
    CGPathRef (^translate)(CGPathRef,CGPoint) = ^CGPathRef(CGPathRef path,CGPoint point) {
        CGAffineTransform translate = CGAffineTransformMakeTranslation(point.x,point.y);
        return CGPathCreateCopyByTransformingPath(path,&translate);
    };
    draw = CGPathCreateMutable();
    CGPathAddPath((CGMutablePathRef)draw,NULL,translate(drawBox,layoutBox.origin));
    CGPathAddPath((CGMutablePathRef)draw,NULL,translate(drawArrow,layoutArrow.origin));
    CGPathCloseSubpath((CGMutablePathRef)draw);
    
    self.frame = layout;
    contentView.frame = CGRectMake(layoutBox.origin.x+contentInset.left,layoutBox.origin.y+contentInset.right,layoutBox.size.width-contentInset.left-contentInset.right,layoutBox.size.height-contentInset.top-contentInset.bottom);
    
    [self setNeedsDisplay];
}

-(CGPathRef)drawBox:(CGSize)size { return [self drawBox:size sharpCornerAtGravity:nil]; }
-(CGPathRef)drawBox:(CGSize)size sharpCornerAtGravity:(NSString*)gravity {
    const CGFloat radius = kCornerRadius;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.f,radius);
    if(![kCAGravityBottomLeft isEqual:gravity]) {
        CGPathAddLineToPoint(path,NULL,0.f,size.height-radius);
        CGPathAddArc(path,NULL,radius,size.height-radius,radius,M_PI,M_PI_2,1);
    } else CGPathAddLineToPoint(path,NULL,0.f,size.height);
    if(![kCAGravityBottomRight isEqual:gravity]) {
        CGPathAddLineToPoint(path,NULL,size.width-radius,size.height);
        CGPathAddArc(path,NULL,size.width-radius,size.height-radius,radius,M_PI_2,0.f,1);
    } else CGPathAddLineToPoint(path,NULL,size.width,size.height);
    if(![kCAGravityTopRight isEqual:gravity]) {
        CGPathAddLineToPoint(path,NULL,size.width,radius);
        CGPathAddArc(path,NULL,size.width-radius,radius,radius,0.f,-M_PI_2,1);
    } else CGPathAddLineToPoint(path,NULL,size.width,0.f);
    if(![kCAGravityTopLeft isEqual:gravity]) {
        CGPathAddLineToPoint(path,NULL,radius,0.f);
        CGPathAddArc(path,NULL,radius,radius,radius,-M_PI_2,M_PI,1);
    } else CGPathAddLineToPoint(path,NULL,0.f,0.f);
    CGPathCloseSubpath(path);
    
    return path;
}
-(CGPathRef)drawArrow:(CGAffineTransform)rotate {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path,NULL,0,kArrowSize.height/2);
    CGPathAddLineToPoint(path,NULL,kArrowSize.width,0);
    CGPathAddLineToPoint(path,NULL,kArrowSize.width,kArrowSize.height);
    CGPathCloseSubpath(path);
    
    if(!CGAffineTransformIsIdentity(rotate)) {
        path = CGPathCreateMutableCopyByTransformingPath(path,&rotate);
        CGRect bounds = CGPathGetBoundingBox(path);
        CGAffineTransform translate = CGAffineTransformMakeTranslation(-bounds.origin.x,-bounds.origin.y);
        path = CGPathCreateMutableCopyByTransformingPath(path,&translate);
    }
    
    return path;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context,rect);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorspace,(float[]){18.0/255.0,29.0/255.0,48.0/255.0,1.0});
    CGContextSetFillColorWithColor(context,popoverColor?popoverColor.CGColor:color);
    
    CGContextBeginPath(context);
    CGContextAddPath(context,draw);
    CGContextFillPath(context);
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
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
    BOOL (^above)(NSString*) = ^BOOL(NSString* corner) {
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
    return SimplePopoverViewDirectionAny;
}
-(SimplePopoverViewDirection)oppositeDirection:(SimplePopoverViewDirection)turnDirection {
    switch(turnDirection) {
        case SimplePopoverViewDirectionUp:   return SimplePopoverViewDirectionDown;
        case SimplePopoverViewDirectionDown: return SimplePopoverViewDirectionUp;
        case SimplePopoverViewDirectionLeft: return SimplePopoverViewDirectionRight;
        case SimplePopoverViewDirectionRight:return SimplePopoverViewDirectionLeft;
        default: return SimplePopoverViewDirectionAny;
    }
}

-(id)initWithFrame:(CGRect)frame {
    if((self=[super initWithFrame:frame])!=nil) {
        self.alpha = 0; self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        direction = SimplePopoverViewDirectionNone;
        
        contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.clipsToBounds = YES;
        contentView.layer.cornerRadius = 5.f;
        contentInset = UIEdgeInsetsMake(6.f,6.f,6.f,6.f);
        [self addSubview:contentView];
        
        popoverPadding = UIEdgeInsetsMake(20.f,20.f,20.f,20.f);
        popoverColor = nil;
    }
    return self;
}
-(id)initWithOrigin:(CGPoint)newOrigin withParentViewController:(UIViewController*)newParentViewController {
    if((self=[self initWithFrame:CGRectZero])!=nil) {
        origin = newOrigin;
        parentViewController = newParentViewController;
        
        direction = SimplePopoverViewDirectionAny;
    }
    return self;
}
-(id)initFromView:(UIView*)newAnchor withParentViewController:(UIViewController*)newParentViewController {
    if((self=[self initWithOrigin:CGPointZero withParentViewController:newParentViewController])!=nil) {
        anchor = newAnchor;
    }
    return self;
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

-(void)setpopoverColor:(UIColor*)newpopoverColor {
    if(popoverColor!=newpopoverColor) {
        popoverColor = newpopoverColor;
        [self setNeedsDisplay];
    }
}

-(void)showPopover { [self showPopoverAnimated:NO completion:nil]; }
-(void)showPopoverAnimated:(BOOL)animated completion:(void(^)(void))completion; {
    if(self.superview) { if(completion) completion(); return; }
    void (^completed)(BOOL) = ^(BOOL finished) {
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
    void (^completed)(BOOL) = ^(BOOL finished) {
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