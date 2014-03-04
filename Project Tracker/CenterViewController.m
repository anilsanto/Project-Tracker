//
//  CenterViewController.m
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "CenterViewController.h"
#define kUrl @"http://offers2win.com/project-tracker/"
@interface CenterViewController ()

@end

@implementation CenterViewController
@synthesize leftButton,delegate,back;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScreen *screen = [UIScreen mainScreen];
    [self.view setFrame:[screen applicationFrame]];
    UIImageView *backImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backImage.image=[UIImage imageNamed:@"ListBg"];
    [self.view addSubview:backImage];
    // Do any additional setup after loading the view from its nib.
    [self calactivityNew];
    [self basicInit];
    [self callmyActivities];
    
}
-(void)basicInit
{
    activities=[[NSMutableArray alloc]init];
    dates=[[NSMutableArray alloc]init];
    hours=[[NSMutableArray alloc]init];
    NameArray=[[NSMutableArray alloc]init];
    TypeArray=[[NSMutableArray alloc]init];
    startDateArray=[[NSMutableArray alloc]init];
    endDateArray=[[NSMutableArray alloc]init];
    memberArray=[[NSMutableArray alloc]init];
    IdArray=[[NSMutableArray alloc]init];
    taskNameArray=[[NSMutableArray alloc]init];
    backArray=[[NSMutableArray alloc]init];
}
-(void)clearArray
{
    [activities removeAllObjects];
    [dates removeAllObjects];
    [hours removeAllObjects];
    [NameArray removeAllObjects];
    [TypeArray removeAllObjects];
    [startDateArray removeAllObjects];
    [endDateArray removeAllObjects];
    [memberArray removeAllObjects];
    [IdArray removeAllObjects];
    [taskNameArray removeAllObjects];
    
}
-(void)calactivityNew
{
    activityIndicator =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray ];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    activityIndicator.hidesWhenStopped = NO;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

-(void)callmyActivities
{
    [self clearButtons];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:leftButton];
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.rightButton];
    if(backArray.count==0)
        [backArray addObject:@"fromActivity"];
    else
        [backArray removeAllObjects];
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/activities?page=1",kUrl]]];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               NSLog(@"%@",status);
                               if([httpResponse statusCode]==200)
                               {
                                   [activityIndicator stopAnimating];
                                   [activityIndicator removeFromSuperview];
                                   activityIndicator=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   [jsonObj getActivitie:status];
                                   [self clearArray];
                                   activities=[jsonObj.activiyArray mutableCopy];
                                   dates=[jsonObj.dateArray mutableCopy];
                                   hours=[jsonObj.hourSpentArray mutableCopy];
                                   __unsafe_unretained typeof(self) weakSelf = self;
                                   [self clearViews];
                                   activityListTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                    activityListTable.scrollEnabled = YES;
                                   activityListTable.showsVerticalScrollIndicator = NO;
                                   activityListTable.userInteractionEnabled = YES;
                                   activityListTable.bounces = YES;
                                   activityListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                   activityListTable.delegate = self;
                                   activityListTable.dataSource = self;
                                  // activityListTable.backgroundColor = [[UIColor alloc] initWithPatternImage:bgTableimg];
                                   [self.view addSubview:activityListTable];
                                   flag=1;
                                   pageCounter=1;
                                   [activityListTable triggerPullToRefresh];
                                   
                                   // setup pull-to-refresh
                                   [activityListTable addPullToRefreshWithActionHandler:^{
                                       [weakSelf insertRowAtTop];
                                   }];
                                   
                                   // setup infinite scrolling
                                   [activityListTable addInfiniteScrollingWithActionHandler:^{
                                       [weakSelf insertRowAtBottom];
                                   }];
                                   
                                   //[delegate setupGestures];
                               }
                           }];
}

- (void)insertRowAtBottom {
    pageCounter++;
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    NSMutableURLRequest *request;
    if(flag==1)
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/activities?page=%d",kUrl,pageCounter]]];
   else if(flag==2)
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/projects?page=%d",kUrl,pageCounter]]];
    else if(flag==3)
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/tasks?page=%d",kUrl,pageCounter]]];
    else if(flag==4)
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/projects/%d?page=%d",kUrl,index,pageCounter]]];
    else if(flag==5)
        request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/tasks/%d?page=%d",kUrl,index,pageCounter]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               // Its has finished but sort out the result (test for data and HTTP 200 i.e. not 404)
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSDictionary *myD = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];
                               jsonObj=[[JsonData alloc]init];
                               if ([httpResponse statusCode] == 200)
                               {
                                   if(flag==1)
                                   {
                                       [jsonObj getActivitie:myD];
                                       int increasedcount=jsonObj.activiyArray.count;
                                       int nextindex=activities.count;
                                       [activityListTable beginUpdates];
                                       for(int i=0;i<increasedcount;i++)
                                       {
                                           [dates insertObject:[jsonObj.dateArray objectAtIndex:i] atIndex:nextindex];
                                           [hours insertObject:[jsonObj.hourSpentArray objectAtIndex:i] atIndex:nextindex];
                                           int64_t delayInSeconds = 0.0;
                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                               
                                               [activities insertObject:[jsonObj.activiyArray objectAtIndex:i] atIndex:nextindex];
                                               [activityListTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextindex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                           } );
                                           nextindex++;
                                       }
                                       [activityListTable endUpdates];
                                       [activityListTable.infiniteScrollingView stopAnimating];

                                   }
                                   // [activityListTable reloadData];
                                   
                               else if(flag==2)
                               {
                                   [jsonObj getProject:myD];
                                   int increasedcount=jsonObj.nameArray.count;
                                   int nextindex=NameArray.count;
                                   [projectListTable beginUpdates];
                                   for(int i=0;i<increasedcount;i++)
                                   {
                                       [TypeArray insertObject:[jsonObj.typeArray objectAtIndex:i] atIndex:nextindex];
                                       [memberArray insertObject:[jsonObj.memberArray objectAtIndex:i] atIndex:nextindex];
                                       [IdArray insertObject:[jsonObj.idArray objectAtIndex:i] atIndex:nextindex];
                                       [startDateArray insertObject:[jsonObj.startDateArray objectAtIndex:i] atIndex:nextindex];
                                       [endDateArray insertObject:[jsonObj.endDateArray objectAtIndex:i] atIndex:nextindex];
                                       
                                       
                                       int64_t delayInSeconds = 0.0;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           
                                           [NameArray insertObject:[jsonObj.nameArray objectAtIndex:i] atIndex:nextindex];
                                           [projectListTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextindex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                       } );
                                       nextindex++;
                                   }
                                   [projectListTable endUpdates];
                                   [projectListTable.infiniteScrollingView stopAnimating];
                                   
                               }
                               else if(flag==3)
                               {
                                   [jsonObj getTask:myD];
                                   int increasedcount=jsonObj.nameArray.count;
                                   int nextindex=NameArray.count;
                                   [taskListTable beginUpdates];
                                   for(int i=0;i<increasedcount;i++)
                                   {
                                       [TypeArray insertObject:[jsonObj.typeArray objectAtIndex:i] atIndex:nextindex];
                                       [taskNameArray insertObject:[jsonObj.taskNameArray objectAtIndex:i] atIndex:nextindex];
                                       [memberArray insertObject:[jsonObj.memberArray objectAtIndex:i] atIndex:nextindex];
                                       [IdArray insertObject:[jsonObj.idArray objectAtIndex:i] atIndex:nextindex];
                                       [startDateArray insertObject:[jsonObj.startDateArray objectAtIndex:i] atIndex:nextindex];
                                       [endDateArray insertObject:[jsonObj.endDateArray objectAtIndex:i] atIndex:nextindex];
                                       
                                       
                                       int64_t delayInSeconds = 0.0;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           
                                           [NameArray insertObject:[jsonObj.nameArray objectAtIndex:i] atIndex:nextindex];
                                           [taskListTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextindex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                       } );
                                       nextindex++;
                                   }
                                   [taskListTable endUpdates];
                                   [taskListTable.infiniteScrollingView stopAnimating];

                               }
                               else if(flag==4)
                               {
                                   [jsonObj getProjectTask:myD];
                                   int increasedcount=jsonObj.taskNameArray.count;
                                   int nextindex=taskNameArray.count;
                                   [projectTaskTable beginUpdates];
                                   for(int i=0;i<increasedcount;i++)
                                   {
                                       [IdArray insertObject:[jsonObj.idArray objectAtIndex:i] atIndex:nextindex];
                                       [startDateArray insertObject:[jsonObj.startDateArray objectAtIndex:i] atIndex:nextindex];
                                       [endDateArray insertObject:[jsonObj.endDateArray objectAtIndex:i] atIndex:nextindex];
                                       
                                       
                                       int64_t delayInSeconds = 0.0;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           
                                           [taskNameArray insertObject:[jsonObj.taskNameArray objectAtIndex:i] atIndex:nextindex];
                                           [projectTaskTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextindex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                       } );
                                       nextindex++;
                                   }
                                   [projectTaskTable endUpdates];
                                   [projectTaskTable.infiniteScrollingView stopAnimating];

                               }
                               else if(flag==5)
                               {
                                   [jsonObj getTaskActivities:myD];
                                   int increasedcount=jsonObj.activiyArray.count;
                                   int nextindex=activities.count;
                                   [taskActivityTable beginUpdates];
                                   for(int i=0;i<increasedcount;i++)
                                   {
                                       
                                       int64_t delayInSeconds = 0.0;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           
                                           [activities insertObject:[jsonObj.activiyArray objectAtIndex:i] atIndex:nextindex];
                                           [taskActivityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextindex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                       } );
                                       nextindex++;
                                   }
                                   [taskActivityTable endUpdates];
                                   [taskActivityTable.infiniteScrollingView stopAnimating];
                                   
                               }
                            }
                               if(flag==1)
                               {
                                   [activityListTable endUpdates];
                                   [activityListTable.infiniteScrollingView stopAnimating];
                               }
                               else if(flag==2)
                               {
                                   [projectListTable endUpdates];
                                   [projectListTable.infiniteScrollingView stopAnimating];
                               }
                               else if(flag==3)
                               {
                                   [taskListTable endUpdates];
                                   [taskListTable.infiniteScrollingView stopAnimating];

                               }
                               else if(flag==4)
                               {
                                   [projectTaskTable endUpdates ];
                                   [projectTaskTable.infiniteScrollingView stopAnimating];
                               }
                               else if(flag==5)
                               {
                                   [taskActivityTable endUpdates ];
                                   [taskActivityTable.infiniteScrollingView stopAnimating];
                                   
                               }
                               
                           }];
    
}


- (void)insertRowAtTop {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(flag==1)
        {
            [activityListTable beginUpdates];
            
            [activityListTable endUpdates];
            
            [activityListTable.pullToRefreshView stopAnimating];

        }
        else if(flag==2)
        {
            [projectListTable beginUpdates];
            
            [projectListTable endUpdates];
            
            [projectListTable.pullToRefreshView stopAnimating];
 
        }
        else if(flag==3)
        {
            [taskListTable beginUpdates];
            
            [taskListTable endUpdates];
            
            [taskListTable.pullToRefreshView stopAnimating];

        }
        else if(flag==4)
        {
            [projectTaskTable beginUpdates];
            
            [projectTaskTable endUpdates];
            
            [projectTaskTable.pullToRefreshView stopAnimating];
        }
        else if(flag==5)
        {
            [taskActivityTable beginUpdates];
            
            [taskActivityTable endUpdates];
            
            [taskActivityTable.pullToRefreshView stopAnimating];
        }
            });
}

-(void)myProjectBack
{
    [delegate movePanelToOriginalPositionformyProject];
}
-(void)myTaskBack
{
    [delegate movePanelToOriginalPositionformyTask];
}
-(void)productbtnclicked:(UIButton *)sender
{
    [self.view endEditing:YES];

    UIButton *button = sender;
	switch (button.tag) {
		case 0: {
			[delegate movePanelToOriginalPosition];
            
			break;
		}
			
		case 1: {
			[delegate movePanelLeft];
            
			break;
		}
            
		default:
			break;
	}
    
}

-(void)backbtnclicked:(UIButton *)sender
{
    UIButton *button = sender;
	switch (button.tag) {
		case 0: {
			[delegate movePanelToOriginalPosition];
            //[self addTableInteraction];
            
			break;
		}
			
		case 1: {
        
            
        //    [self removeTableInteraction];
			[delegate movePanelRight];
            
			break;
		}
			
		default:
			break;
            
	}
    NSLog(@"btnTag%d",sender.tag);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==projectListTable)
        return [NameArray count];
    else if(tableView==activityListTable)
        return [activities count];
    else if(tableView==taskListTable)
        return [NameArray count];
    else if(tableView==memberTable)
        return [[memberArray objectAtIndex:index] count];
    else if(tableView==projectTaskTable)
        return taskNameArray.count;
    else if(tableView==taskActivityTable)
        return activities.count;
    else
        return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(tableView==projectListTable)
        return 105;
    else if(tableView==activityListTable)
        return 105;
    else if(tableView==taskListTable)
        return 105;
    else if(tableView==memberTable)
        return 75;
    else if(tableView==projectDetailsTable)
        return 600;
    else if(tableView==taskDetailsTable)
        return 600;
    else if(tableView==projectTaskTable)
        return 55;
    else if(tableView==taskActivityTable)
        return 35;
    else
        return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==projectListTable)
        [self projectDetails:[[IdArray objectAtIndex:indexPath.row] intValue]];
    else if(tableView==taskListTable)
        [self taskDetails:[[IdArray objectAtIndex:indexPath.row] intValue]];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //NSString *CellIdentifier = [NSString stringWithFormat:@"%d,%d",indexPath.section,indexPath.row];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if(tableView==activityListTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,100)];
            [cell addSubview:drawObj];
            
            UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 25, 170,50)];
            lbl.text=[activities objectAtIndex:indexPath.row];
            lbl.textColor=[UIColor colorWithRed:((float) 10.0f / 255.0f)
                                          green:((float) 113.0f/ 255.0f)
                                           blue:((float) 181.0f / 255.0f)
                                          alpha:1.0f];
            [lbl setFont:[UIFont fontWithName:@"Tahoma" size:15]];
            [cell addSubview:lbl];

            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(190, 4, 1,92)];
            lineView.backgroundColor = [UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                       green:((float) 220.0f/ 255.0f)
                                                        blue:((float) 220.0f / 255.0f)
                                                       alpha:1.0f];
            [cell addSubview:lineView];
            
            UILabel *dateLbl=[[UILabel alloc]initWithFrame:CGRectMake(195, 10, 100, 30)];
            dateLbl.text=[dates objectAtIndex:indexPath.row];
            dateLbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                          green:((float) 51.0f/ 255.0f)
                                           blue:((float) 51.0f / 255.0f)
                                          alpha:1.0f];
            [dateLbl setFont:[UIFont fontWithName:@"Tahoma" size:9]];
            
            [cell addSubview:dateLbl];
            
            NSLog(@"%@",[hours objectAtIndex:indexPath.row]);
            UILabel *timeLbl=[[UILabel alloc]initWithFrame:CGRectMake(195, 50, 100, 30)];
            timeLbl.text=[NSString stringWithFormat:@"%@",[hours objectAtIndex:indexPath.row]];
            timeLbl.textAlignment=NSTextAlignmentCenter;
            timeLbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                              green:((float) 51.0f/ 255.0f)
                                               blue:((float) 51.0f / 255.0f)
                                              alpha:1.0f];
            [timeLbl setFont:[UIFont fontWithName:@"Tahoma" size:9]];
            
            [cell addSubview:timeLbl];
           
        }
        else if(tableView==projectListTable)
            {
                drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,100)];
                [cell addSubview:drawObj];
                UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,300, 30)];
                name.text=[NameArray objectAtIndex:indexPath.row];
                name.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                  green:((float) 51.0f/ 255.0f)
                                                   blue:((float) 51.0f / 255.0f)
                                                  alpha:1.0f];
                name.font = [UIFont systemFontOfSize:18];
                [cell addSubview:name];
                UILabel *Type=[[UILabel alloc]initWithFrame:CGRectMake(10, 30, 300, 20)];
                Type.text=[TypeArray objectAtIndex:indexPath.row];
                Type.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                               green:((float) 51.0f/ 255.0f)
                                                blue:((float) 51.0f / 255.0f)
                                               alpha:1.0f];
                [Type setFont:[UIFont systemFontOfSize:12]];
                [cell addSubview:Type];
                UILabel *Date=[[UILabel alloc]initWithFrame:CGRectMake(10, 55, 300, 20)];
                NSString *startDate;
                NSString *endDate;
                
                if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                {
                    startDate=@"Start Date";
                }
                else
                {
                    startDate=[startDateArray objectAtIndex:indexPath.row];
                }
                if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                {
                    endDate=@"End Date";
                }
                else
                {
                    endDate=[endDateArray objectAtIndex:indexPath.row];
                }
                
                Date.text=[NSString stringWithFormat:@"%@ to %@",startDate,endDate];
                                Date.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                               green:((float) 51.0f/ 255.0f)
                                                blue:((float) 51.0f / 255.0f)
                                               alpha:1.0f];
                Date.font=[UIFont systemFontOfSize:12];
                [cell addSubview:Date];
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: Date.attributedText];
                [Date setAttributedText: text];
                if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                {
                    NSLog(@"%d",startDate.length);
                    [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(0,[startDate length])];
                    [Date setAttributedText: text];
                }
                if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                {
                    [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(startDate.length+3,endDate.length)];
                    [Date setAttributedText: text];
                }

                UIButton *btn;
                int btnx=5;
                for (int i=0; i<2; i++) {
                    btn=[[UIButton alloc]initWithFrame:CGRectMake(btnx+5, 75, 70, 25)];
                    if(i==0)
                    {
                        [btn setTitle:@"Members" forState:UIControlStateNormal];
                        btn.tag=indexPath.row;
                    }
                    else if(i==1)
                    {
                        [btn setTitle:@"Tasks" forState:UIControlStateNormal];
                        btn.tag=[[IdArray objectAtIndex:indexPath.row] integerValue];
                    }
                    btnx+=80;
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.titleLabel.font=[UIFont systemFontOfSize:9];
                    [btn addTarget:self action:@selector(taskormemClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:btn];
                    
                }
                
            }
        else if(tableView==taskListTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,100)];
            [cell addSubview:drawObj];
            UILabel *taskName=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,200, 30)];
            taskName.text=[taskNameArray objectAtIndex:indexPath.row];
            taskName.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            taskName.font = [UIFont systemFontOfSize:15];
            [cell addSubview:taskName];
            
            UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(10,30,200, 20)];
            name.text=[NameArray objectAtIndex:indexPath.row];
            name.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            name.font = [UIFont systemFontOfSize:12];
            [cell addSubview:name];
            UILabel *Date=[[UILabel alloc]initWithFrame:CGRectMake(10, 55, 300, 20)];
            NSString *startDate;
            NSString *endDate;
            
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                startDate=@"Start Date";
            }
            else
            {
                startDate=[startDateArray objectAtIndex:indexPath.row];
            }
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                endDate=@"End Date";
            }
            else
            {
                endDate=[endDateArray objectAtIndex:indexPath.row];
            }
            
            Date.text=[NSString stringWithFormat:@"%@ to %@",startDate,endDate];
            Date.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            Date.font=[UIFont systemFontOfSize:12];
            [cell addSubview:Date];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: Date.attributedText];
            [Date setAttributedText: text];
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
               // NSLog(@"%d",startDate.length);
                [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(0,[startDate length])];
                [Date setAttributedText: text];
            }
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(startDate.length+3,endDate.length)];
                [Date setAttributedText: text];
            }
            UIButton *btn;
            int btnx=5;
            for (int i=0; i<2; i++) {
                btn=[[UIButton alloc]initWithFrame:CGRectMake(btnx+5, 75, 70, 25)];
                btn.tag=[[IdArray objectAtIndex:indexPath.row] integerValue];
                if(i==0)
                {
                    [btn setTitle:@"Activites" forState:UIControlStateNormal];
                    btn.tag=[[IdArray objectAtIndex:indexPath.row] integerValue] ;
                }
                else if(i==1)
                {
                    [btn setTitle:@"Members" forState:UIControlStateNormal];
                    btn.tag=indexPath.row;
                }
                btnx+=80;
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //   btn.backgroundColor=[UIColor redColor];
                btn.titleLabel.font=[UIFont systemFontOfSize:9];
                [btn addTarget:self action:@selector(memoracivityClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
                
            }

            
        }
        else if(tableView==memberTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,70)];
            [cell addSubview:drawObj];
            
            UILabel *Name=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,200, 30)];
            Name.text=[jsonObj.nameArray objectAtIndex:indexPath.row];
            Name.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                               green:((float) 51.0f/ 255.0f)
                                                blue:((float) 51.0f / 255.0f)
                                               alpha:1.0f];
            Name.font = [UIFont systemFontOfSize:15];
            [cell addSubview:Name];
            
            UILabel *Email=[[UILabel alloc]initWithFrame:CGRectMake(10,30,200, 20)];
            Email.text=[jsonObj.emailArray objectAtIndex:indexPath.row];
            Email.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            Email.font = [UIFont systemFontOfSize:12];
            [cell addSubview:Email];
   
        }
        else if(tableView==projectDetailsTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,600)];
            [cell addSubview:drawObj];
            
            UILabel *Name=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,200, 30)];
            Name.text=jsonObj.projectName;
            Name.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            Name.font = [UIFont systemFontOfSize:18];
            [cell addSubview:Name];
            
            UILabel *Type=[[UILabel alloc]initWithFrame:CGRectMake(10, 30,200, 20)];
            Type.text=jsonObj.projectType;
            Type.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            Type.font = [UIFont systemFontOfSize:12];
            [cell addSubview:Type];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10,50 , 280,1)];
            lineView.backgroundColor = [UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                       green:((float) 220.0f/ 255.0f)
                                                        blue:((float) 220.0f / 255.0f)
                                                       alpha:1.0f];
            [cell addSubview:lineView];
            
            int lbly=50;
            UILabel *namelbl;
            for(int j=0;j<4;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++) {
                    namelbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            namelbl.text=@"Team Lead : ";
                        else
                            namelbl.text=jsonObj.projectTeamLead;

                    }
                    else if(j==1)
                    {
                        if(i==0)
                            namelbl.text=@"Implementation Owner : ";
                        else
                            namelbl.text=jsonObj.projectImplOwner;

                    }
                    else if(j==2)
                    {
                        if(i==0)
                            namelbl.text=@"Status : ";
                        else
                            namelbl.text=jsonObj.projectStatus;
                        
                    }
                    else if(j==3)
                    {
                        if(i==0)
                            namelbl.text=@"Scheduled Status : ";
                        else
                            namelbl.text=jsonObj.projectSchedStatus;
                        
                    }
                    
                    namelbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                      green:((float) 51.0f/ 255.0f)
                                                       blue:((float) 51.0f / 255.0f)
                                                      alpha:1.0f];
                    namelbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:namelbl];
                    lblx+=150;
                    
                }
                lbly+=20;
                
            }
            
            UILabel *descTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 130,200, 20)];
            descTitle.text=@"Status Description :";
            descTitle.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            descTitle.font = [UIFont systemFontOfSize:12];
            [cell addSubview:descTitle];
            
            UITextView * desc = [[UITextView alloc] initWithFrame:CGRectMake(10, 150,280, 40)];
            [desc setText:jsonObj.projectStatusDesc];
            desc.layer.borderWidth=1.0f;
            desc.layer.cornerRadius=5.0f;
            desc.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                   green:((float) 220.0f/ 255.0f)
                                                    blue:((float) 220.0f / 255.0f)
                                                   alpha:1.0f]CGColor];

            desc.editable=NO;
            desc.font=[UIFont systemFontOfSize:12];
            desc.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                 green:((float) 51.0f/ 255.0f)
                                                  blue:((float) 51.0f / 255.0f)
                                                 alpha:1.0f];
            [cell addSubview:desc];

            lbly=190;
            UILabel *lbl;
            for(int j=0;j<6;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++) {
                    lbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            lbl.text=@"Stage : ";
                        else
                            lbl.text=jsonObj.projectStage;
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            lbl.text=@"Percentage Completed : ";
                        else
                            lbl.text=[NSString stringWithFormat:@"%@",jsonObj.projectCompleted];
                        
                    }
                    else if(j==2)
                    {
                        if(i==0)
                            lbl.text=@"Planned Start Date : ";
                        else
                            if([jsonObj.projectPlanSDate isEqual:[NSNull null]])
                            {
                               lbl.text=@"Start date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectPlanSDate;
                            }
                        
                    }
                    else if(j==3)
                    {
                        if(i==0)
                            lbl.text=@"Planned End Date : ";
                        else
                            if([jsonObj.projectPlanEDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"End date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectPlanEDate;
                            }
                        
                    }
                    else if(j==4)
                    {
                        if(i==0)
                            lbl.text=@"Actual Start Date : ";
                        else
                            if([jsonObj.projectActualSDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"Start date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectActualSDate;
                            }
                        
                    }
                    else if(j==5)
                    {
                        if(i==0)
                            lbl.text=@"Actual End Date : ";
                        else
                            if([jsonObj.projectActualEDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"End date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectActualEDate;
                            }
                        
                    }
                    
                    lbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                      green:((float) 51.0f/ 255.0f)
                                                       blue:((float) 51.0f / 255.0f)
                                                      alpha:1.0f];
                    lbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:lbl];
                    lblx+=150;
                    
                }
                lbly+=20;
                
            }
            lineView = [[UIView alloc] initWithFrame:CGRectMake(10,lbly, 280,1)];
            lineView.backgroundColor = [UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                       green:((float) 220.0f/ 255.0f)
                                                        blue:((float) 220.0f / 255.0f)
                                                       alpha:1.0f];
            [cell addSubview:lineView];
            lbly+=1;
            UILabel *Hourlbl;
            for(int j=0;j<3;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++)
                {
                    Hourlbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            Hourlbl.text=@"Total Hours : ";
                        else
                            if([jsonObj.projectTotalHour isEqual:[NSNull null]])
                            {
                                Hourlbl.text=@"Total Hour";
                            }
                            else
                            {
                                Hourlbl.text=[NSString stringWithFormat:@"%@",jsonObj.projectTotalHour];
                            }
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            Hourlbl.text=@"Actual Hours Till Date : ";
                        else
                            if([jsonObj.projectActualHour isEqual:[NSNull null]])
                            {
                                Hourlbl.text=@"Hours till date";
                            }
                            else
                            {
                                Hourlbl.text=[NSString stringWithFormat:@"%@",jsonObj.projectActualHour ];
                            }
                        
                    }
                    else if(j==2)
                    {
                        if(i==0)
                            Hourlbl.text=@"Remaining Hours : ";
                        else
                            if([jsonObj.projectRemainHour isEqual:[NSNull null]])
                            {
                                Hourlbl.text=@"Remaining";
                            }
                            else
                            {
                                Hourlbl.text=[NSString stringWithFormat:@"%@",jsonObj.projectRemainHour];
                            }
                        
                    }
                    Hourlbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                  green:((float) 51.0f/ 255.0f)
                                                   blue:((float) 51.0f / 255.0f)
                                                  alpha:1.0f];
                    Hourlbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:Hourlbl];
                    lblx+=150;
                    
                }
                lbly+=20;
            }
            lineView = [[UIView alloc] initWithFrame:CGRectMake(10,lbly, 280,1)];
            lineView.backgroundColor = [UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                       green:((float) 220.0f/ 255.0f)
                                                        blue:((float) 220.0f / 255.0f)
                                                       alpha:1.0f];
            [cell addSubview:lineView];
            lbly++;
            UILabel *Clientlbl;
            for(int j=0;j<2;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++)
                {
                    Clientlbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            Clientlbl.text=@"Client Name : ";
                        else
                            if([jsonObj.projectClientName isEqual:[NSNull null]])
                            {
                                Clientlbl.text=@"Client Name";
                            }
                            else
                            {
                                Clientlbl.text=jsonObj.projectClientName;
                            }
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            Clientlbl.text=@"Client Contact : ";
                        else
                            if([jsonObj.projectClientContact isEqual:[NSNull null]])
                            {
                                Clientlbl.text=@"Contact";
                            }
                            else
                            {
                                Clientlbl.text=jsonObj.projectClientContact;
                            }
                    }
                    Clientlbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                        green:((float) 51.0f/ 255.0f)
                                                         blue:((float) 51.0f / 255.0f)
                                                        alpha:1.0f];
                    Clientlbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:Clientlbl];
                    
                    lblx+=150;
                }
                lbly+=20;
            }
        }
        else if(tableView==taskDetailsTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,600)];
            [cell addSubview:drawObj];
            int lbly=10;
            UILabel *namelbl;
            for(int j=0;j<2;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++)
                {
                    namelbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            namelbl.text=@"Type : ";
                        else
                            namelbl.text=@"Type";
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            namelbl.text=@"Project : ";
                        else
                            namelbl.text=jsonObj.projectName;
                        
                    }
                    namelbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                      green:((float) 51.0f/ 255.0f)
                                                       blue:((float) 51.0f / 255.0f)
                                                      alpha:1.0f];
                    namelbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:namelbl];
                    
                    lblx+=150;
                }
                lbly+=20;
            }
            UILabel *descTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, lbly,200, 20)];
            descTitle.text=@"Task Description :";
            descTitle.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                green:((float) 51.0f/ 255.0f)
                                                 blue:((float) 51.0f / 255.0f)
                                                alpha:1.0f];
            descTitle.font = [UIFont systemFontOfSize:12];
            [cell addSubview:descTitle];
            lbly+=20;
            UITextView * desc = [[UITextView alloc] initWithFrame:CGRectMake(10, lbly,280, 40)];
            [desc setText:jsonObj.taskDesc];
            desc.layer.borderWidth=1.0f;
            desc.layer.cornerRadius=5.0f;
            desc.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                    green:((float) 220.0f/ 255.0f)
                                                     blue:((float) 220.0f / 255.0f)
                                                    alpha:1.0f]CGColor];
            
            desc.editable=NO;
            desc.font=[UIFont systemFontOfSize:12];
            desc.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            [cell addSubview:desc];
            lbly+=40;
            
            UILabel *AssignTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, lbly,200, 20)];
            AssignTitle.text=@"Assigned To :";
            AssignTitle.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                  green:((float) 51.0f/ 255.0f)
                                                   blue:((float) 51.0f / 255.0f)
                                                  alpha:1.0f];
            AssignTitle.font = [UIFont systemFontOfSize:12];
            [cell addSubview:AssignTitle];
            lbly+=20;
            UITextView * assign = [[UITextView alloc] initWithFrame:CGRectMake(10, lbly,280, 50)];
            [assign setText:jsonObj.Users];
            assign.layer.borderWidth=1.0f;
            assign.layer.cornerRadius=5.0f;
            assign.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                      green:((float) 220.0f/ 255.0f)
                                                       blue:((float) 220.0f / 255.0f)
                                                      alpha:1.0f]CGColor];
            
            assign.editable=NO;
            assign.font=[UIFont systemFontOfSize:12];
            assign.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                             green:((float) 51.0f/ 255.0f)
                                              blue:((float) 51.0f / 255.0f)
                                             alpha:1.0f];
            [cell addSubview:assign];
            lbly+=50;
            UILabel *lbl;
            for(int j=0;j<4;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++) {
                    lbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            lbl.text=@"Planned Start Date : ";
                        else
                            if([jsonObj.projectPlanSDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"Start date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectPlanSDate;
                            }
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            lbl.text=@"Planned End Date : ";
                        else
                            if([jsonObj.projectPlanEDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"End date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectPlanEDate;
                            }
                        
                    }
                    else if(j==2)
                    {
                        if(i==0)
                            lbl.text=@"Actual Start Date : ";
                        else
                            if([jsonObj.projectActualSDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"Start date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectActualSDate;
                            }
                        
                    }
                    else if(j==3)
                    {
                        if(i==0)
                            lbl.text=@"Actual End Date : ";
                        else
                            if([jsonObj.projectActualEDate isEqual:[NSNull null]])
                            {
                                lbl.text=@"End date";
                            }
                            else
                            {
                                lbl.text=jsonObj.projectActualEDate;
                            }
                        
                    }
                    
                    lbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                  green:((float) 51.0f/ 255.0f)
                                                   blue:((float) 51.0f / 255.0f)
                                                  alpha:1.0f];
                    lbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:lbl];
                    lblx+=150;
                    
                }
                lbly+=20;
                
            }
            UILabel *tasklbl;
            for(int j=0;j<4;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++) {
                    tasklbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            tasklbl.text=@"Planned Effort : ";
                        else
                            if([jsonObj.taskPlanEffort isEqual:[NSNull null]])
                            {
                                tasklbl.text=@"Effort";
                            }
                            else
                            {
                                tasklbl.text=jsonObj.taskPlanEffort;
                            }
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            tasklbl.text=@"Planned Cost : ";
                        else
                            if([jsonObj.taskCost isEqual:[NSNull null]])
                            {
                                tasklbl.text=@"Cost";
                            }
                            else
                            {
                                tasklbl.text=jsonObj.taskCost;
                            }
                        
                    }
                    else if(j==2)
                    {
                        if(i==0)
                            tasklbl.text=@"Priority : ";
                        else
                            if([jsonObj.taskPriority isEqual:[NSNull null]])
                            {
                                tasklbl.text=@"Priority";
                            }
                            else
                            {
                                tasklbl.text=[NSString stringWithFormat:@"%@",jsonObj.taskPriority];
                            }
                        
                    }
                    else if(j==3)
                    {
                        if(i==0)
                            tasklbl.text=@"Status : ";
                        else
                            if([jsonObj.projectStatus isEqual:[NSNull null]])
                            {
                                tasklbl.text=@"Status";
                            }
                            else
                            {
                                tasklbl.text=jsonObj.projectStatus;
                            }
                        
                    }
                    
                    tasklbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                      green:((float) 51.0f/ 255.0f)
                                                       blue:((float) 51.0f / 255.0f)
                                                      alpha:1.0f];
                    tasklbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:tasklbl];
                    lblx+=150;
                    
                }
                lbly+=20;
                
            }
            UILabel *progresslbl;
            for(int j=0;j<2;j++)
            {
                int lblx=10;
                for (int i=0; i<2; i++) {
                    progresslbl=[[UILabel alloc]initWithFrame:CGRectMake(lblx, lbly,150, 20)];
                    if(j==0)
                    {
                        if(i==0)
                            progresslbl.text=@"Progress : ";
                        else
                            if([jsonObj.projectCompleted isEqual:[NSNull null]])
                            {
                                progresslbl.text=@"Progress";
                            }
                            else
                            {
                                progresslbl.text=[NSString stringWithFormat:@"%@",jsonObj.projectCompleted];
                            }
                        
                    }
                    else if(j==1)
                    {
                        if(i==0)
                            progresslbl.text=@"WBS Code : ";
                        else
                            if([jsonObj.WBScode isEqual:[NSNull null]])
                            {
                                progresslbl.text=@"WBS Code";
                            }
                            else
                            {
                                progresslbl.text=jsonObj.WBScode;
                            }
                        
                    }
                    progresslbl.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                          green:((float) 51.0f/ 255.0f)
                                                           blue:((float) 51.0f / 255.0f)
                                                          alpha:1.0f];
                    progresslbl.font = [UIFont systemFontOfSize:12];
                    [cell addSubview:progresslbl];
                    lblx+=150;

                }
                lbly+=20;
            }
            UILabel *ActivitiesTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, lbly,200, 20)];
            ActivitiesTitle.text=@"Recent Activities :";
            ActivitiesTitle.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                                green:((float) 51.0f/ 255.0f)
                                                 blue:((float) 51.0f / 255.0f)
                                                alpha:1.0f];
            ActivitiesTitle.font = [UIFont systemFontOfSize:12];
            [cell addSubview:ActivitiesTitle];
            lbly+=20;
            UITextView * activitie = [[UITextView alloc] initWithFrame:CGRectMake(10, lbly,280, 60)];
            [activitie setText:jsonObj.recentActivities];
            activitie.layer.borderWidth=1.0f;
            activitie.layer.cornerRadius=5.0f;
            activitie.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                    green:((float) 220.0f/ 255.0f)
                                                     blue:((float) 220.0f / 255.0f)
                                                    alpha:1.0f]CGColor];
            
            activitie.editable=NO;
            activitie.font=[UIFont systemFontOfSize:12];
            activitie.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            [cell addSubview:activitie];
            
        }
        else if(tableView==projectTaskTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,50)];
            [cell addSubview:drawObj];
            UILabel *taskName=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,280, 30)];
            taskName.text=[taskNameArray objectAtIndex:indexPath.row];
            taskName.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                               green:((float) 51.0f/ 255.0f)
                                                blue:((float) 51.0f / 255.0f)
                                               alpha:1.0f];
            taskName.font = [UIFont systemFontOfSize:15];
            [cell addSubview:taskName];
            UILabel *Date=[[UILabel alloc]initWithFrame:CGRectMake(10, 30, 300, 20)];
            NSString *startDate;
            NSString *endDate;
            
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                startDate=@"Start Date";
            }
            else
            {
                startDate=[startDateArray objectAtIndex:indexPath.row];
            }
            if([[endDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                endDate=@"End Date";
            }
            else
            {
                endDate=[endDateArray objectAtIndex:indexPath.row];
            }
            
            Date.text=[NSString stringWithFormat:@"%@ to %@",startDate,endDate];
            Date.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                           green:((float) 51.0f/ 255.0f)
                                            blue:((float) 51.0f / 255.0f)
                                           alpha:1.0f];
            Date.font=[UIFont systemFontOfSize:12];
            [cell addSubview:Date];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: Date.attributedText];
            [Date setAttributedText: text];
            if([[startDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                NSLog(@"%d",startDate.length);
                [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(0,[startDate length])];
                [Date setAttributedText: text];
            }
            if([[endDateArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            {
                [text addAttribute: NSFontAttributeName  value:[UIFont italicSystemFontOfSize:12] range:NSMakeRange(startDate.length+3,endDate.length)];
                [Date setAttributedText: text];
            }
            
        }
        else if(tableView==taskActivityTable)
        {
            drawObj=[[DrawClass alloc]initWithFrame:CGRectMake(0, 0, 300,30)];
            [cell addSubview:drawObj];
            UILabel *taskName=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,280, 30)];
            taskName.text=[activities objectAtIndex:indexPath.row];
            taskName.textColor=[UIColor colorWithRed:((float) 51.0f / 255.0f)
                                               green:((float) 51.0f/ 255.0f)
                                                blue:((float) 51.0f / 255.0f)
                                               alpha:1.0f];
            taskName.font = [UIFont systemFontOfSize:13];
            [cell addSubview:taskName];
        }
        
    }
    return cell;
}
-(void)clearButtons
{
    [leftButton removeFromSuperview];
    leftButton=nil;
    [self.rightButton removeFromSuperview];
    self.rightButton=nil;
    [back removeFromSuperview];
    back=nil;
}
-(void)clearViews
{
    [activityListTable removeFromSuperview];
    activityListTable=nil;
    [projectListTable removeFromSuperview];
    projectListTable=nil;
    [taskListTable removeFromSuperview];
    taskListTable=nil;
    [memberView removeFromSuperview];
    memberView=nil;
    [memberTable removeFromSuperview];
    memberTable=nil;
    [projectDetailsView removeFromSuperview];
    projectDetailsView=Nil;
    [projectDetailsTable removeFromSuperview];
    projectDetailsTable=nil;
    [taskDetailsView removeFromSuperview];
    taskDetailsView=Nil;
    [taskDetailsTable removeFromSuperview];
    taskDetailsTable=Nil;
    [projectTaskView removeFromSuperview];
    projectTaskView=nil;
    [projectTaskTable removeFromSuperview];
    projectTaskTable=nil;
    [taskActivityView removeFromSuperview];
    taskActivityView=nil;
    [taskActivityTable removeFromSuperview];
    taskActivityTable=nil;
}
-(void)backClicked
{
    if(fromProject)
    {
        fromProject=NO;
        [backArray removeLastObject];
      //  [backArray removeLastObject];
        [self myProjectCall];
    }
    else if(fromTask)
    {
        fromTask=NO;
        [backArray removeLastObject];
      //  [backArray removeLastObject];
        [self myTaskCall];
    }
    else
    {
        if([[backArray objectAtIndex:(backArray.count -2)]isEqualToString:@"fromActivity"])
        {
            [backArray removeLastObject];
            [backArray removeLastObject];
            [self callmyActivities];
        }
        else if([[backArray objectAtIndex:(backArray.count -2)]isEqualToString:@"fromProject"])
        {
            [backArray removeLastObject];
            [backArray removeLastObject];
            [self myProjectCall];
        }
        else
        {
            [backArray removeLastObject];
            [backArray removeLastObject];
            [self myTaskCall];
        }
    }
}
-(void)myProjectCall
{
    [self clearButtons];
    [backArray addObject:@"fromProject"];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:leftButton];
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(45, 11, 25, 30)];
    back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:back];
    [back setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.rightButton];
    
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/projects?page=1",kUrl]]];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               NSLog(@"%@",status);
                               if([httpResponse statusCode]==200)
                               {
                                   jsonObj=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   [jsonObj getProject:status];
                                   [self clearViews];
                                   [self clearArray];
                                   __unsafe_unretained typeof(self) weakSelf = self;
                                   projectListTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                   projectListTable.scrollEnabled = YES;
                                   projectListTable.showsVerticalScrollIndicator = NO;
                                   projectListTable.userInteractionEnabled = YES;
                                   projectListTable.bounces = YES;
                                   projectListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                   projectListTable.delegate = self;
                                   projectListTable.dataSource = self;
                                  
                                   [self.view addSubview:projectListTable];
                                   flag=2;
                                   pageCounter=1;
                                   [projectListTable triggerPullToRefresh];
                                   
                                   // setup pull-to-refresh
                                   [projectListTable addPullToRefreshWithActionHandler:^{
                                       [weakSelf insertRowAtTop];
                                   }];
                                   
                                   // setup infinite scrolling
                                   [projectListTable addInfiniteScrollingWithActionHandler:^{
                                       [weakSelf insertRowAtBottom];
                                   }];

                                   fromList=NO;
                                   
                                   NameArray=[jsonObj.nameArray mutableCopy];
                                   TypeArray=[jsonObj.typeArray mutableCopy];
                                   memberArray=[jsonObj.memberArray mutableCopy];
                                   startDateArray=[jsonObj.startDateArray mutableCopy];
                                   endDateArray=[jsonObj.startDateArray mutableCopy];
                                   IdArray=[jsonObj.idArray mutableCopy];
                               }
                           }];
}
-(void)projectDetails:(int)idtag
{
    [self clearButtons];
    [self clearViews];
    [backArray addObject:@"fromProject"];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(45, 11, 25, 30)];
    back.backgroundColor=[UIColor clearColor];
    fromProject=YES;
    [back addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    if(fromList)
    {
         projectTaskView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [projectTaskView addSubview:leftButton];
        [projectTaskView addSubview:back];
        [projectTaskView addSubview:self.rightButton];
    }
    else
    {
        projectDetailsView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [projectDetailsView addSubview:leftButton];
        [projectDetailsView addSubview:back];
        [projectDetailsView addSubview:self.rightButton];
    }
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    index=idtag;
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/projects/%d?page=1",kUrl,idtag]]];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([httpResponse statusCode]==200)
                               {
                                   jsonObj=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   if(fromList)
                                   {
                                       [jsonObj getProjectTask:status];
                                       [self clearArray];
                                       taskNameArray=[jsonObj.taskNameArray mutableCopy];
                                       startDateArray=[jsonObj.startDateArray mutableCopy];
                                       endDateArray=[jsonObj.startDateArray mutableCopy];
                                       IdArray=[jsonObj.idArray mutableCopy];

                                       __unsafe_unretained typeof(self) weakSelf = self;
                                       projectTaskTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                       projectTaskTable.scrollEnabled = YES;
                                       projectTaskTable.showsVerticalScrollIndicator = NO;
                                       projectTaskTable.userInteractionEnabled = YES;
                                       projectTaskTable.bounces = YES;
                                       projectTaskTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                       projectTaskTable.delegate = self;
                                       projectTaskTable.dataSource = self;
                                       
                                       [projectTaskView addSubview:projectTaskTable];
                                       [self.view addSubview:projectTaskView];
                                       
                                       
                                       
                                       flag=4;
                                       pageCounter=1;
                                       [projectTaskTable triggerPullToRefresh];
                                       
                                       // setup pull-to-refresh
                                       [projectTaskTable addPullToRefreshWithActionHandler:^{
                                           [weakSelf insertRowAtTop];
                                       }];
                                       [projectTaskTable addInfiniteScrollingWithActionHandler:^{
                                           [weakSelf insertRowAtBottom];
                                       }];

                                   }
                                   else
                                   {
                                       [jsonObj getProjectDetails:status];
                                       [self clearArray];
                                       
                                       projectDetailsTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                       projectDetailsTable.scrollEnabled = YES;
                                       projectDetailsTable.showsVerticalScrollIndicator = NO;
                                       projectDetailsTable.userInteractionEnabled = YES;
                                       projectDetailsTable.bounces = YES;
                                       projectDetailsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                       projectDetailsTable.delegate = self;
                                       projectDetailsTable.dataSource = self;
                                       
                                       [projectDetailsView addSubview:projectDetailsTable];
                                       [self.view addSubview:projectDetailsView];
                                       
                                   }
                                   
                                   
                               }
                           }];
     
}
-(void)taskormemClicked:(UIButton *)btn
{
        if([btn.titleLabel.text isEqualToString:@"Members"])
        {
            index=btn.tag;
            fromProject=YES;
            [self membersClicked];
        }
        else
        {
            fromList=YES;
            [self projectDetails:btn.tag];
        }
}
-(void)membersClicked
{
    [self clearButtons];
    [self clearViews];
   // [backArray addObject:@"fromProject"];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(45, 11, 25, 30)];
    back.backgroundColor=[UIColor clearColor];
//fromProject=YES;
    [back addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    

    jsonObj=nil;
    jsonObj=[[JsonData alloc]init];
    [jsonObj getMember:[memberArray objectAtIndex:index]];
    memberView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [memberView addSubview:leftButton];
    [memberView addSubview:back];
    [memberView addSubview:self.rightButton];
    memberTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
    memberTable.scrollEnabled = YES;
    memberTable.showsVerticalScrollIndicator = NO;
    memberTable.userInteractionEnabled = YES;
    memberTable.bounces = YES;
    memberTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    memberTable.delegate = self;
    memberTable.dataSource = self;
    [memberView addSubview:memberTable];
    [self.view addSubview:memberView];

}
-(void)taskDetails:(int)Idtag
{
    [self clearButtons];
    [self clearViews];
    [backArray addObject:@"fromProject"];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(45, 11, 25, 30)];
    back.backgroundColor=[UIColor clearColor];
    fromTask=YES;
    [back addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    if(fromList)
    {
        taskActivityView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [taskActivityView addSubview:leftButton];
        [taskActivityView addSubview:back];
        [taskActivityView addSubview:self.rightButton];
    }
    else
    {
        taskDetailsView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [taskDetailsView addSubview:leftButton];
        [taskDetailsView addSubview:back];
        [taskDetailsView addSubview:self.rightButton];
    }
    
    
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    index=Idtag;
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/tasks/%d?page=1",kUrl,Idtag]]];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([httpResponse statusCode]==200)
                               {
                                   jsonObj=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   [self clearArray];
                                   if(fromList)
                                   {
                                       [jsonObj getTaskActivities:status];
                                       activities=[jsonObj.activiyArray mutableCopy];
                                       __unsafe_unretained typeof(self) weakSelf = self;
                                       
                                       taskActivityTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                       taskActivityTable.scrollEnabled = YES;
                                       taskActivityTable.showsVerticalScrollIndicator = NO;
                                       taskActivityTable.userInteractionEnabled = YES;
                                       taskActivityTable.bounces = YES;
                                       taskActivityTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                       taskActivityTable.delegate = self;
                                       taskActivityTable.dataSource = self;
                                       
                                       [taskActivityView addSubview:taskActivityTable];
                                       [self.view addSubview:taskActivityView];
                                       flag=5;
                                       pageCounter=1;
                                       [taskActivityTable triggerPullToRefresh];
                                       
                                       // setup pull-to-refresh
                                       [taskActivityTable addPullToRefreshWithActionHandler:^{
                                           [weakSelf insertRowAtTop];
                                       }];
                                       [taskActivityTable addInfiniteScrollingWithActionHandler:^{
                                           [weakSelf insertRowAtBottom];
                                       }];
                                   }
                                   else
                                   {
                                       [jsonObj getTaskDetails:status];
                                       taskDetailsTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                       taskDetailsTable.scrollEnabled = YES;
                                       taskDetailsTable.showsVerticalScrollIndicator = NO;
                                       taskDetailsTable.userInteractionEnabled = YES;
                                       taskDetailsTable.bounces = YES;
                                       taskDetailsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                       taskDetailsTable.delegate = self;
                                       taskDetailsTable.dataSource = self;
                                       
                                       [taskDetailsView addSubview:taskDetailsTable];
                                       [self.view addSubview:taskDetailsView];
  
                                   }
                                   
                               }
                           }];

}
-(void)myTaskCall
{
    [self clearButtons];
    [backArray addObject:@"fromTask"];
    leftButton=[[UIButton alloc]initWithFrame:CGRectMake(5, 11, 30, 30)];
    leftButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:leftButton];
    leftButton.tag=1;
    [leftButton addTarget:self action:@selector(backbtnclicked:) forControlEvents:UIControlEventTouchDown];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(45, 11, 25, 30)];
    back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:back];
    [back setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 0, 50, 44)];
    self.rightButton.backgroundColor=[UIColor clearColor];
    self.rightButton.userInteractionEnabled=YES;
    self.rightButton.tag=1;
    [self.rightButton addTarget:self action:@selector(productbtnclicked:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.rightButton];

    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/tasks?page=1",kUrl]]];
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               
                               if([httpResponse statusCode]==200)
                               {
                                   jsonObj=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   [jsonObj getTask:status];
                                   [self clearArray];
                                   NameArray=[jsonObj.nameArray mutableCopy];
                                   taskNameArray=[jsonObj.taskNameArray mutableCopy];
                                   startDateArray=[jsonObj.startDateArray mutableCopy];
                                   endDateArray=[jsonObj.startDateArray mutableCopy];
                                   memberArray=[jsonObj.memberArray mutableCopy];
                                   IdArray=[jsonObj.idArray mutableCopy];
                                   [self clearViews];
                                   __unsafe_unretained typeof(self) weakSelf = self;
                                   taskListTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, self.view.frame.size.height-50) style:UITableViewStylePlain];
                                   taskListTable.scrollEnabled = YES;
                                   taskListTable.showsVerticalScrollIndicator = NO;
                                   taskListTable.userInteractionEnabled = YES;
                                   taskListTable.bounces = YES;
                                   taskListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                                   taskListTable.delegate = self;
                                   taskListTable.dataSource = self;
                                   [self.view addSubview:taskListTable];
                                   flag=3;
                                   pageCounter=1;
                                   [taskListTable triggerPullToRefresh];
                                   
                                   // setup pull-to-refresh
                                   [taskListTable addPullToRefreshWithActionHandler:^{
                                       [weakSelf insertRowAtTop];
                                   }];
                                   
                                   // setup infinite scrolling
                                   [taskListTable addInfiniteScrollingWithActionHandler:^{
                                       [weakSelf insertRowAtBottom];
                                   }];

                                   
                               }
                           }];
}


-(void)memoracivityClicked:(UIButton *)btn
{
    if([btn.titleLabel.text isEqualToString:@"Members"])
    {
        index=btn.tag;
        fromTask=YES;
        [self membersClicked];
    }
    else
    {
        fromList=YES;
        [self taskDetails:btn.tag];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
