//
//  Calculator.h
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CalculatorDelegate <NSObject>

@property(nonatomic, retain) NSString *displayValue;

@end

@interface CalculatorModel : NSObject

@property(nonatomic, weak) id <CalculatorDelegate> delegate;

- (void)equals;
- (void)executeOperation:(NSString *)operation;
- (void)handleOperation:(NSString *)operation;
- (void)handleDigit:(NSString *)digit;
- (void)updatingRadix:(int)radix;

@end
