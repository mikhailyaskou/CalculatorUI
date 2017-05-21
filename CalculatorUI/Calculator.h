//
//  Calculator.h
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"


@interface Calculator : NSObject

@property (nonatomic, retain) NSString *operator;
@property (nonatomic, assign) double firstOperand;
@property (nonatomic, assign) double secondOperand;
@property (nonatomic, assign) double unaryOperand;

- (id)init;
- (double)executeOperation:(NSString *) operation;
- (double)equals;

@end
