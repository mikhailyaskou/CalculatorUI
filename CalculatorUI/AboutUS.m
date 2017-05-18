//
//  AboutUS.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "AboutUS.h"
#import "License.h"

@interface AboutUS ()

@property (retain, nonatomic) UIViewController *licenseView;

@end

@implementation AboutUS

- (void)dealloc{
    [_licenseView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)showLicenseTaped:(id)sender {
    
    self.licenseView = [[[ License alloc] init]autorelease];
    
    [self presentViewController: self.licenseView animated:YES completion:nil];
}


@end
