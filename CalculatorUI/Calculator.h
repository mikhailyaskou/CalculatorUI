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
@property (nonatomic, assign, getter=isDigitEnteringEnterupted) BOOL digitEnteringEnterupted;
@property (nonatomic, assign, getter=isEquailsWasTaped) BOOL equailsWasTaped;

-(void)resultUpdated: (NSString *)resultOfOperation;

@end


@interface Calculator : NSObject

@property (nonatomic, retain) NSString *operator;
@property (nonatomic, assign) double firstOperand;
@property (nonatomic, assign) double secondOperand;
@property (nonatomic, assign) double unaryOperand;
@property (nonatomic, assign) int radix;
@property (nonatomic, assign) id <CalculatorDelegate> delegate;


- (void)executeOperation:(NSString *) operation;
- (NSString*)toDecemial: (NSString *) displayLabel;
- (NSString*)fromDecemial: (double) operand;
- (void)equalsTaped;
- (void)operationTaped:(NSString *)operation;

@end
