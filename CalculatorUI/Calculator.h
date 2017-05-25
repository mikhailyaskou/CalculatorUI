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

-(void)resultUpdated: (NSString *)resultOfOperation;
-(void)setDigitEnteringEnterupted: (BOOL)digitEnteringEnterupted;

@end


@interface Calculator : NSObject

@property (nonatomic, retain) NSString *operator;
@property (nonatomic, assign) double firstOperand;
@property (nonatomic, assign) double secondOperand;
@property (nonatomic, assign) double unaryOperand;
@property (nonatomic, assign) id <CalculatorDelegate> delegate;

- (id)init;
- (void)executeOperation:(NSString *) operation;

@end
