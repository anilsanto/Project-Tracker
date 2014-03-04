
//  JsonData.m
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "JsonData.h"

@implementation JsonData
-(id)init{
    self = [super init];
    self.activiyArray=[[NSMutableArray alloc]init];
    self.dateArray=[[NSMutableArray alloc]init];
    self.hourSpentArray=[[NSMutableArray alloc]init];
    self.nameArray=[[NSMutableArray alloc]init];
    self.typeArray=[[NSMutableArray alloc]init];
    self.startDateArray=[[NSMutableArray alloc]init];
    self.endDateArray=[[NSMutableArray alloc]init];
    self.memberArray=[[NSMutableArray alloc]init];
    self.idArray=[[NSMutableArray alloc]init];
    self.taskNameArray=[[NSMutableArray alloc]init];
    self.emailArray=[[NSMutableArray alloc]init];
    self.taskArray=[[NSMutableArray alloc]init];
    
    self.Users=[[NSMutableString alloc]initWithFormat:@""];
    self.recentActivities=[[NSMutableString alloc]initWithFormat:@""];
    return self;
}

-(void)getActivitie:(NSDictionary *)dict
{
    NSArray *activities=dict[@"activities"];
    for(int i=0;i<[activities count];i++)
    {
        [self.activiyArray addObject:[activities objectAtIndex:i][@"activity"]];
        [self.dateArray addObject:[activities objectAtIndex:i][@"formated_start_date"]];
        [self.hourSpentArray addObject:[activities objectAtIndex:i][@"total_hours_spent"]];
    }
    
}
-(void)getProject:(NSDictionary *)dict 
{
    NSArray *projects=dict[@"projects"];
    for(int i=0;i<[projects count];i++)
    {
        [self.nameArray addObject:[projects objectAtIndex:i][@"name"]];
        [self.typeArray addObject:[projects objectAtIndex:i][@"formated_project_types"]];
        [self.startDateArray addObject:[projects objectAtIndex:i][@"formated_planned_start_date"]];
        [self.endDateArray addObject:[projects objectAtIndex:i][@"formated_planned_end_date"]];
        [self.idArray addObject:[projects objectAtIndex:i][@"id"]];
        [self.memberArray addObject:[projects objectAtIndex:i][@"members"]];
    }
}
-(void)getTask:(NSDictionary *)dict
{
    NSArray *Tasks=dict[@"tasks"];
    for(int i=0;i<[Tasks count];i++)
    {
        [self.nameArray addObject:[Tasks objectAtIndex:i][@"taskable"][@"name"]];
        [self.taskNameArray addObject:[Tasks objectAtIndex:i][@"task"]];
        [self.startDateArray addObject:[Tasks objectAtIndex:i][@"formated_planned_start_date"]];
        [self.endDateArray addObject:[Tasks objectAtIndex:i][@"formated_planned_end_date"]];
        [self.memberArray addObject:[Tasks objectAtIndex:i][@"members"]];
        [self.idArray addObject:[Tasks objectAtIndex:i][@"id"]];
    }

}
-(void)getMember:(NSArray *)array
{
    for(int i=0;i<[array count];i++)
    {
        [self.nameArray addObject:[array objectAtIndex:i][@"name"]];
        [self.emailArray addObject:[array objectAtIndex:i][@"email"]];
    }
}
-(void)getProjectDetails:(NSDictionary *)dict
{
    NSDictionary *project=dict[@"project"];
    self.projectName=project[@"name"];
    self.projectImplOwner=project[@"formated_implementation_owner"];
    self.projectTeamLead=project[@"formated_dev_supervisor"];
    self.projectType=project[@"formated_project_types"];
    self.projectStatus=project[@"status"];
    self.projectSchedStatus=project[@"schedule_status"];
    self.projectStatusDesc=project[@"status_description"];
    self.projectStage=project[@"stage"];
    self.projectCompleted=project[@"percentage_completed"];
    self.projectPlanSDate=project[@"formated_planned_start_date"];
    self.projectPlanEDate=project[@"formated_planned_end_date"];
    self.projectActualSDate=project[@"formated_actual_start_date"];
    self.projectActualEDate=project[@"formated_actual_end_date"];
    self.projectTotalHour=project[@"total_hours_planned"];
    self.projectActualHour=project[@"actual_hours_till_date"];
    self.projectRemainHour=project[@"remaining_hours"];
    self.projectClientName=project[@"client_name"];
    self.projectClientContact=project[@"client_contact"];
    
}
-(void)getProjectTask:(NSDictionary *)dict
{
    NSArray *Tasks=dict[@"recent_tasks"];
    for(int i=0;i<[Tasks count];i++)
    {
        [self.nameArray addObject:[Tasks objectAtIndex:i][@"taskable"][@"name"]];
        [self.taskNameArray addObject:[Tasks objectAtIndex:i][@"task"]];
        [self.startDateArray addObject:[Tasks objectAtIndex:i][@"formated_planned_start_date"]];
        [self.endDateArray addObject:[Tasks objectAtIndex:i][@"formated_planned_end_date"]];
        [self.memberArray addObject:[Tasks objectAtIndex:i][@"members"]];
        [self.idArray addObject:[Tasks objectAtIndex:i][@"id"]];
    }

}
-(void)getTaskDetails:(NSDictionary *)dict
{
    NSDictionary *task=dict[@"task"];
    
    self.projectPlanSDate=task[@"formated_planned_start_date"];
    self.projectPlanEDate=task[@"formated_planned_end_date"];
    self.projectActualSDate=task[@"formated_actual_start_date"];
    self.projectActualEDate=task[@"formated_actual_end_date"];
    self.projectCompleted=task[@"percentage_completed"];
    self.projectName=task[@"taskable"][@"name"];
    self.taskDesc=task[@"task"];
    self.taskPlanEffort=task[@"planned_effort"];
    self.taskCost=task[@"planned_cost"];
    self.taskPriority=task[@"priority"];
    self.projectStatus=task[@"status"];
    self.WBScode=task[@"wbs_code"];
    for (int i=0; i<[task[@"members"] count]; i++) {
        [self.Users appendFormat:@"%@ \n",[task[@"members"] objectAtIndex:i][@"name"]];
    }
    for (int i=0; i<[dict[@"recent_activities"] count]; i++) {
        [self.recentActivities appendFormat:@"-%@ \n",[dict[@"recent_activities"] objectAtIndex:i][@"activity"]];
        
    }
    
}
-(void)getTaskActivities:(NSDictionary *)dict
{
    NSArray *activities=dict[@"recent_activities"];
    for (int i=0; i<activities.count; i++) {
        [self.activiyArray addObject:[activities objectAtIndex:i][@"activity"]];
    }
    
}
-(void)getOpenTask:(NSDictionary *)dict
{
    NSArray *task=dict[@"tasks"];
    for (int i=0; i<task.count; i++) {
        if([[task objectAtIndex:i][@"status"] isEqualToString:@"in_progress"])
        {
            [self.taskArray addObject:[task objectAtIndex:i][@"task"] ];
            [self.nameArray addObject:[task objectAtIndex:i][@"taskable"][@"name"]];
            [self.idArray addObject:[task objectAtIndex:i][@"id"]];
        }
    }
}
@end
