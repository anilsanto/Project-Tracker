//
//  ViewController.m
//  Project Tracker
//
//  Created by Nuevalgo on 24/02/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "ViewController.h"
#define kUrl @"http://offers2win.com/project-tracker/"
@interface ViewController ()

@end

@implementation ViewController
@synthesize str;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self basicInitialisation];
   
	// Do any additional setup after loading the view.
    UIImageView *Icon=[[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width,self.view.frame.size.height)];
    Icon.image=[UIImage imageNamed:@"loginbck"];
    [self.view addSubview:Icon];
    for(int i=0;i<2;i++)
    {
        UITextField *sighintxt=[[UITextField alloc]initWithFrame:CGRectMake(48, txY, 252, txtheight)];
        sighintxt.backgroundColor=[UIColor clearColor];
        sighintxt.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        sighintxt.placeholder=[placeHolder objectAtIndex:i];
        if(i==1)
        {
            sighintxt.secureTextEntry = YES;
        }
        [self.view addSubview:sighintxt];
        [TextStringArray addObject:sighintxt];
        txY+=txtheight+4;
        
    }
    
    
    signinbutton=[[UIButton alloc]initWithFrame:CGRectMake(15, regY, 288, 40)];
    signinbutton.backgroundColor=[UIColor colorWithRed:((float) 10.0f / 255.0f)
                                                 green:((float) 113.0f/ 255.0f)
                                                  blue:((float) 181.0f / 255.0f)
                                                 alpha:1.0f];
    signinbutton.layer.cornerRadius=4.0f;
    //[signinbutton setBackgroundImage:[UIImage imageNamed:@"signin.png"] forState:UIControlStateNormal];
    
    [signinbutton setTitle:@"Login" forState:UIControlStateNormal];
    [signinbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signinbutton addTarget:self action:@selector(signinclicked) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:signinbutton];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES ];
}
-(void)basicInitialisation
{
    
    placeHolder=[[NSMutableArray alloc]initWithObjects:@"User Email",@"Password", nil];
    TextStringArray=[[NSMutableArray alloc]init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        // iPad-specific code
        
    }
    else
    {
        // iPhone-specific code
        
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            txY=156;
            txtheight=37;
            regY=275;
            socialY=470;
            socialheight=38;
            forgotY=350;
            // [loginhome setImage:[UIImage imageNamed:@"loginbck5s.png"]];
            
        }
        else
        {
            txY=145;
            txtheight=36;
            regY=250;
            socialY=410;
            socialheight=38;
            forgotY=315;
            // [loginhome setImage:[UIImage imageNamed:@"loginbck.png"]];
            
        }
        //Ceating other buttos
    }
    
    
}
-(void)signinclicked
{
    UITextField *txt=[TextStringArray objectAtIndex:0];
    email=txt.text;
    txt=[TextStringArray objectAtIndex:1];
    password=txt.text;
    [self loginCall];
    
}
-(void)loginCall
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(160, 240);
    activityIndicator.hidesWhenStopped = NO;
    self.view.alpha=0.3f;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/users/sign_in?user[email]=%@&user[password]=%@",kUrl,email,password]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *status=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([httpResponse statusCode]==200)
                               {
                                   [activityIndicator stopAnimating];
                                   [activityIndicator removeFromSuperview];
                                 //  activityIndicator=nil;
                                   NSString *token=status[@"token"];
                                   NSString *returnEmail=status[@"email"];
                                   NSString *name=status[@"name"];
                                   NSUserDefaults *userData=[NSUserDefaults standardUserDefaults];
                                   [userData setObject:token forKey:@"tokenKey"];
                                   [userData setObject:returnEmail forKey:@"Email"];
                                   [userData setObject:name forKey:@"Name"];
                                   [self performSegueWithIdentifier:@"logintolist" sender:self  ];
                               }
                               
                           }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
