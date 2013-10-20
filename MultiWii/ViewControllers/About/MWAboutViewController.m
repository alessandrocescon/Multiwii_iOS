//
//  MWAboutViewController.m
//  MultiWii
//
//  Created by Eugene Skrebnev on 7/10/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import "MWAboutViewController.h"

@interface MWAboutViewController ()

@end

@implementation MWAboutViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.viewControllerTitle = @" ABOUT ";
}

-(NSArray*) titlesForMenu
{
    return @[@"ABOUT PROGRAM", @"HOW TO CONNECT", @"ASK QUESTION", @"SUBMIT BUG", @"ABOUT AUTHOR"];
}

-(NSArray*) iconsForMenu
{
    return @[@"about_program", @"how_to_connect", @"ask", @"bug", @"about_author"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 ||indexPath.row == 3)
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        NSString* subject = indexPath.row == 2 ? @"Got some question" : @"!!!BUG!!!";
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:subject];
        [mailViewController setToRecipients:@[@"multiwii.for.ios@gmail.com"]];
        [mailViewController setMessageBody:@"" isHTML:NO];
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;

        [self presentModalViewController:mailViewController animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    if (result == MFMailComposeResultSaved)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    if (result == MFMailComposeResultSent)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    if (result == MFMailComposeResultFailed)
    {
        [UIAlertView alertResultWithTitle:@"Failed" message:@"Something wrong, check your internet connection" buttonNames:@[@"Return to mail", @"Cancel"] block:^(UIAlertView *alert, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                
            }
            else
            {
                [self dismissModalViewControllerAnimated:YES];
            }
        }];
    }
    

}

@end
