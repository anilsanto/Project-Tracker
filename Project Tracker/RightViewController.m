//
//  RightViewController.m
//  Project Tracker
//
//  Created by Nuevalgo on 03/03/14.
//  Copyright (c) 2014 Nuevalgo. All rights reserved.
//

#import "RightViewController.h"
#define kUrl @"http://offers2win.com/project-tracker/"

@interface RightViewController ()

@end
@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
@implementation RightViewController

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
  
    bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height )];
    bgView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:bgView];

    [self calProjectTask];
    
    
}
-(void)calProjectTask
{
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
                               NSDictionary *myD=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               
                               if([httpResponse statusCode]==200)
                               {
                                   jsonObj=nil;
                                   jsonObj=[[JsonData alloc]init];
                                   [jsonObj getOpenTask:myD];
                                   [self createActivity];
                                   
                               }
                           }];

}
-(void)createActivity
{
    UILabel *titlelbl=[[UILabel alloc]initWithFrame:CGRectMake(70, 20, 240, 55)];
    titlelbl.text=@"New Activity";
    titlelbl.font=[UIFont systemFontOfSize:18];
    titlelbl.textAlignment=NSTextAlignmentCenter;
    titlelbl.textColor=[UIColor whiteColor];
    [bgView addSubview:titlelbl];
    
    UILabel *tasklbl=[[UILabel alloc]initWithFrame:CGRectMake(70, 75, 200, 30)];
    tasklbl.text=@"Task";
    tasklbl.font=[UIFont systemFontOfSize:13];
    tasklbl.textColor=[UIColor whiteColor];
    [bgView addSubview:tasklbl];

    dropDownBtn=[[UIButton alloc]initWithFrame:CGRectMake(65, 105, 200, 30)];
    dropDownBtn.backgroundColor=[UIColor whiteColor];
    dropDownBtn.layer.borderWidth=1.0f;
    dropDownBtn.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                green:((float) 220.0f/ 255.0f)
                                                 blue:((float) 220.0f / 255.0f)
                                                alpha:1.0f]CGColor];    dropDownBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    [dropDownBtn setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [dropDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dropDownBtn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:dropDownBtn];
    
    dropDownView = [[DropDownView alloc] initWithArrayData:jsonObj.taskArray cellHeight:30 heightTableView:200 paddingTop:-8 paddingLeft:-5 paddingRight:-10 refView:dropDownBtn animation:GROW openAnimationDuration:0.5 closeAnimationDuration:0.5];
	
	dropDownView.delegate = self;
	
	[self.view addSubview:dropDownView.view];
	
	[dropDownBtn setTitle:[jsonObj.taskArray objectAtIndex:0] forState:UIControlStateNormal];
    
    UILabel *activitylbl=[[UILabel alloc]initWithFrame:CGRectMake(70, 135, 200, 30)];
    activitylbl.text=@"Activity";
    activitylbl.font=[UIFont systemFontOfSize:13];
    activitylbl.textColor=[UIColor whiteColor];
    [bgView addSubview:activitylbl];
    
    activity=[[UITextField alloc]initWithFrame:CGRectMake(65, 165, 200, 30)];
    activity.layer.borderWidth=1.0f;
    activity.layer.cornerRadius=5.0f;
    activity.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                            green:((float) 220.0f/ 255.0f)
                                             blue:((float) 220.0f / 255.0f)
                                            alpha:1.0f]CGColor];
    activity.font=[UIFont systemFontOfSize:12];
    activity.textColor=[UIColor blackColor];
    activity.backgroundColor=[UIColor whiteColor];
    [bgView addSubview:activity];
    
    UILabel *Datelbl=[[UILabel alloc]initWithFrame:CGRectMake(70, 195, 100, 30)];
    
    Datelbl.text=@"Date";
    Datelbl.font=[UIFont systemFontOfSize:13];
    Datelbl.textColor=[UIColor whiteColor];
    [bgView addSubview:Datelbl];
    
    date=[[UITextField alloc]initWithFrame:CGRectMake(65, 225, 100, 30)];
    date.layer.borderWidth=1.0f;
    date.layer.cornerRadius=5.0f;
    date.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                                green:((float) 220.0f/ 255.0f)
                                                 blue:((float) 220.0f / 255.0f)
                                                alpha:1.0f]CGColor];
    date.font=[UIFont systemFontOfSize:12];
    date.textColor=[UIColor blackColor];
    date.backgroundColor=[UIColor whiteColor];
    [bgView addSubview:date];
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode=UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateTextField) forControlEvents:UIControlEventValueChanged];
    [date setInputView:datePicker];
    
    UILabel *hourlbl=[[UILabel alloc]initWithFrame:CGRectMake(200, 195, 100, 30)];
    
    hourlbl.text=@"Hours spent";
    hourlbl.font=[UIFont systemFontOfSize:13];
    hourlbl.textColor=[UIColor whiteColor];
    [bgView addSubview:hourlbl];
    
    hour=[[UITextField alloc]initWithFrame:CGRectMake(195, 225, 100, 30)];
    hour.layer.borderWidth=1.0f;
    hour.layer.cornerRadius=5.0f;
    hour.layer.borderColor=[[UIColor colorWithRed:((float) 220.0f / 255.0f)
                                            green:((float) 220.0f/ 255.0f)
                                             blue:((float) 220.0f / 255.0f)
                                            alpha:1.0f]CGColor];
    hour.font=[UIFont systemFontOfSize:12];
    hour.textColor=[UIColor blackColor];
    hour.backgroundColor=[UIColor whiteColor];
    [bgView addSubview:hour];
    
    UIButton *createActivity=[[UIButton alloc]initWithFrame:CGRectMake(120, 285, 150, 30)];
    createActivity.backgroundColor=[UIColor grayColor];
    [createActivity setTitle:@"Create Activity" forState:UIControlStateNormal];
    createActivity.layer.cornerRadius=4.0f;
    createActivity.layer.borderWidth=1.0f;
    
    [createActivity addTarget:self action:@selector(calCreateActivity) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:createActivity];
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = createActivity.layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.7f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.5f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.3f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.6f],
                            [NSNumber numberWithFloat:0.7f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [createActivity.layer addSublayer:shineLayer];
    
   
}
-(void)updateTextField
{
    UIDatePicker *picker = (UIDatePicker*)date.inputView;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int year   =    [[calendar components:NSYearCalendarUnit    fromDate:[picker date ]] year];
    int month  =    [[calendar components:NSMonthCalendarUnit   fromDate:[picker date]] month];
    int day    =    [[calendar components:NSDayCalendarUnit     fromDate:[picker date]] day];
    
    NSString *dateString = [NSString stringWithFormat:@"%d/%d/%d",year, month, day];
    date.text=[NSString stringWithFormat:@"%@",dateString];
    
}
-(void)calCreateActivity
{
    NSUserDefaults *List=[NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/activities",kUrl]]];
    NSLog(@"%@",[activity.text urlencode]);
    NSString *TokenString=[List objectForKey:@"tokenKey"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:TokenString forHTTPHeaderField:@"AUTH-TOKEN"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"activity[activity]\" \r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",[activity.text urlencode]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"activity[start_date]\" \r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",date.text] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"activity[total_hours_spent]\" \r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",[hour text]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"activity[task_id]\" \r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",[jsonObj.idArray objectAtIndex:index]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString *returns  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSDictionary *myD=[NSJSONSerialization JSONObjectWithData:[returns dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               
                               if([httpResponse statusCode]==200)
                               {
                               }
                           }];
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
	[dropDownBtn setTitle:[jsonObj.taskArray objectAtIndex:returnIndex] forState:UIControlStateNormal];
	
    index=returnIndex;
}
-(void)action
{
    [dropDownView openAnimation];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   
    for (id textField in bgView.subviews) {
        
        if ([textField isKindOfClass:[UITextField class]] && [textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
