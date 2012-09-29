//
//  ViewController.m
//  Simple Popover View
//
//  Created by Kraljic, Kristian on 20.09.12.
//  Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de). All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    UILabel* echoLabel;
}
@end

@implementation ViewController
@synthesize backgroundImage;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    echoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,56.f,56.f)];
    echoLabel.numberOfLines = 2;
    echoLabel.font = [UIFont boldSystemFontOfSize:13];
    echoLabel.textAlignment = UITextAlignmentCenter;
    
    popoverView = [[SimplePopoverView alloc] initWithOrigin:CGPointZero withParentViewController:self];
    [popoverView.contentView addSubview:echoLabel];
}

-(void)viewDidUnload {
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(IBAction)actionButton:(id)sender {
    if(!popoverView.superview||popoverView.anchor!=sender) {
        [popoverView dismissPopoverAnimated:YES completion:^{
            popoverView.anchor = (UIView*)sender;
            echoLabel.text = ((UIButton*)sender).titleLabel.text;
            [popoverView showPopoverAnimated:YES completion:nil];
        }];
    } else [popoverView dismissPopoverAnimated:YES completion:nil];
}

- (IBAction)actionRandom:(id)sender {
    [popoverView dismissPopoverAnimated:YES completion:^{
        popoverView.anchor = nil;
        popoverView.origin = CGPointMake(rand()%(int)self.view.bounds.size.width,rand()%(int)self.view.bounds.size.height);
        echoLabel.text = ((UIButton*)sender).titleLabel.text;
        [popoverView showPopoverAnimated:YES completion:nil];
    }];
}

- (IBAction)actionCorner:(id)sender {
    [popoverView dismissPopoverAnimated:YES completion:^{
        popoverView.anchor = nil;
        switch(((UIView*)sender).tag) {
            case 0: popoverView.origin = CGPointMake(0.f,0.f); break;
            case 1: popoverView.origin = CGPointMake(self.view.bounds.size.width,0.f); break;
            case 2: popoverView.origin = CGPointMake(0.f,self.view.bounds.size.height); break;
            case 3: popoverView.origin = CGPointMake(self.view.bounds.size.width,self.view.bounds.size.height); break;
            default: break;
        }
        echoLabel.text = ((UIButton*)sender).titleLabel.text;
        [popoverView showPopoverAnimated:YES completion:nil];
    }];
}

@end
