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

-(void)adjustText:(id)sender;

@end

@implementation ViewController
@synthesize backgroundImage;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    echoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,92.f,92.f)];
    echoLabel.numberOfLines = 0;
    echoLabel.font = [UIFont systemFontOfSize:11];
    echoLabel.textAlignment = UITextAlignmentCenter;
    
    popoverView = [[SimplePopoverView alloc] initWithOrigin:CGPointZero withParentViewController:self];
    popoverView.contentSize = echoLabel.frame.size;
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
            [self adjustText:sender];
            popoverView.anchor = (UIView*)sender;
            popoverView.direction = SimplePopoverViewDirectionAny;
            [popoverView showPopoverAnimated:YES completion:nil];
        }];
    } else [popoverView dismissPopoverAnimated:YES completion:nil];
}

- (IBAction)actionRandom:(id)sender {
    [popoverView dismissPopoverAnimated:YES completion:^{
        [self adjustText:sender];
        popoverView.anchor = nil;
        popoverView.origin = CGPointMake(rand()%(int)self.view.bounds.size.width,rand()%(int)self.view.bounds.size.height);
        popoverView.direction = rand()%2?SimplePopoverViewDirectionAny:SimplePopoverViewDirectionNone;
        [popoverView showPopoverAnimated:YES completion:nil];
    }];
}

- (IBAction)actionCorner:(id)sender {
    [popoverView dismissPopoverAnimated:YES completion:^{
        [self adjustText:sender];
        popoverView.anchor = nil;
        switch(((UIView*)sender).tag) {
            case 0: popoverView.origin = CGPointMake(0.f,0.f); break;
            case 1: popoverView.origin = CGPointMake(self.view.bounds.size.width,0.f); break;
            case 2: popoverView.origin = CGPointMake(0.f,self.view.bounds.size.height); break;
            case 3: popoverView.origin = CGPointMake(self.view.bounds.size.width,self.view.bounds.size.height); break;
            default: break;
        }
        popoverView.direction = SimplePopoverViewDirectionAny;
        [popoverView showPopoverAnimated:YES completion:nil];
    }];
}

-(void)adjustText:(id)sender {
    echoLabel.text = [((UIButton*)sender).titleLabel.text stringByAppendingFormat:@". %@",@"Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat."];
}

@end
