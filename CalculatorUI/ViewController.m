//
//  ViewController.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "ViewController.h"
#import "AboutUS.h"
#import "Calculator.h"


@interface ViewController ()

@property (retain, nonatomic) AboutUS *aboutView;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) Calculator *calculatorModel;
@property (assign, nonatomic) BOOL isDigitEnteringEnterupted;

@end

@implementation ViewController

NSString *const zeroCharacher = @"0";
NSString *const dotCharachter = @".";


- (void)dealloc {
    [_aboutView release];
    [_resultLabel release];
    [_calculatorModel release];
    [super dealloc];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)]autorelease];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
    [self clearTaped:self];
    }


- (void)deleteLastDigit{
    
    self.resultLabel.text = (self.resultLabel.text.length > 1) ? [self.resultLabel.text substringToIndex: self.resultLabel.text.length -1] : zeroCharacher;
}

- (IBAction)clearTaped:(id)sender {
    self.resultLabel.text = zeroCharacher;
    self.calculatorModel = [[Calculator new] autorelease];
    self.isDigitEnteringEnterupted = NO;
}


- (IBAction)dotTaped:(id)sender {
    
    NSRange range = [self.resultLabel.text rangeOfString:dotCharachter];
    if (range.location == NSNotFound)
    {
        self.resultLabel.text = [self.resultLabel.text stringByAppendingString:dotCharachter];
    }
}


- (IBAction)unaryOperationTaped:(UIButton *)sender {
    
    self.calculatorModel.operator = sender.currentTitle;
    self.calculatorModel.unaryOperand = self.resultLabel.text.doubleValue;
    self.resultLabel.text = [NSString stringWithFormat:@"%g", [self.calculatorModel executeOperation: self.calculatorModel.operator]];
}


- (IBAction)operationTaped:(UIButton *)sender {

    self.calculatorModel.operator = sender.currentTitle;
    
    if (!isnan(self.calculatorModel.firstOperand) && (!self.isDigitEnteringEnterupted)){
        
        [self equalsTaped:self];
    }

    if (isnan(self.calculatorModel.firstOperand)) {
        
        self.calculatorModel.firstOperand = self.resultLabel.text.floatValue;;
    }
    
    self.isDigitEnteringEnterupted = YES;
    }


- (IBAction)equalsTaped:(id)sender {
    
    if (!self.isDigitEnteringEnterupted || isnan(self.calculatorModel.secondOperand)) {
        
    self.calculatorModel.secondOperand = self.resultLabel.text.doubleValue;
    }

    self.resultLabel.text = [NSString stringWithFormat:@"%g", [self.calculatorModel executeOperation:self.calculatorModel.operator]];
    self.calculatorModel.firstOperand = self.resultLabel.text.doubleValue;
    
    self.isDigitEnteringEnterupted = YES;
}


- (IBAction)digitTaped:(UIButton *)sender {
    
    if (([self.resultLabel.text isEqualToString: zeroCharacher]) || (self.isDigitEnteringEnterupted)){
        
        self.resultLabel.text=@"";
        self.isDigitEnteringEnterupted = NO;
    }
    self.resultLabel.text = [self.resultLabel.text stringByAppendingFormat:@"%g", sender.titleLabel.text.floatValue];
}


#pragma mark ViewControl Managment

- (IBAction)aboutTaped:(id)sender {
    
    self.aboutView = [[[AboutUS alloc] init] autorelease];
    [self.navigationController pushViewController:self.aboutView animated: YES];
}


@end
