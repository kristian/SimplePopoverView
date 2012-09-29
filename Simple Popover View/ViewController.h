//
//  ViewController.h
//  Simple Popover View
//
//  Created by Kraljic, Kristian on 20.09.12.
//  Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimplePopoverView.h"

@interface ViewController : UIViewController {
    SimplePopoverView* popoverView;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (IBAction)actionButton:(id)sender;
- (IBAction)actionRandom:(id)sender;
- (IBAction)actionCorner:(id)sender;

@end
