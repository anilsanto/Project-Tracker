//
//  ViewController.h
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ViewController : UIViewController
{
    NSMutableArray *placeHolder;
    NSMutableArray *TextStringArray;
    NSString *email;
    NSString *password;
    
    UIButton *signinbutton;
    UIButton *forgotbtn;
    
    int txY,txtheight,regY,socialY,socialheight,forgotY;
}
@property(strong)NSString *str;
@end
