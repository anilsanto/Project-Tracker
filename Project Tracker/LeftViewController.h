//
//  LeftViewController.h
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LeftViewControllerDelegate <NSObject>

@optional
-(void)myProjectBack;
-(void)myTaskBack;

@required
@end
@interface LeftViewController : UIViewController<LeftViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *listTable;
    NSURLConnection *connectionsignout;
}
@property (nonatomic, assign) id<LeftViewControllerDelegate> delegate;

@end
