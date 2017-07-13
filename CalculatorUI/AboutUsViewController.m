//
//  AboutUS.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "AboutUsViewController.h"
#import "LicenseViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (IBAction)showLicenseTaped:(id)sender {
    [self presentViewController:[LicenseViewController new] animated:YES completion:nil];
}

@end
