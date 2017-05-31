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

@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) Calculator *calculatorModel;
//@property (assign, nonatomic, getter=isDigitEnteringEnterupted) BOOL digitEnteringEnterupted;
//@property (assign, nonatomic, getter=isEquailsWasTaped) BOOL equailsWasTaped;
@property (retain, nonatomic) IBOutlet UIStackView *mainStackView;
@property (retain, nonatomic) IBOutlet UIStackView *operationStackView;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *allDigits;

@end


@implementation CalculatorViewController

@synthesize equailsWasTaped = _equailsWasTaped;
@synthesize digitEnteringEnterupted = _digitEnteringEnterupted;
@synthesize displayValue = _displayValue;



-(void)setDisplayValue:(NSString *)displayValue {
    
    if (_displayValue!=displayValue){
        [_displayValue release];
        _displayValue = [displayValue retain];
    }
    self.resultLabel.text = displayValue;
}

-(NSString *)displayValue{
    return  self.resultLabel.text;
}

NSString *const zeroCharacher = @"0";
NSString *const dotCharachter = @".";


- (void)dealloc {
    
    [_resultLabel release];
    [_calculatorModel release];
    [_operationStackView release];
    [_mainStackView release];
    [super dealloc];
}


- (void)viewDidLoad {
    
    self.calculatorModel = [[Calculator new] autorelease];
    self.calculatorModel.delegate = self;
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)]autorelease];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    
}

- (IBAction)deleteLastDigitTaped:(id)sender {
    [self deleteLastDigit];
}

- (void)deleteLastDigit{
    
    self.displayValue = (self.displayValue.length > 1) ? [self.displayValue substringToIndex: self.displayValue.length -1] : zeroCharacher;
}

- (IBAction)dotTaped:(id)sender {
    
    NSRange range = [self.displayValue rangeOfString:dotCharachter];
    if (range.location == NSNotFound)
    {
        self.displayValue = [self.displayValue stringByAppendingString:dotCharachter];
    }
}

- (IBAction)clearTaped:(UIButton *)sender {
    [self.calculatorModel executeOperation:sender.currentTitle];
}

#pragma mark Calculate operatins


- (IBAction)digitTaped:(UIButton *)sender {
    
    //IF digit entering was interrupted or on display zero THAN start entering new display value
    if (([self.displayValue isEqualToString: zeroCharacher]) || (self.isDigitEnteringEnterupted)){
        
        self.displayValue=@"";
        self.digitEnteringEnterupted = NO;
    }
    self.displayValue = [self.displayValue stringByAppendingFormat:@"%@", sender.titleLabel.text];
}


- (IBAction)unaryOperationTaped:(UIButton *)sender {

    self.calculatorModel.unaryOperand = self.displayValue.doubleValue;
    [self.calculatorModel executeOperation: sender.currentTitle];
}


- (IBAction)operationTaped:(UIButton *)sender {
    
    [self.calculatorModel operationTaped: sender.currentTitle];
}


- (IBAction)equalsTaped:(id)sender {
    
    [self.calculatorModel equalsTaped];
}


-(void)resultUpdated:(NSString *)resultOfOperation{
    
    self.displayValue = [self.calculatorModel fromDecemial: resultOfOperation.floatValue];
}

#pragma mark ViewControl Managment

- (IBAction)radixTaped:(UIButton*)sender {

    if (self.calculatorModel.radix !=sender.currentTitle.intValue){
        
        NSString *decemial = [self.calculatorModel toDecemial:self.displayValue];
        self.calculatorModel.radix = sender.currentTitle.intValue;
    
        //disable all buttos that less than crrent base.
        for(UIButton *button in self.allDigits){
            if (button.tag >= self.calculatorModel.radix){
                button.enabled = NO;
            }else{
                button.enabled = YES;
            }
        }
     [self resultUpdated: decemial];
    }
}

- (IBAction)aboutTaped:(id)sender {
    
     [self.navigationController pushViewController: [[AboutUsViewController new]autorelease] animated: YES];
}


- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{

    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    int indexStackView;
    if (interfaceOrientation==1){
        indexStackView = 3;
    }else{
        indexStackView = 0;
    }
    [self.mainStackView removeArrangedSubview: self.operationStackView];
    [self.mainStackView insertArrangedSubview:self.operationStackView atIndex: indexStackView];
}


@end
