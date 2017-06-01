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
@property (nonatomic, assign) double result;
@property (nonatomic, assign) double firstOperand;
@property (nonatomic, assign) double secondOperand;
@property (nonatomic, retain) NSString *operator;
@property (nonatomic, assign, getter=isEquailsWasTaped) BOOL equailsWasTaped;
@property (nonatomic, assign, getter=isDigitEnteringEnterupted) BOOL digitEnteringEnterupted;

@end

@implementation Calculator

static NSString *const errorMessageNan = @"ОШИБКА";
static NSString *const errorMessageInf = @"Не определено";
static int const defaultRadix = 10;
static int const maximumSignificantDigits = 7;
//operations
static NSString *const zeroCharacher = @"0";
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
        _radix = defaultRadix;
    }
    return self;
}

- (void)dealloc{
    [_operator release];
    [_mapOfOperations release];
    [super dealloc];
}


+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *_numberFormatter = nil;
    @synchronized(self) {
        if (!_numberFormatter) {
            _numberFormatter = [NSNumberFormatter new];
            _numberFormatter.usesSignificantDigits = YES;
            _numberFormatter.maximumSignificantDigits = maximumSignificantDigits;
            _numberFormatter.notANumberSymbol = errorMessageNan;
            _numberFormatter.negativeInfinitySymbol=errorMessageInf;
            _numberFormatter.positiveInfinitySymbol=errorMessageInf;
        }
    }
    return _numberFormatter;
}

#pragma mark - Scale of notation

-(NSString *)toDecemial:(NSString *)displayLabel {
    
    //check if now in decimal than just return current value
    if (self.radix == 10){
        return  displayLabel;
    } else {
        return [NSString stringWithFormat:@"%ld", strtol([displayLabel UTF8String], NULL, self.radix)];
    }
}



-(NSString *)fromDecemial:(double)operand {
    
    NSString *returnValue = zeroCharacher;
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

- (double)getDecemialDisplayValue {
    return  [self toDecemial:  self.delegate.displayValue].doubleValue;
}


#pragma mark - Actions

- (void)operationTaped:(NSString *)operation {
    
    //operation button work as equals button (and use operator entered before) IF first operator entered and digit entering NOT interrupted
    if (!isnan(self.firstOperand) && !self.isDigitEnteringEnterupted && !self.isEquailsWasTaped){
        [self equalsTaped];
    } else {
        //SET first operand IF first operand not entered or if its happens after equals taped and its new operations.
        self.firstOperand = [self getDecemialDisplayValue];
    }
    
    //take current operator.
    self.operator = operation;
    //marking that the input of the digits was interrupted
    self.digitEnteringEnterupted = YES;
    //restore equailsWasTaped after changes in [self equalsTaped:self];
    self.equailsWasTaped = NO;
}


- (void)equalsTaped {
    
    //SET second operand - IF digit entering enterupted OR second operator is not entered;
    if (!self.isDigitEnteringEnterupted || isnan(self.secondOperand)) {
        self.secondOperand = [self getDecemialDisplayValue];;
    }
    
    [self executeOperation: self.operator];
    
    //result is first operand now;
    self.firstOperand = [self getDecemialDisplayValue];;
}


-(void)digitTaped: (NSString *)digit {
    
    //IF digit entering was interrupted or on display zero THAN start entering new display value
    if (([self.delegate.displayValue isEqualToString: zeroCharacher]) || (self.isDigitEnteringEnterupted)){
    
        self.delegate.displayValue=@"";
        self.digitEnteringEnterupted = NO;
    }
    self.delegate.displayValue = [self.delegate.displayValue stringByAppendingFormat:@"%@", digit];
    
}


#pragma mark - Operations

- (void)executeOperation: (NSString *)operation {
    
    SEL operationMethodName = NSSelectorFromString([self.mapOfOperations valueForKey:operation]);
    
    if ([self respondsToSelector:operationMethodName]) {
        
        //marking that the input of the digits was interrupted
        self.digitEnteringEnterupted = YES;
        self.equailsWasTaped = YES;
        
        [self performSelector:operationMethodName];
        [self.delegate resultUpdated: [Calculator.numberFormatter stringFromNumber: [NSNumber numberWithDouble:self.result]]];
        
        //if result is error value than clear calculator model, and set setDigitEnteringEnterupted to reset displayLabel;
        if (isnan(self.result) || self.result == INFINITY){
            self.delegate.displayValue = [Calculator.numberFormatter stringFromNumber: [NSNumber numberWithDouble:self.result]];
            [self clear];
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
    self.result = 0 - [self getDecemialDisplayValue];
    //set that digit entering in not interrupted and user can continue entering digit after change symbol;
    self.digitEnteringEnterupted = NO;
}

-(void)getPrecent {
    self.result = [self getDecemialDisplayValue] / 100;
}

-(void)getSquareRoot {
    self.result = sqrt([self getDecemialDisplayValue]);
}

@end
