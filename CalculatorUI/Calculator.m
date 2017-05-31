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

static NSString * const plus = @"+";
static NSString * const minus = @"-";
static NSString * const multiply =@"*";
static NSString * const divide =@"/";
static NSString * const changeSymbol =@"+/-";
static NSString * const precent =@"%";
static NSString * const squarRoot =@"√";
static NSString * const clear =@"AC";
static NSString * const equals =@"=";

- (id)init {
    if(self = [super init]) {
        _mapOfOperations = @{plus:@"add",
                             minus:@"sub",
                             multiply:@"mul",
                             divide:@"div",
                             changeSymbol:@"сhangeSymbol",
                             precent:@"getPrecent",
                             squarRoot:@"getSquareRoot",
                             clear:@"clear",
                             equals:@"equals",};
        [_mapOfOperations retain];
        _firstOperand = NAN;
        _secondOperand = NAN;
        _radix = 10;
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


-(NSString *)toDecemial:(NSString *)displayLabel {
    
    return  [NSString stringWithFormat:@"%ld", strtol([displayLabel UTF8String], NULL, self.radix)];
}



-(NSString *)fromDecemial:(double)operand {
    
    NSString *returnValue = @"0";
    
    
    switch (self.radix) {
        case 2:
            
        //from decimal to binary
        {
            NSString *newDec = [NSString stringWithFormat:@"%g", operand];
            NSUInteger x = [newDec integerValue];
            int i = 0;
            while (x > 0) {
                returnValue = [[NSString stringWithFormat:@"%lu", x&1] stringByAppendingString:returnValue];
                x = x>> 1;
                ++i;
        }
            break;
            }
        case 8:
            returnValue = [NSString stringWithFormat: @"%o", (int) operand];
            break;
        case 10:
            returnValue = [NSString stringWithFormat:@"%g", operand];
            break;
        case 16:
           returnValue = [NSString stringWithFormat: @"%X", (int) operand];
            break;
        default:
            break;
    }
    
    return returnValue;
   
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



- (void)operationTaped:(NSString *)operation {
    
    
    //operation button work as equals button (and use operator entered before) IF first operator entered and digit entering NOT interrupted
    if (!isnan(self.firstOperand) && !self.delegate.isDigitEnteringEnterupted && !self.delegate.isEquailsWasTaped){
        
        [self equalsTaped];
        //restore equailsWasTaped after changes in [self equalsTaped:self];
        self.delegate.equailsWasTaped = NO;
    } else {
        
        //SET first operand IF first operand not entered or if its happens after equals taped and its new operations.
        self.firstOperand = [self toDecemial:  self.delegate.displayValue].doubleValue;
        self.delegate.equailsWasTaped = NO;
    }
    
    //take current operator.
    self.operator = operation;
    //marking that the input of the digits was interrupted
    
    self.delegate.digitEnteringEnterupted = YES;

}


- (void)equalsTaped {
    
    //SET second operand - IF digit entering enterupted OR second operator is not entered;
    if (!self.delegate.isDigitEnteringEnterupted || isnan(self.secondOperand)) {
        self.secondOperand = [self toDecemial:  self.delegate.displayValue].doubleValue;
    }
    
    [self executeOperation: self.operator];
    
    //result is first operand now;
    self.firstOperand = [self toDecemial:  self.delegate.displayValue].doubleValue;
    
    //marking that the input of the digits was interrupted
    
    self.delegate.digitEnteringEnterupted = YES;
    self.delegate.equailsWasTaped = YES;
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
    
    //SET second operand - IF digit entering enterupted OR second operator is not entered;
    if (!self.delegate.isDigitEnteringEnterupted || isnan(self.secondOperand)) {
        self.secondOperand = [self toDecemial:  self.delegate.displayValue].doubleValue;
    }
    
    [self executeOperation: self.operator];
    
    //result is first operand now;
    self.firstOperand = [self toDecemial:  self.delegate.displayValue].doubleValue;
    
    //marking that the input of the digits was interrupted
    
    self.delegate.digitEnteringEnterupted = YES;
    self.delegate.equailsWasTaped = YES;
}



@end
