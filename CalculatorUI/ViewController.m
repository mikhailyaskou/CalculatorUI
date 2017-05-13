//
//  ViewController.m
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (retain, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

NSString *const zeroCharacher = @"0";
NSString *const dotCharachter = @".";

- (void)viewDidLoad {
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastDigit)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.resultLabel addGestureRecognizer:swipe];
}

- (IBAction)clearTaped:(id)sender {
    self.resultLabel.text = zeroCharacher;
}


- (void)deleteLastDigit{
    
    self.resultLabel.text = (self.resultLabel.text.length > 1) ? [self.resultLabel.text substringToIndex: self.resultLabel.text.length -1] : zeroCharacher;
}

- (IBAction)dotTaped:(id)sender {
    
    NSRange range = [self.resultLabel.text rangeOfString:dotCharachter];
    if (range.location == NSNotFound)
    {
        self.resultLabel.text = [self.resultLabel.text stringByAppendingString:dotCharachter];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)digitTaped:(UIButton *)sender {
    
    if ([self.resultLabel.text isEqualToString: zeroCharacher]){
        
        self.resultLabel.text=@"";
    }
    self.resultLabel.text = [self.resultLabel.text stringByAppendingFormat:@"%.0f", sender.titleLabel.text.floatValue];
}


- (void)dealloc {
    [_resultLabel release];
    [super dealloc];
}
@end
