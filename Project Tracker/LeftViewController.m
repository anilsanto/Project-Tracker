//
//  LeftViewController.m
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "LeftViewController.h"
#define kUrl @"http://offers2win.com/project-tracker/"

@interface LeftViewController ()

@end

@implementation LeftViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor=[UIColor blackColor];
    UIView *topView=[[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width-100, 80)];
    NSUserDefaults *userProfile=[NSUserDefaults standardUserDefaults];
    int Usery=0;
    for (int i=0; i<2; i++) {
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(0, Usery, 150, 50)];
        if(i==0)
            lbl.text=[userProfile objectForKey:@"Name"];
        else
            lbl.text=[userProfile objectForKey:@"Email"];
        lbl.textColor=[UIColor whiteColor];
        [topView addSubview:lbl];
        Usery+=30;
    }
    
    [self.view addSubview:topView];
    listTable= [[UITableView alloc]initWithFrame:CGRectMake(0,100, self.view.frame.size.width,self.view.frame.size.height-100) style:UITableViewStylePlain];
    listTable.scrollEnabled = YES;
    listTable.showsVerticalScrollIndicator = NO;
    listTable.userInteractionEnabled = YES;
    listTable.bounces = YES;
    listTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    listTable.delegate = self;
    listTable.dataSource = self;
    listTable.backgroundColor = [UIColor colorWithRed:((float) 16.0f / 255.0f)
                                                       green:((float) 21.0f/ 255.0f)
                                                        blue:((float) 25.0f / 255.0f)
                                                       alpha:1.0f];
    [self.view addSubview:listTable];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return self.view.frame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // static NSString *CellIdentifier = @"newFriendCell";
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d,%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor colorWithRed:((float) 16.0f / 255.0f)
                                             green:((float) 21.0f/ 255.0f)
                                              blue:((float) 25.0f / 255.0f)
                                             alpha:1.0f];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if(tableView==listTable)
        {   int profileY=5;
            for (int i=0; i<=3; i++)
            {
                UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(10,  profileY, 250, 45)];
                if(i==0)
                    [btn setBackgroundImage:[UIImage imageNamed:@"menuhome"] forState:UIControlStateNormal];
                else if(i==1)
                    [btn setBackgroundImage:[UIImage imageNamed:@"MyProject"] forState:UIControlStateNormal];
                else if(i==2)
                    [btn setBackgroundImage:[UIImage imageNamed:@"MyTask"] forState:UIControlStateNormal];
                else if(i==3)
                    [btn setBackgroundImage:[UIImage imageNamed:@"menulogout"] forState:UIControlStateNormal];
                btn.tag=i;
                [btn addTarget:self action:@selector(profilebtn:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
                profileY+=50;
            }
            
        }
    }
    return cell;
}
-(void)profilebtn:(UIButton *)btn
{
    if(btn.tag==1)
    {
        [delegate myProjectBack];
    }
    else if(btn.tag==2)
    {
        [delegate myTaskBack];
    }

    else if(btn.tag==3)
    {
        [self logout];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)logout
{
    NSUserDefaults *logout=[NSUserDefaults standardUserDefaults];
    
    NSURL * url=[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/users/sign_out",kUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *TokenString=[logout objectForKey:@"tokenKey"];
    
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    
    
    connectionsignout=[[NSURLConnection alloc] initWithRequest:request delegate:self];
       
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];


}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    int errorCode = httpResponse.statusCode;
    NSString *fileMIMEType = [[httpResponse MIMEType] lowercaseString];
    if(connection==connectionsignout)
        
        NSLog(@"response is %d, %@", errorCode, fileMIMEType);
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Message!"
                                                      message:@"Successfully SignedOut"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    message.delegate=self;
    [message show];
    
    
    
    
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.message isEqualToString:@"Successfully SignedOut"])
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * initialVC = [storyboard instantiateViewControllerWithIdentifier:@"logIn"];
        [self presentViewController:initialVC animated:YES completion:nil];
        
    }
}

@end
