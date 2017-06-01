//
//  Calculator.h
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  CalculatorDelegate;

@protocol CalculatorDelegate <NSObject>

@property (nonatomic, retain) NSString *displayValue;

- (void)resultUpdated: (NSString *)resultOfOperation;

@end


@interface Calculator : NSObject

@property (nonatomic, assign) id <CalculatorDelegate> delegate;
@property (nonatomic, assign) int radix;

- (NSString*)toDecemial: (NSString *) displayLabel;
- (NSString*)fromDecemial: (double) operand;
- (void)executeOperation: (NSString *) operation;
- (void)equalsTaped;
- (void)operationTaped: (NSString *)operation;
- (void)digitTaped: (NSString *)digit;


@end
