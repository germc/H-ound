//
//  ViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLoginButton {
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //NSLog(@"%@", [user description]);
        if (!user) {
            if (!error) {
                NSLog(@"[Facebook utils] The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"[Facebook utils] An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
        else if (user.isNew)
        {
            NSLog(@"user Signed up and logged through facebook");
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSString *name = [result objectForKey:@"first_name"];
                    NSString *surname = [result objectForKey:@"last_name"];
                    NSString *email = [result objectForKey:@"email"];
                    NSString *link = [result objectForKey:@"link"];

                    user[@"name"] = name;
                    user[@"surname"] = surname;
                    user.email = email;
                    [user saveInBackground];
                    
                    NSLog(@"Signin: %@ %@ %@ %@", name, surname, email, link);
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    currentInstallation[@"user"] = user;
                    [currentInstallation setObject:[NSNumber numberWithBool:YES] forKey:@"canReceiveNotification"];
                    [currentInstallation addUniqueObject:user[@"username"] forKey:@"channels"];
                    [currentInstallation saveInBackground];
                    
                    [self performSegueWithIdentifier:@"loginComplete" sender:self];
                }
            }];
        }
        else
        {
            NSLog(@"[Login View Controller] Welcome back %@", user[@"name"]);
            // GOTO personal (Skip walkthrough)
            [self performSegueWithIdentifier:@"loginComplete" sender:self];
            
        }
    }];
}

@end
