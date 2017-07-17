//
//  YMANumeralSystemsCalculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 17.07.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "YMANumeralSystemsCalculator.h"
#import "AboutUsViewController.h"

static NSString *const YMACalculatorViewControllerZeroCharacter = @"0";
static NSString *const YMACalculatorViewControllerDecimalSymbol = @".";
static int const YMACalculatorViewControllerDefaultRadix = 10;

@interface YMANumeralSystemsCalculator ()

@property(strong, nonatomic) CalculatorModel *calculatorModel;
@property(strong, nonatomic) IBOutlet UILabel *resultLabel;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allRadixButton;

@end

@implementation YMANumeralSystemsCalculator

@synthesize displayValue = _displayValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    //connect model
    self.calculatorModel = [CalculatorModel new];
    //connect delegate
    self.calculatorModel.delegate = self;
    //adding gesture for delete last digit
    UISwipeGestureRecognizer
        *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    //set radix to default;
    [self updateRadixAndInterface:YMACalculatorViewControllerDefaultRadix];
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

- (IBAction)radixTaped:(UIButton *)sender {
    [self updateRadixAndInterface:sender.currentTitle.intValue];
}

- (void)updateRadixAndInterface:(int)radix {
    //update value
    [self.calculatorModel updatingRadix:radix];
    //update interface
    for (UIButton *button in self.allDigits) {
        button.enabled = button.tag < radix;
    }
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
