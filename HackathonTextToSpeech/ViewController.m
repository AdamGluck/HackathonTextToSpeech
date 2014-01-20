//
//  ATTViewController.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "TTSEasyAPI.h"
#import "ViewController.h"

@interface ViewController () <TTSEasyAPIDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) TTSEasyAPI * easyAccess;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.easyAccess = [[TTSEasyAPI alloc] initWithDelegate:self];
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

-(TTSEasyAPI *)easyAccess
{
    if (!_easyAccess){
        _easyAccess = [[TTSEasyAPI alloc] initWithDelegate:self];
    }
    return _easyAccess;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
