//
//  AppDelegate.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     return YES;
}

- (void)dealloc{
    [_window release];
    [super dealloc];
}

@end
