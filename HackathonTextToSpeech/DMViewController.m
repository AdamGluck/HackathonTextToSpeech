//
//  DMViewController.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "DMTextToSpeechEasyAPI.h"

@interface DMViewController () <DMTextToSpeechEasyAPIDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) DMTextToSpeechEasyAPI * easyAccess;
@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)readTextField:(id)sender
{
    [self.easyAccess readText:self.textField.text];
}
- (IBAction)listen:(id)sender
{
    [self.easyAccess listen];
}
-(void)speechWasRecognizedWithText:(NSString *)text
{
    self.textField.text = text;
}

-(void)speechAuthenticationSucceeded
{
    NSLog(@"speech prep succeeded");
}

-(void)speechAuthenticationFailed
{
    NSLog(@"speech prep failed");
}

-(DMTextToSpeechEasyAPI *)easyAccess
{
    if (!_easyAccess){
        _easyAccess = [[DMTextToSpeechEasyAPI alloc] initWithDelegate: self];
    }
    return _easyAccess;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
