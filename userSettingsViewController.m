//
//  userSettingsViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "userSettingsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface userSettingsViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *canReceiveNotifications;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *profileSurname;

@end

@implementation userSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation[@"canReceiveNotification"]) {
        _canReceiveNotifications.selected = YES;
    }else
    {
        _canReceiveNotifications.selected = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _profilePicture.layer.cornerRadius = 72.f;
    _profilePicture.layer.masksToBounds = YES;
    
    _profileName.text = [[PFUser currentUser]objectForKey:@"name"];
    _profileSurname.text = [[PFUser currentUser]objectForKey:@"surname"];
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *facebookId = [result objectForKey:@"id"];
             
             NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];

             [self.profilePicture setImageWithURL:profilePictureURL
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
             
         }
         else
         {
             NSLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
         }
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleNotifications:(id)sender {
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (_canReceiveNotifications.selected) {
        [installation setObject:[NSNumber numberWithBool:NO] forKey:@"canReceiveNotification"];
        [installation saveInBackground];
    }
    else
    {
        [installation setObject:[NSNumber numberWithBool:YES] forKey:@"canReceiveNotification"];
        [installation saveInBackground];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
