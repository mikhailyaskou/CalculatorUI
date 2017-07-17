//
//  YMASimpleCalculator.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 16.07.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "AboutUsViewController.h"
#import "CalculatorModel.h"
#import "YMASimpleCalculator.h"

static NSString *const YMACalculatorViewControllerZeroCharacter = @"0";
static NSString *const YMACalculatorViewControllerDecimalSymbol = @".";

@interface YMASimpleCalculator ()

@property(strong, nonatomic) CalculatorModel *calculatorModel;
@property(strong, nonatomic) IBOutlet UILabel *resultLabel;
@property(strong, nonatomic) IBOutlet UIStackView *mainStackView;
@property(strong, nonatomic) IBOutlet UIStackView *operationStackView;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;

@end

@implementation YMASimpleCalculator

@synthesize displayValue = _displayValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    //connect model
    self.calculatorModel = [CalculatorModel new];
    //connect delegate
    self.calculatorModel.delegate = self;
    //adding gesture for delete last digit
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
}

#pragma mark - Actioans

- (IBAction)clearTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation:sender.currentTitle];
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
