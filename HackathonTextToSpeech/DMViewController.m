//
//  DMViewController.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "DMTextToSpeechEasyAPI.h"

@interface DMViewController () 
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) DMTextToSpeechEasyAPI * easyAccess;
@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.easyAccess = [[DMTextToSpeechEasyAPI alloc] init];
}

- (IBAction)readTextField:(id)sender
{
    [self.easyAccess readText:self.textField.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
