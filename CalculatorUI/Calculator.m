//
//  Calculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "Calculator.h"
#import "FormatterForCalculator.h"


@interface Calculator ()

@property (nonatomic, retain) NSDictionary *mapOfOperations;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, assign) double result;

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
    [_errorMessage release];
    [super dealloc];
}


+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *_numberFormatter = nil;
    @synchronized(self) {
        if (!_numberFormatter) {
            _numberFormatter = [NSNumberFormatter new];
            _numberFormatter.usesSignificantDigits = YES;
            _numberFormatter.maximumSignificantDigits = 7;
            _numberFormatter.notANumberSymbol = @"ОШИБКА";
            _numberFormatter.negativeInfinitySymbol=@"Не определено";
            _numberFormatter.positiveInfinitySymbol=@"Не определено";
            
        }
    }
    
    return _numberFormatter;
}


#pragma mark - Operations

- (void)executeOperation:(NSString *)operation {
    
    SEL operationMethodName = NSSelectorFromString([self.mapOfOperations valueForKey:operation]);

    if ([self respondsToSelector:operationMethodName]) {
        
        [self performSelector:operationMethodName];
        [self.delegate resultUpdated: [Calculator.numberFormatter stringFromNumber: [NSNumber numberWithDouble:self.result]]];
        
        //if result is error value than clear calculator model, and set setDigitEnteringEnterupted to reset displayLabel;
        if (isnan(self.result) || self.result == INFINITY){
            [self clear];
            [self.delegate setDigitEnteringEnterupted: YES];
        }
    }
}

-(void)clear {
    self.firstOperand = NAN;
    self.secondOperand = NAN;
    self.operator = nil;
    self.result = 0;
}


-(void)add {
    self.result = self.firstOperand + self.secondOperand;
}


-(void)sub {
    self.result = self.firstOperand - self.secondOperand;
}


-(void)mul {
    self.result = self.firstOperand * self.secondOperand;
}


-(void)div {
        self.result = self.firstOperand / self.secondOperand;
}


-(void)сhangeSymbol {
    //set that digit entering in not interrupted and user can continue entering digit after change symbol;
    [self.delegate setDigitEnteringEnterupted: NO];
    self.result = 0 - self.unaryOperand;
}


-(void)getPrecent {
    self.result = self.unaryOperand / 100;
}


-(void)getSquareRoot{
        self.result = sqrt(self.unaryOperand);
}


-(void)equals{
    
    [self executeOperation:self.operator];
}



@end
