//
//  YMAEngineeringCalculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 17.07.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "YMAEngineeringCalculator.h"
#import "AboutUsViewController.h"

static NSString *const YMACalculatorViewControllerZeroCharacter = @"0";
static NSString *const YMACalculatorViewControllerDecimalSymbol = @".";
static int const YMACalculatorViewControllerDefaultRadix = 10;
static NSString *const YMACalculatorBrainPi = @"π";
static NSString *const YMACalculatorBrainEulerNumber = @"e";
static NSString *const YMACalculatorBrainNaturalLogarithm = @"ln";
static NSString *const YMACalculatorBrainSin = @"sin";
static NSString *const YMACalculatorBrainCos = @"cos";
static NSString *const YMACalculatorBrainTan = @"tan";
static NSString *const YMACalculatorBrainCtg = @"ctg";

@interface CalculatorModel ( YMAAddingOperationsExposingProperties )

@property(nonatomic, strong) NSDictionary *mapOfBlocksOperations;
@property(nonatomic, assign) double firstOperand;
@property(nonatomic, assign) double secondOperand;

- (double)decimalDisplayValue;

@end

@interface YMAEngineeringCalculator ()

@property(strong, nonatomic) CalculatorModel *calculatorModel;
@property(strong, nonatomic) IBOutlet UILabel *resultLabel;
@property(strong, nonatomic) IBOutlet UIStackView *mainStackView;
@property(strong, nonatomic) IBOutlet UIStackView *operationStackView;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;

@end

@implementation YMAEngineeringCalculator

@synthesize displayValue = _displayValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calculatorModel = [CalculatorModel new];
    self.calculatorModel.delegate = self;
    //adding gesture for delete last digit
    UISwipeGestureRecognizer
        *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    //adding "new" operations
    [self addNewOperations];
}

- (void)addNewOperations {
    __weak CalculatorModel *weakCalculatorModel = self.calculatorModel;
    NSMutableDictionary *mutableDictionaryForNewOperations = [self.calculatorModel.mapOfBlocksOperations mutableCopy];

    mutableDictionaryForNewOperations[YMACalculatorBrainPi] = [^{ return M_PI; } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainEulerNumber] = [^{ return M_E; } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainNaturalLogarithm] = [^{ return log([weakCalculatorModel decimalDisplayValue]); } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainSin] = [^{ return sin([weakCalculatorModel decimalDisplayValue]); } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainCos] = [^{ return cos([weakCalculatorModel decimalDisplayValue]);; } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainTan] = [^{ return tan([weakCalculatorModel decimalDisplayValue]);; } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainCtg] = [^{ return cos([weakCalculatorModel decimalDisplayValue])/sin([weakCalculatorModel decimalDisplayValue]); } copy];

    self.calculatorModel.mapOfBlocksOperations = [mutableDictionaryForNewOperations copy];
}

#pragma mark - Actioans

- (IBAction)clearTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation:sender.currentTitle];
}

- (IBAction)deleteLastDigitTaped:(id)sender {
    [self deleteLastDigit];
}

- (void)deleteLastDigit {
    //this method uses twice - when button pressed, and with swipe
    self.displayValue = (self.displayValue.length > 1) ? [self.displayValue substringToIndex:self.displayValue.length
        - 1] : YMACalculatorViewControllerZeroCharacter;
}

#pragma mark - Calculate actioans

- (IBAction)dotTaped:(id)sender {
    NSRange range = [self.displayValue rangeOfString:YMACalculatorViewControllerDecimalSymbol];
    if (range.location == NSNotFound) {
        self.displayValue = [self.displayValue stringByAppendingString:YMACalculatorViewControllerDecimalSymbol];
    }
}

- (IBAction)digitTaped:(UIButton *)sender {
    [self.calculatorModel handleDigit:sender.currentTitle];
}

- (IBAction)unaryOperationTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation:sender.currentTitle];
}

- (IBAction)operationTaped:(UIButton *)sender {
    [self.calculatorModel handleOperation:sender.currentTitle];
}

- (IBAction)equalsTaped:(id)sender {
    [self.calculatorModel equals];
}

#pragma mark - ViewControl Managment

- (IBAction)aboutTaped:(id)sender {
    [self.navigationController pushViewController:[AboutUsViewController new] animated:YES];
}

#pragma mark - CalculatorDelegate

- (void)setDisplayValue:(NSString *)displayValue {

    if (_displayValue != displayValue) {
        _displayValue = displayValue;
    }
    self.resultLabel.text = displayValue;
}

- (NSString *)displayValue {
    return self.resultLabel.text;
}

@end
