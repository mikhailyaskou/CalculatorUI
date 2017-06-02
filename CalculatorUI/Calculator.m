//
//  Calculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "Calculator.h"
#import "FormatterForCalculator.h"

static NSString *const YMACalculatorBrainErrorMessageNan = @"ОШИБКА";
static NSString *const YMACalculatorBrainErrorMessageInf = @"Не определено";
static int const YMACalculatorBrainDefaultRadix = 10;
static int const YMACalculatorBrainMaximumSignificantDigits = 7;
//operations
static NSString * const YMACalculatorBrainZeroCharacher = @"0";
static NSString * const YMACalculatorBrainPlus = @"+";
static NSString * const YMACalculatorBrainMinus = @"-";
static NSString * const YMACalculatorBrainMultiply =@"*";
static NSString * const YMACalculatorBrainDivide =@"/";
static NSString * const YMACalculatorBrainChangeSymbol =@"+/-";
static NSString * const YMACalculatorBrainPrecent =@"%";
static NSString * const YMACalculatorBrainSquarRoot =@"√";
static NSString * const YMACalculatorBrainClear =@"AC";
//method names
static NSString * const YMACalculatorBrainPlusMethodNames = @"add";
static NSString * const YMACalculatorBrainMinusMethodNames = @"sub";
static NSString * const YMACalculatorBrainMultiplyMethodNames =@"mul";
static NSString * const YMACalculatorBrainDivideMethodNames =@"div";
static NSString * const YMACalculatorBrainChangeSymbolMethodNames =@"сhangeSymbol";
static NSString * const YMACalculatorBrainPrecentMethodNames =@"precent";
static NSString * const YMACalculatorBrainSquarRootMethodNames =@"squareRoot";
static NSString * const YMACalculatorBrainClearMethodNames =@"clear";


@interface Calculator ()

@property (nonatomic, retain) NSDictionary *mapOfOperations;
@property (nonatomic, assign) double result;
@property (nonatomic, assign) double firstOperand;
@property (nonatomic, assign) double secondOperand;
@property (nonatomic, retain) NSString *operator;
@property (nonatomic, assign, getter=isEquailsWasTaped) BOOL equailsWasTaped;
@property (nonatomic, assign, getter=isDigitEnteringEnterupted) BOOL digitEnteringEnterupted;
@property (nonatomic, assign) int radix;

- (NSString*)toDecemial:(NSString *) displayLabel;
- (NSString*)fromDecemial:(double) operand;

@end

@implementation Calculator

- (id)init {
    if (self = [super init]) {
        _mapOfOperations = [@{YMACalculatorBrainPlus      : YMACalculatorBrainPlusMethodNames,
                             YMACalculatorBrainMinus      : YMACalculatorBrainMinusMethodNames,
                             YMACalculatorBrainMultiply   : YMACalculatorBrainMultiplyMethodNames,
                             YMACalculatorBrainDivide     : YMACalculatorBrainDivideMethodNames,
                             YMACalculatorBrainChangeSymbol: YMACalculatorBrainChangeSymbolMethodNames,
                             YMACalculatorBrainPrecent    : YMACalculatorBrainPrecentMethodNames,
                             YMACalculatorBrainSquarRoot  : YMACalculatorBrainSquarRootMethodNames,
                            YMACalculatorBrainClear       : YMACalculatorBrainClearMethodNames}retain];
        _firstOperand = NAN;
        _secondOperand = NAN;
        _radix = YMACalculatorBrainDefaultRadix;
    }
    return self;
}

- (void)dealloc {
    [_operator release];
    [_mapOfOperations release];
    [super dealloc];
}


+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *_numberFormatter = nil;
    @synchronized(self) {
        if (!_numberFormatter) {
            _numberFormatter = [NSNumberFormatter new];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [_numberFormatter setLocale:locale];
            [locale release];
            _numberFormatter.usesSignificantDigits = YES;
            _numberFormatter.maximumSignificantDigits = YMACalculatorBrainMaximumSignificantDigits;
            _numberFormatter.notANumberSymbol = YMACalculatorBrainErrorMessageNan;
            _numberFormatter.negativeInfinitySymbol=YMACalculatorBrainErrorMessageInf;
            _numberFormatter.positiveInfinitySymbol=YMACalculatorBrainErrorMessageInf;
        }
    }
    return _numberFormatter;
}

#pragma mark - Scale of notation

-(NSString *)toDecemial:(NSString *)displayLabel {
    
    //check if now in decimal than just return current value
    if (self.radix == 10) {
        return  displayLabel;
    }
    else {
        return [NSString stringWithFormat:@"%ld", strtol([displayLabel UTF8String], NULL, self.radix)];
    }
}



-(NSString *)fromDecemial:(double)operand {
    
    NSString *returnValue = @"";
    switch (self.radix) {
        case 2:
        {
            //from decimal to binary
            NSUInteger x = operand;
            while (x>0) {
                returnValue = [[NSString stringWithFormat: @"%lu", x&1] stringByAppendingString:returnValue];
                x = x >> 1;
            }
            break;
        }
        case 8:
            returnValue = [NSString stringWithFormat:@"%o", (int) operand];
            break;
        case 10:
            returnValue = [NSString stringWithFormat:@"%g", operand];
            break;
        case 16:
            returnValue = [NSString stringWithFormat:@"%X", (int) operand];
            break;
        default:
            break;
    }
    return returnValue;
}


- (void)updatingRadix:(int) radix{
    
    if (self.radix !=radix){
        NSString *decemial = [self toDecemial:self.delegate.displayValue];
        self.radix = radix;
        [self resultUpdated:decemial];
    }
}


- (double)decemialDisplayValue {
    return  [self toDecemial:self.delegate.displayValue].doubleValue;
}


#pragma mark - Actions

- (void)handleOperation:(NSString *)operation {
    //operation button work as equals button (and use operator entered before) IF first operator entered and digit entering NOT interrupted
    if (!isnan(self.firstOperand) && !self.isDigitEnteringEnterupted && !self.isEquailsWasTaped){
        [self equals];
    }
    else {
        //SET first operand IF first operand not entered or if its happens after equals taped and its new operations.
        self.firstOperand = [self decemialDisplayValue];
    }
    //take current operator.
    self.operator = operation;
    //marking that the input of the digits was interrupted
    self.digitEnteringEnterupted = YES;
    //restore equailsWasTaped after changes in [self equalsTaped:self];
    self.equailsWasTaped = NO;
}


- (void)equals {
    //SET second operand - IF digit entering enterupted OR second operator is not entered;
    if (!self.isDigitEnteringEnterupted || isnan(self.secondOperand)) {
        self.secondOperand = [self decemialDisplayValue];;
    }
    //calculating operation
    [self executeOperation:self.operator];
    //result is first operand now;
    self.firstOperand = [self decemialDisplayValue];;
}


- (void)handleDigit:(NSString *)digit {
    //IF digit entering was interrupted or on display zero THAN start entering new display value
    if (([self.delegate.displayValue isEqualToString: YMACalculatorBrainZeroCharacher]) || (self.isDigitEnteringEnterupted)) {
    //reset value for new input
        self.delegate.displayValue=@"";
        self.digitEnteringEnterupted = NO;
    }
    //add new taped digit
    self.delegate.displayValue = [self.delegate.displayValue stringByAppendingFormat:@"%@", digit];
}

- (void)resultUpdated:(NSString *)resultOfOperation {
    self.delegate.displayValue = [self fromDecemial: resultOfOperation.floatValue];
}

#pragma mark - Operations

- (void)executeOperation:(NSString *)operation {
    SEL operationMethodName = NSSelectorFromString([self.mapOfOperations valueForKey:operation]);
    if ([self respondsToSelector:operationMethodName]) {
        //marking that the input of the digits was interrupted
        self.digitEnteringEnterupted = YES;
        self.equailsWasTaped = YES;
        //operation method call
        [self performSelector:operationMethodName];
        [self resultUpdated: [Calculator.numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.result]]];
        //if result is error value than clear calculator model, and set setDigitEnteringEnterupted to reset displayLabel;
        if (isnan(self.result) || self.result == INFINITY){
            self.delegate.displayValue = [Calculator.numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.result]];
            [self clear];
        }
    }
}

- (void)clear {
    self.firstOperand = NAN;
    self.secondOperand = NAN;
    self.operator = nil;
    self.result = 0;
}

- (void)add {
    self.result = self.firstOperand + self.secondOperand;
}

- (void)sub {
    self.result = self.firstOperand - self.secondOperand;
}

- (void)mul {
    self.result = self.firstOperand * self.secondOperand;
}

- (void)div {
    self.result = self.firstOperand / self.secondOperand;
}

- (void)сhangeSymbol {
    self.result = 0 - [self decemialDisplayValue];
    //set that digit entering in not interrupted and user can continue entering digit after change symbol;
    self.digitEnteringEnterupted = NO;
}

- (void)precent {
    self.result = [self decemialDisplayValue] / 100;
}

- (void)squareRoot {
    self.result = sqrt([self decemialDisplayValue]);
}

@end
