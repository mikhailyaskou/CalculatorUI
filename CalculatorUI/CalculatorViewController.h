//
//  CalculatorViewController.h
//  CalculatorUI
//
//  Created by Mikhail Yaskou on 11.05.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calculator.h"

@protocol CalculatorDelegate;

@interface CalculatorViewController : UIViewController <CalculatorDelegate>

@end

