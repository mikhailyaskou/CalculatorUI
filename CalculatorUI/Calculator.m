//
//  Calculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "Calculator.h"


@interface Calculator ()


@property (nonatomic, retain) NSDictionary *mapOfOperations;

@end


@implementation Calculator


- (id)init {
    
    if(self = [super init]) {
        self.mapOfOperations = @{@"+":@"add",
                     @"-":@"sub",
                     @"*":@"mul",
                     @"/":@"div",
                     @"+/-":@"сhangeSymbol",
                     @"%":@"getPrecent",
                     @"√":@"getSquareRoot",
                     @"AC":@"clear",
                     @"=":@"equals",};
        self.firstOperand = NAN;
        self.secondOperand = NAN;
    }
    return self;
}

- (void)dealloc{
    [_operator release];
    [_mapOfOperations release];
    [super dealloc];
}

#pragma mark - Operations

- (double)executeOperation:(NSString *)operation {
    
    SEL operationMethodName = NSSelectorFromString([self.mapOfOperations valueForKey:operation]);
    
    double returnValue = 0.0;
    
    if ([self respondsToSelector:operationMethodName]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[self class] instanceMethodSignatureForSelector:operationMethodName]];
        
        [invocation setSelector:operationMethodName];
        [invocation setTarget:self];
        [invocation invoke];
        [invocation getReturnValue:&returnValue];
        
        }
    
    return returnValue;
}

-(double)add {
    return  self.firstOperand + self.secondOperand;
}

-(double)sub {
    return self.firstOperand - self.secondOperand;
}

-(double)mul {
    return  self.firstOperand * self.secondOperand;
}

-(double)div {
    return self.firstOperand / self.secondOperand;
}

-(double)сhangeSymbol {
    return 0 - self.unaryOperand;
}

-(double)getPrecent {
    return self.unaryOperand / 100;
}

-(double)getSquareRoot{
    return sqrt(self.unaryOperand);
}


-(double)equals{
    
    return [self executeOperation:self.operator];
}



@end
