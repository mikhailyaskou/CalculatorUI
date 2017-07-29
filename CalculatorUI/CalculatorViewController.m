//
//  ViewController.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "CalculatorViewController.h"
#import "AboutUsViewController.h"

static NSString *const YMACalculatorViewControllerZeroCharacter = @"0";
static NSString *const YMACalculatorViewControllerDecimalSymbol = @".";
static int YMACalculatorViewControllerInterfaceOrientationPortrait = 1;
static int YMACalculatorViewControllerIndexStackViewPortraitPosition = 3;
static int YMACalculatorViewControllerIndexStackViewLandscapePosition = 0;
static int const YMACalculatorViewControllerDefaultRadix = 10;
static NSString *const YMACalculatorBrainPlus = @"+";
static NSString *const YMACalculatorBrainMinus = @"-";


@interface CalculatorModel ( YMAAddingOperationsExposingProperties )

@property(nonatomic, strong) NSDictionary *mapOfBlocksOperations;
@property(nonatomic, assign) double firstOperand;
@property(nonatomic, assign) double secondOperand;

@end

@interface CalculatorViewController ()

@property(strong, nonatomic) CalculatorModel *calculatorModel;
@property(strong, nonatomic) IBOutlet UILabel *resultLabel;
@property(strong, nonatomic) IBOutlet UIStackView *mainStackView;
@property(strong, nonatomic) IBOutlet UIStackView *operationStackView;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *allRadixButton;
@property(strong, nonatomic) IBOutletCollection(UIButton) NSArray *disabledButtonsInLandscapeMode;

@end

@implementation CalculatorViewController

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
    //draw interface depending on the orientation;
    [self updateInterfaceWhenOrientationChanged];
    //set radix to default;
    [self updateRadixAndInterface:YMACalculatorViewControllerDefaultRadix];
    //adding "new" operations
    [self addNewOperations];
}

- (void)addNewOperations {
    __weak CalculatorModel *weakCalculatorModel = self.calculatorModel;
    NSMutableDictionary *mutableDictionaryForNewOperations = [self.calculatorModel.mapOfBlocksOperations mutableCopy];
    // - and + operations just for example;
    mutableDictionaryForNewOperations[YMACalculatorBrainPlus] = [^{ return weakCalculatorModel.firstOperand + weakCalculatorModel.secondOperand; } copy];
    mutableDictionaryForNewOperations[YMACalculatorBrainMinus] = [^{ return weakCalculatorModel.firstOperand - weakCalculatorModel.secondOperand; } copy];
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

#pragma mark - Orintation managment

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    //redraw interface for current orientation
    [self updateInterfaceWhenOrientationChanged];
        //reset radix to decimal
    [self updateRadixAndInterface:YMACalculatorViewControllerDefaultRadix];
}

- (void)updateInterfaceWhenOrientationChanged {
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    BOOL radixDisableFlag;
    int indexStackView;
    if (interfaceOrientation == YMACalculatorViewControllerInterfaceOrientationPortrait) {
        radixDisableFlag = YES;
        indexStackView = YMACalculatorViewControllerIndexStackViewPortraitPosition;
    } else {
        indexStackView = YMACalculatorViewControllerIndexStackViewLandscapePosition;
        radixDisableFlag = NO;
    }
    for (UIButton *button in self.allRadixButton) {
        button.hidden = radixDisableFlag;
    }
    for (UIButton *button in self.disabledButtonsInLandscapeMode) {
        button.enabled = radixDisableFlag;
    }
    [self.mainStackView removeArrangedSubview:self.operationStackView];
    [self.mainStackView insertArrangedSubview:self.operationStackView atIndex:indexStackView];
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
