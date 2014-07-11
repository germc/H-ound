//
//  AppDelegate.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "AppDelegate.h"
#define HFARMBEACONREGION @"CEAA3E59-796E-4C0F-BE03-CC7FD2F2F532"
@import CoreLocation;

@interface AppDelegate() <CLLocationManagerDelegate>

//Regioni da monitorare
@property (nonatomic, strong) NSMutableArray *allRegionsToMonitor;
@property (nonatomic, strong) CLBeaconRegion *hfarmBeaconRegion;
@property (nonatomic, strong) CLBeaconRegion *receptionBR;
@property (nonatomic, strong) CLBeaconRegion *hcampBR;
@property (nonatomic, strong) CLBeaconRegion *serraBR;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSUUID *hfarmUUID;

@property (nonatomic, strong) NSDictionary *zonesDictionary;

@property int enteredTimes;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //VARS
    _enteredTimes = 0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"parseData" ofType:@"plist"];
    NSMutableDictionary *parseData = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
    //Parse Initialization
    [Parse setApplicationId:[parseData objectForKey:@"applicationId"]
                  clientKey:[parseData objectForKey:@"clientKey"]];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];

    //LOCATION MANAGER PARTS
    _hfarmUUID = [[NSUUID alloc]initWithUUIDString:HFARMBEACONREGION];
    _locationManager.delegate = self;

    //Dictionary to switch
    _zonesDictionary = @{@"com.hfarm.hfarmBeaconRegion": @0,
                                      @"com.hfarm.reception": @1,
                                      @"com.hfarm.hcamp": @2,
                                      @"com.hfarm.serra": @3};
    
    // Generico ID di monitoring
    _hfarmBeaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:_hfarmUUID identifier:@"com.hfarm.hfarmBeaconRegion"];

    //Specific zones to identify
    _receptionBR = [[CLBeaconRegion alloc]initWithProximityUUID:_hfarmUUID major:1 identifier:@"com.hfarm.reception"];
    _hcampBR = [[CLBeaconRegion alloc]initWithProximityUUID:_hfarmUUID major:2 identifier:@"com.hfarm.hcamp"];
    _serraBR = [[CLBeaconRegion alloc]initWithProximityUUID:_hfarmUUID major:3 identifier:@"com.hfarm.serra"];
    
    //Add to array
    [_allRegionsToMonitor addObject:_hfarmBeaconRegion];
    [_allRegionsToMonitor addObject:_receptionBR];
    [_allRegionsToMonitor addObject:_hcampBR];
    [_allRegionsToMonitor addObject:_serraBR];

    if ([PFUser currentUser]) {
        //Up to 20 locations to search
        int i = 0;
        for (i=0; i < [_allRegionsToMonitor count]; i++) {
            [_locationManager startMonitoringForRegion:_allRegionsToMonitor[i]];
        }
    }
    else{
        //Register First!
    }
    
    //DONE!
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - LocationMangager delegate methods
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //Send notification to parse of exit
    //Tell parse that i'm entered the region => user has a major number
    if (_enteredTimes == 0) {
        //Show local notification
        _enteredTimes++;
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        NSInteger switcher = (NSInteger)[_zonesDictionary objectForKey:[region identifier]];
        
        switch (switcher) {
            case 0:
                //I'm in zone 0
                notification.alertBody = NSLocalizedString(@"Benvenuto in H-Farm", @"2nd?");
                break;
            case 1:
                //I'm in zone 1
                notification.alertBody = NSLocalizedString(@"Benvenuto in Reception!", @"2nd?");
                break;
            case 2:
                //I'm in zone 2
                notification.alertBody = NSLocalizedString(@"Benvenuto in HCamp!", @"2nd?");
                break;
            case 3:
                //I'm in zone 3
                notification.alertBody = NSLocalizedString(@"Benvenuto in Serra!", @"2nd?");
                break;
            default:
                // I'm entered but i don't know where I am
                notification.alertBody = NSLocalizedString(@"Benvenuto in H-Farm", @"2nd?");
                break;
        }
        
        //Mostra la notifica
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    

}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //Send notification to parse of exit
    //Delete major number from user
    
    UILocalNotification *goodbyeNotification = [[UILocalNotification alloc]init];
    goodbyeNotification.alertBody = NSLocalizedString(@"Arrivederci e grazie della visita", @"");
    goodbyeNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:goodbyeNotification];
}


#pragma mark - Notifications delegates methods
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //Local Notification income
    NSLog(@"[AppDelegate] Local notification received");
    
}


/*
 - (void)application:(UIApplication *)application
 didReceiveRemoteNotification:(NSDictionary *)userInfo
 fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
 // Create empty photo object
 NSString *photoId = [userInfo objectForKey:@"p"];
 PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:@"Photo"
 objectId:photoId];
 
 // Fetch photo object
 [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
 // Show photo view controller
 if (error) {
 handler(UIBackgroundFetchResultFailed);
 } else if ([PFUser currentUser]) {
 PhotoVC *viewController = [[PhotoVC alloc] initWithPhoto:object];
 [self.navController pushViewController:viewController animated:YES];
 handler(UIBackgroundFetchResultNewData);
 } else {
 handler(UIBackgroundModeNoData);
 }
 }];
 }
 */

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    NSString *username = [userInfo objectForKey:@"name"];

    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:username message:@"WEI" delegate:self cancelButtonTitle:@"WEI" otherButtonTitles:nil, nil];
    [alert show];*/
    //Fetch new data for presenting to the interface
    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
}

@end
