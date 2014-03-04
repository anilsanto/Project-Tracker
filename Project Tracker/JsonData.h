//
//  JsonData.h
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonData : NSObject
{
    
}
@property(strong)NSMutableArray *activiyArray;
@property(strong)NSMutableArray *dateArray;
@property(strong)NSMutableArray *hourSpentArray;
@property(strong)NSMutableArray *nameArray;
@property(strong)NSMutableArray *typeArray;
@property(strong)NSMutableArray *startDateArray;
@property(strong)NSMutableArray *endDateArray;
@property(strong)NSMutableArray *memberArray;
@property(strong)NSMutableArray *idArray;
@property(strong)NSMutableArray *taskNameArray;
@property(strong)NSMutableArray *emailArray;
@property(strong)NSMutableArray *taskArray;

@property(strong)NSString *projectName;
@property(strong)NSString *projectType;
@property(strong)NSString *projectTeamLead;
@property(strong)NSString *projectImplOwner;
@property(strong)NSString *projectStatus;
@property(strong)NSString *projectSchedStatus;
@property(strong)NSString *projectStatusDesc;
@property(strong)NSString *projectStage;
@property(strong)NSString *projectCompleted;
@property(strong)NSString *projectPlanSDate;
@property(strong)NSString *projectPlanEDate;
@property(strong)NSString *projectActualSDate;
@property(strong)NSString *projectActualEDate;
@property(strong)NSString *projectTotalHour;
@property(strong)NSString *projectActualHour;
@property(strong)NSString *projectRemainHour;
@property(strong)NSString *projectClientName;
@property(strong)NSString *projectClientContact;
@property(strong)NSString *taskDesc;
@property(strong)NSString *taskPlanEffort;
@property(strong)NSString *taskCost;
@property(strong)NSString *taskPriority;
@property(strong)NSString *WBScode;

@property(strong)NSMutableString *Users;
@property(strong)NSMutableString *recentActivities;

-(void)getActivitie:(NSDictionary *)dict;
-(void)getProject:(NSDictionary *)dict;
-(void)getTask:(NSDictionary *)dict;
-(void)getMember:(NSArray *)array;
-(void)getProjectDetails:(NSDictionary *)dict;
-(void)getProjectTask:(NSDictionary *)dict;
-(void)getTaskDetails:(NSDictionary *)dict;
-(void)getTaskActivities:(NSDictionary *)dict;
-(void)getOpenTask:(NSDictionary *)dict;
@end
