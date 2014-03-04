//
//  RightViewController.h
//  Project Tracker
//
//  Created by Nuevalgo on 03/03/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonData.h"
#import "DropDownView.h"

@protocol RightPanelViewControllerDelegate <NSObject>

@optional

@required


@end

@interface RightViewController : UIViewController
{
    JsonData *jsonObj;
    UIView *bgView;
    UIButton *dropDownBtn;
    
    UITextField  *date;
    UITextField  *hour;
    UITextField  *activity;
    
    int index;
    
    DropDownView *dropDownView;
}
@property (nonatomic, assign) id<RightPanelViewControllerDelegate> delegate;
@end
