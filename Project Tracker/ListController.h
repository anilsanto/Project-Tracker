//
//  ListController.h
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CenterViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60
@interface ListController : UIViewController<CenterViewControllerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong)CenterViewController *centerViewController;
@property (nonatomic, strong) LeftViewController *leftPanelViewController;
@property (nonatomic, strong) RightViewController *rightPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) CGPoint preVelocity;

@end
