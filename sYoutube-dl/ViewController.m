/*
 MIT License
 
 Copyright (c) 2017 John Sklikas
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
//
//  ViewController.m
//  sYoutube-dl
//
//  Created by Yannis on 03/12/2016.
//  Copyright © 2016 isklikas. All rights reserved.
//

#import "ViewController.h"
#import "sYoutube_dl-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];
    /*
     */
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    NSError *error;
    NSArray *passwordItems = [KeychainPasswordItem passwordItemsForService:@"sYoutube-dl" accessGroup:nil error:&error];
    if (passwordItems.count == 0 || [[NSUserDefaults standardUserDefaults] stringForKey:@"serverAddress"] == nil || [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStorageLocation"] == nil) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        KeychainController * vc = (KeychainController *)[sb instantiateViewControllerWithIdentifier:@"KeychainController"];
        [self.navigationController pushViewController:vc animated:FALSE];
    }
}

- (IBAction)downloadVideo:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor blackColor];
    spinner.frame = CGRectMake(60, 80, 40, 40);
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        NSError *error;
        NSArray *passwordItems = [KeychainPasswordItem passwordItemsForService:@"sYoutube-dl" accessGroup:nil error:&error];
        NSString *serverAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverAddress"];
        NSString *response = @"Error";
        if (passwordItems.count > 0 && serverAddress != nil) {
            KeychainPasswordItem *item = passwordItems[0];
            NSString *server = [serverAddress stringByAppendingString:@":22"];
            NMSSHSession *session = [NMSSHSession connectToHost:server
                                                   withUsername:item.account];
            
            if (session.isConnected) {
                [session authenticateByPassword:[item readPasswordAndReturnError:nil]];
                
                if (session.isAuthorized) {
                    NSLog(@"Authentication succeeded");
                }
            }
            
            NSError *error = nil;
            const NSString *constCommand = @"youtube-dl --extract-audio --audio-format mp3 -o '";//
            NSString *defaultLocation = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultStorageLocation"];
            NSString *cmdString = [constCommand stringByAppendingString:defaultLocation];
            NSString *filetypeFormat = @"%(title)s.%(ext)s'";
            NSString *command = [cmdString stringByAppendingString:filetypeFormat];
            command = [command stringByAppendingString:[NSString stringWithFormat:@" %@", _linkField.text]];
            response = [session.channel execute:command error:&error];
            [session disconnect];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [spinner stopAnimating];
            [_serverLog setText: response];
            //Run UI Updates
        });
    });
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
