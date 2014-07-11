//
//  contactsTableViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "contactsTableViewController.h"
#import "contactCellTableViewCell.h"

@interface contactsTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation contactsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    PFQuery *searchAllContactsOfHfarm = [PFUser query];
    searchAllContactsOfHfarm.cachePolicy = kPFCachePolicyNetworkElseCache;
//    [searchAllContactsOfHfarm whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [searchAllContactsOfHfarm findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //NSLog(@"%@", [objects[0] description]);
            _contacts = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"Description: %@, Failure: %@", [error localizedDescription], [error localizedFailureReason]);
        }

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    contactCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    

    if (cell == nil) {
        cell = [[contactCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier];
    }
    
    //Set the content of every cell
    cell.contactName.text = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.contactImage.layer.cornerRadius = 25.f;
    cell.contactImage.layer.masksToBounds = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Ha toccato una row @indexpath
    //Send notification to parse servers
    NSString *nameOfTouchedUser = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    //NSString *usernameOfTouchedUser = [[_contacts objectAtIndex:indexPath.row]objectForKey:@"username"];
    
//    NSLog(@"Touched user %@", nameOfTouchedUser);
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:[_contacts objectAtIndex:indexPath.row]];
    [pushQuery whereKey:@"canReceiveNotification" equalTo:[NSNumber numberWithBool:YES]];
    
    PFPush *sendPush = [[PFPush alloc]init];
    [sendPush setQuery:pushQuery];
//    [sendPush setMessage:@"iOS Push notification"];
    [sendPush setMessage:[[PFUser currentUser]objectForKey:@"surname"]];
//    [sendPush setData:@{@"name": [[PFUser currentUser]objectForKey:@"surname"]}];
    
//    [sendPush setChannel:usernameOfTouchedUser];

    //NSLog(@"Username: %@", usernameOfTouchedUser);
    [sendPush sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Push notification sent to: %@", nameOfTouchedUser);
        }
    }];
    //Ogni user è un canale differente di push notification
    //Iscrivo gli utenti l'un l'altro
    
    /*
     PFQuery *pushQuery = [PFInstallation query];
     [pushQuery whereKey:@"injuryReports" equalTo:YES];
     
     // Send push notification to query
     PFPush *push = [[PFPush alloc] init];
     [push setQuery:pushQuery]; // Set our Installation query
     [push setMessage:@"Willie Hayes injured by own pop fly."];
     [push sendPushInBackground];
     */
    
}

- (IBAction)requestInfoForUser:(id)sender {

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
