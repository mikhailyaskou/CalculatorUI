//
//  ViewController.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "CalculatorViewController.h"
#import "AboutUsViewController.h"

static NSString * const YMACalculatorViewControllerZeroCharacher = @"0";
static NSString * const YMACalculatorViewControllerDecimalSymbol = @".";
static int YMACalculatorViewControllerInterfaceOrientationPortrait = 1;
static int YMACalculatorViewControllerIndexStackViewPortraitPosition = 3;
static int YMACalculatorViewControllerIndexStackViewLandscapePosition = 0;
static int const YMACalculatorViewControllerDefaultRadix = 10;

@interface CalculatorViewController ()

@property (retain, nonatomic) CalculatorModel *calculatorModel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UIStackView *mainStackView;
@property (retain, nonatomic) IBOutlet UIStackView *operationStackView;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *allRadixButton;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *disabledButtonsInLandscapeMode;

@end

@implementation CalculatorViewController

@synthesize displayValue = _displayValue;

- (void)dealloc {
    [_resultLabel release];
    [_calculatorModel release];
    [_operationStackView release];
    [_mainStackView release];
    [_allDigits release];
    [_displayValue release];
    [_allRadixButton release];
    [_disabledButtonsInLandscapeMode release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //connect model
    self.calculatorModel = [[CalculatorModel new] autorelease];
    //connect delegate
    self.calculatorModel.delegate = self;
    //adding gesture for delete last digit
    UISwipeGestureRecognizer *swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)]autorelease];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    //drow interface depending on the orientation;
    [self updateInterfaceWhenOrientationChanged];
    //set radix to default;
    [self updateRadixAndInterface: YMACalculatorViewControllerDefaultRadix];
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
    self.displayValue = (self.displayValue.length > 1) ? [self.displayValue substringToIndex:self.displayValue.length -1] : YMACalculatorViewControllerZeroCharacher;
}

- (IBAction)dotTaped:(id)sender {
    NSRange range = [self.displayValue rangeOfString:YMACalculatorViewControllerDecimalSymbol];
    if (range.location == NSNotFound) {
        self.displayValue = [self.displayValue stringByAppendingString:YMACalculatorViewControllerDecimalSymbol];
    }
}

#pragma mark - Calculate actioans

- (IBAction)digitTaped:(UIButton *)sender {
    [self.calculatorModel handleDigit:sender.currentTitle];
}

- (IBAction)unaryOperationTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation: sender.currentTitle];
}

- (IBAction)operationTaped:(UIButton *)sender {
    [self.calculatorModel handleOperation: sender.currentTitle];
}

- (IBAction)equalsTaped:(id)sender {
    [self.calculatorModel equals];
}

#pragma mark - ViewControl Managment

- (IBAction)aboutTaped:(id)sender {
    [self.navigationController pushViewController: [[AboutUsViewController new]autorelease] animated: YES];
}

- (IBAction)radixTaped:(UIButton*)sender {
    [self updateRadixAndInterface:sender.currentTitle.intValue];
}

- (void)updateRadixAndInterface:(int) radix {
    //update value
    [self.calculatorModel updatingRadix: radix];
    //update interface
    for (UIButton *button in self.allDigits) {
        button.enabled = button.tag < radix ? YES : NO;
    }
}

#pragma mark - Orintation managment

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id< UIViewControllerTransitionCoordinator>)coordinator {
    //redrow interface for current orientaion
    [self updateInterfaceWhenOrientationChanged];
    //reset radix to decemial
    [self updateRadixAndInterface: YMACalculatorViewControllerDefaultRadix];
}

- (void)updateInterfaceWhenOrientationChanged {
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    BOOL radixDisableFlag;
    int indexStackView;
    if (interfaceOrientation == YMACalculatorViewControllerInterfaceOrientationPortrait){
        radixDisableFlag = YES;
        indexStackView = YMACalculatorViewControllerIndexStackViewPortraitPosition;
    }
    else {
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
    
    if (_displayValue!=displayValue) {
        [_displayValue release];
        _displayValue = [displayValue retain];
    }
    self.resultLabel.text = displayValue;
}

- (NSString *)displayValue {
    return  self.resultLabel.text;
}

@end
