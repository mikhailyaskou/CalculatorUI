//
//  FormatterForCalculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 25.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "FormatterForCalculator.h"

 static FormatterForCalculator *sharedFormatterForCalculator = nil;

@implementation FormatterForCalculator

#pragma mark Singleton Methods

+ (id)sharedFormatterForCalculator {
   
    @synchronized(self) {
        if(!sharedFormatterForCalculator) {
            sharedFormatterForCalculator = [[FormatterForCalculator alloc] init];
            sharedFormatterForCalculator.formatter = [NSNumberFormatter new];
            sharedFormatterForCalculator.formatter.usesSignificantDigits = YES;
            sharedFormatterForCalculator.formatter.maximumSignificantDigits = 7;
        }
    }
    return sharedFormatterForCalculator;
}

-(void)dealloc {
    [_formatter release];
    [super dealloc];
}

@end
