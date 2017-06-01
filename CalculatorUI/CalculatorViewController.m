//
//  ViewController.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "CalculatorViewController.h"
#import "AboutUsViewController.h"


@interface CalculatorViewController ()

@property (retain, nonatomic) Calculator *calculatorModel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UIStackView *mainStackView;
@property (retain, nonatomic) IBOutlet UIStackView *operationStackView;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *allRadixButton;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *disabledButtonsInLandscapeMode;
@property (retain, nonatomic) NSString *decimalSymbol;

@end


@implementation CalculatorViewController

static NSString *const zeroCharacher = @"0";
static int interfaceOrientationPortrait = 1;
static int indexStackViewPortraitPosition = 3;
static int indexStackViewLandscapePosition = 0;
static int const defaultRadix = 10;

@synthesize displayValue = _displayValue;


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
    self.calculatorModel = [[Calculator new] autorelease];
    //connect delegate
    self.calculatorModel.delegate = self;
    //adding gesture for delete last digit
    UISwipeGestureRecognizer *swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)]autorelease];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    //drow interface depending on the orientation;
    [self updateInterfaceWhenOrientationChanged];
    //set radix to default;
    [self updateRadixAdndInterface: defaultRadix];
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    self.decimalSymbol = [formatter decimalSeparator];
}


- (IBAction)deleteLastDigitTaped:(id)sender {
    [self deleteLastDigit];
}


- (void)deleteLastDigit {
    self.displayValue = (self.displayValue.length > 1) ? [self.displayValue substringToIndex:self.displayValue.length -1] : zeroCharacher;
}

- (IBAction)dotTaped:(id)sender {
    NSRange range = [self.displayValue rangeOfString:self.decimalSymbol];
    if (range.location == NSNotFound) {
        self.displayValue = [self.displayValue stringByAppendingString:self.decimalSymbol];
    }
}


- (IBAction)clearTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation:sender.currentTitle];
}


#pragma mark Calculate operatins


- (IBAction)digitTaped:(UIButton *)sender {
    [self.calculatorModel digitTaped:sender.currentTitle];
}


- (IBAction)unaryOperationTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation: sender.currentTitle];
}


- (IBAction)operationTaped:(UIButton *)sender {
    [self.calculatorModel operationTaped: sender.currentTitle];
}


- (IBAction)equalsTaped:(id)sender {
    [self.calculatorModel equalsTaped];
}

#pragma mark ViewControl Managment

- (IBAction)radixTaped:(UIButton*)sender {
    
    [self updateRadixAdndInterface:sender.currentTitle.intValue];
}

- (void)updateRadixAdndInterface:(int) radix {
    //update value
    [self.calculatorModel updatingRadix: radix];
    //update interface
    for (UIButton *button in self.allDigits) {
        if (button.tag >= radix){
            button.enabled = NO;
        } else {
            button.enabled = YES;
        }
    }
}

- (IBAction)aboutTaped:(id)sender {
    
    [self.navigationController pushViewController: [[AboutUsViewController new]autorelease] animated: YES];
}


- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id< UIViewControllerTransitionCoordinator>)coordinator {
    //redrow interface for current orientaion
    [self updateInterfaceWhenOrientationChanged];
    //reset radix to decemial
    [self updateRadixAdndInterface: defaultRadix];
}

- (void)updateInterfaceWhenOrientationChanged {
        UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
        BOOL radixDisableFlag;
        int indexStackView;
        if (interfaceOrientation == interfaceOrientationPortrait){
            radixDisableFlag = YES;
            indexStackView = indexStackViewPortraitPosition;
        } else {
            indexStackView = indexStackViewLandscapePosition;
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


@end
