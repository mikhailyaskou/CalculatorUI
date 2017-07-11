//
//  Calculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 18.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "CalculatorModel.h"

static NSString *const YMACalculatorBrainErrorMessageNan = @"ОШИБКА";
static NSString *const YMACalculatorBrainErrorMessageInf = @"Не определено";
static int const YMACalculatorBrainDefaultRadix = 10;
static int const YMACalculatorBrainMaximumSignificantDigits = 7;
//operations
static NSString *const YMACalculatorBrainZeroCharacter = @"0";
static NSString *const YMACalculatorBrainPlus = @"+";
static NSString *const YMACalculatorBrainMinus = @"-";
static NSString *const YMACalculatorBrainMultiply = @"*";
static NSString *const YMACalculatorBrainDivide = @"/";
static NSString *const YMACalculatorBrainChangeSymbol = @"+/-";
static NSString *const YMACalculatorBrainPrecent = @"%";
static NSString *const YMACalculatorBrainSquareRoot = @"√";
static NSString *const YMACalculatorBrainClear = @"AC";
//method names
static NSString *const YMACalculatorBrainPlusMethodNames = @"add";
static NSString *const YMACalculatorBrainMinusMethodNames = @"sub";
static NSString *const YMACalculatorBrainMultiplyMethodNames = @"mul";
static NSString *const YMACalculatorBrainDivideMethodNames = @"div";
static NSString *const YMACalculatorBrainChangeSymbolMethodNames = @"сhangeSymbol";
static NSString *const YMACalculatorBrainPrecentMethodNames = @"precent";
static NSString *const YMACalculatorBrainSquareRootMethodNames = @"squareRoot";
static NSString *const YMACalculatorBrainClearMethodNames = @"clear";

@interface CalculatorModel ()

@property(nonatomic, strong) NSDictionary *mapOfBlocksOperations;

@property(nonatomic, assign) double result;
@property(nonatomic, assign) double firstOperand;
@property(nonatomic, assign) double secondOperand;
@property(nonatomic, strong) NSString *operator;
@property(nonatomic, assign, getter=isEquailsWasTaped) BOOL equailsWasTaped;
@property(nonatomic, assign, getter=isDigitEnteringEnterupted) BOOL digitEnteringInterrupted;
@property(nonatomic, assign) int radix;

- (NSString *)toDecimal:(NSString *)displayLabel;
- (NSString *)fromDecimal:(double)operand;
- (double)decimalDisplayValue;

@end

@implementation CalculatorModel

- (id)init {
    if (self = [super init]) {
        __weak CalculatorModel *weakSelf = self;
        _mapOfBlocksOperations = @{
            //comented for adding + and - blocks in ViewController.
          //  YMACalculatorBrainPlus: [^{ return weakSelf.firstOperand + weakSelf.secondOperand; } copy],
          //  YMACalculatorBrainMinus: [^{ return weakSelf.firstOperand - weakSelf.secondOperand; } copy],
            YMACalculatorBrainMultiply: [^{ return weakSelf.firstOperand * weakSelf.secondOperand; } copy],
            YMACalculatorBrainDivide: [^{ return weakSelf.firstOperand / weakSelf.secondOperand; } copy],
            YMACalculatorBrainPrecent: [^{ return weakSelf.decimalDisplayValue / 100; } copy],
            YMACalculatorBrainSquareRoot: [^{ return sqrt(weakSelf.decimalDisplayValue); } copy],
            YMACalculatorBrainChangeSymbol: [^{//set that digit entering in not interrupted and user can continue entering digit after change symbol;
                                            weakSelf.digitEnteringInterrupted = NO;
                                            return 0 - weakSelf.decimalDisplayValue;} copy],
            YMACalculatorBrainClear: [^{weakSelf.firstOperand = NAN;
                                        weakSelf.secondOperand = NAN;
                                        weakSelf.operator = nil;
                                        return 0.0; } copy],
        };

        _firstOperand = NAN;
        _secondOperand = NAN;
        _radix = YMACalculatorBrainDefaultRadix;
    }
    return self;
}

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *_numberFormatter = nil;
    @synchronized (self) {
        if (!_numberFormatter) {
            _numberFormatter = [NSNumberFormatter new];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [_numberFormatter setLocale:locale];
            _numberFormatter.usesSignificantDigits = YES;
            _numberFormatter.maximumSignificantDigits = YMACalculatorBrainMaximumSignificantDigits;
            _numberFormatter.notANumberSymbol = YMACalculatorBrainErrorMessageNan;
            _numberFormatter.negativeInfinitySymbol = YMACalculatorBrainErrorMessageInf;
            _numberFormatter.positiveInfinitySymbol = YMACalculatorBrainErrorMessageInf;
        }
    }
    return _numberFormatter;
}

#pragma mark - Scale of notation

- (NSString *)toDecimal:(NSString *)displayLabel {

    //check if now in decimal than just return current value
    if (self.radix == 10) {
        return displayLabel;
    } else {
        return [NSString stringWithFormat:@"%ld", strtol([displayLabel UTF8String], NULL, self.radix)];
    }
}

- (NSString *)fromDecimal:(double)operand {
    NSString *returnValue = @"";
    switch (self.radix) {
    case 2: {
        //from decimal to binary
        NSUInteger x = operand;
        while (x > 0) {
            returnValue = [[NSString stringWithFormat:@"%lu", x & 1] stringByAppendingString:returnValue];
            x = x >> 1;
        }
        break;
    }
    case 8:returnValue = [NSString stringWithFormat:@"%o", (int) operand];
        break;
    case 10:returnValue = [NSString stringWithFormat:@"%g", operand];
        break;
    case 16:returnValue = [NSString stringWithFormat:@"%X", (int) operand];
        break;
    default:break;
    }
    return returnValue;
}

- (void)updatingRadix:(int)radix {

    if (self.radix != radix) {
        NSString *decimal = [self toDecimal:self.delegate.displayValue];
        self.radix = radix;
        [self resultUpdated:decimal];
    }
}

- (double)decimalDisplayValue {
    return [self toDecimal:self.delegate.displayValue].doubleValue;
}

#pragma mark - Actions

- (void)handleOperation:(NSString *)operation {
    //operation button work as equals button (and use operator entered before) IF first operator entered and digit entering NOT interrupted
    if (!isnan(self.firstOperand) && !self.digitEnteringInterrupted && !self.isEquailsWasTaped) {
        [self equals];
    } else {
        //SET first operand IF first operand not entered or if its happens after equals taped and its new operations.
        self.firstOperand = [self decimalDisplayValue];
    }
    //take current operator.
    self.operator = operation;
    //marking that the input of the digits was interrupted
    self.digitEnteringInterrupted = YES;
    //restore equailsWasTaped after changes in [self equalsTaped:self];
    self.equailsWasTaped = NO;
}

- (void)equals {
    //SET second operand - IF digit entering interrupted OR second operator is not entered;
    if (!self.digitEnteringInterrupted || isnan(self.secondOperand)) {
        self.secondOperand = [self decimalDisplayValue];;
    }
    //calculating operation
    [self executeOperation:self.operator];
    //result is first operand now;
    self.firstOperand = [self decimalDisplayValue];;
}

- (void)handleDigit:(NSString *)digit {
    //IF digit entering was interrupted or on display zero THAN start entering new display value
    if (([self.delegate.displayValue isEqualToString:YMACalculatorBrainZeroCharacter])
        || (self.digitEnteringInterrupted)) {
        //reset value for new input
        self.delegate.displayValue = @"";
        self.digitEnteringInterrupted = NO;
    }
    //add new taped digit
    self.delegate.displayValue = [self.delegate.displayValue stringByAppendingFormat:@"%@", digit];
}

- (void)resultUpdated:(NSString *)resultOfOperation {
    self.delegate.displayValue = [self fromDecimal:resultOfOperation.floatValue];
}

#pragma mark - Operations

- (void)executeOperation:(NSString *)operation {
    //marking that the input of the digits was interrupted
    self.digitEnteringInterrupted = YES;
    self.equailsWasTaped = YES;
    //operation block call
    double (^operationBlock)() = self.mapOfBlocksOperations[operation];
    self.result = operationBlock();
    [self resultUpdated:[CalculatorModel.numberFormatter stringFromNumber:@(self.result)]];
    //if result is error value than clear calculator model, and set setDigitEnteringInterrupted to reset displayLabel;
    if (isnan(self.result) || self.result == INFINITY) {
        self.delegate.displayValue = [CalculatorModel.numberFormatter stringFromNumber:@(self.result)];
        void(^clearBlock)() = self.mapOfBlocksOperations[YMACalculatorBrainClear];
        clearBlock();
    }
}

@end
