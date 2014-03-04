//
//  CenterViewController.h
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JsonData.h"
#import "DrawClass.h"
#import "SVPullToRefresh.h"
@protocol CenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;
-(void)setupGestures;
@required

-(void)movePanelToOriginalPosition;
-(void)movePanelToOriginalPositionformyProject;
-(void)movePanelToOriginalPositionformyTask;
@end
@interface CenterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int pageCounter;
    int index;
    int flag;
    
    DrawClass *drawObj;
    JsonData *jsonObj;
    UITableView *activityListTable;
    UITableView *projectListTable;
    UITableView *taskListTable;
    UITableView *memberTable;
    UITableView *projectDetailsTable;
    UITableView *taskDetailsTable;
    UITableView *projectTaskTable;
    UITableView *taskActivityTable;
    
    UIView *memberView;
    UIView *projectDetailsView;
    UIView *taskDetailsView;
    UIView *projectTaskView;
    UIView *taskActivityView;
    
    NSMutableArray *activities;
    NSMutableArray *dates;
    NSMutableArray *hours;
    NSMutableArray *NameArray;
    NSMutableArray *TypeArray;
    NSMutableArray *startDateArray;
    NSMutableArray *endDateArray;
    NSMutableArray *IdArray;
    NSMutableArray *memberArray;
    NSMutableArray *taskNameArray;
    NSMutableArray *backArray;
    
    UIActivityIndicatorView *activityIndicator;
    
    BOOL fromList;
    BOOL fromProject;
    BOOL fromTask;
    
}
@property (nonatomic, assign) id<CenterViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *back;
-(void)myProjectCall;
-(void)myTaskCall;
@end
