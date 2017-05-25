//
//  FormatterForCalculator.h
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 25.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatterForCalculator : NSObject

@property (nonatomic, retain) NSNumberFormatter *formatter;

+ (id)sharedFormatterForCalculator;

@end
