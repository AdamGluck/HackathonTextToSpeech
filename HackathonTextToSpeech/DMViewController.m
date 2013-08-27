//
//  DMViewController.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "DMTextToSpeechEasyAPI.h"


@interface DMViewController () <ATTSpeechServiceDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (retain,nonatomic) NSString* oauthToken;
@property (retain,nonatomic) NSString* ttsInProgress;
@property (retain,nonatomic) AVAudioPlayer* audioPlayer;
@property (strong, nonatomic) DMTextToSpeechEasyAPI * easyAccess;
@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.easyAccess = [[DMTextToSpeechEasyAPI alloc] init];
}

/*
- (void) prepareSpeech
{
    // Set up this application for audio output.
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error != nil) {
        NSLog(@"Not able to initialize audio session for playback: %@", error);
    }
    
    // Access the SpeechKit singleton.
    ATTSpeechService* speechService = [ATTSpeechService sharedSpeechService];
    
    // Point to the SpeechToText API.
    speechService.recognitionURL = SpeechServiceUrl();
    
    // Hook ourselves up as a delegate so we can get called back with the response.
    speechService.delegate = self;
    
    // Use default speech UI.
    speechService.showUI = YES;
    
    // Choose the speech recognition package.
    speechService.speechContext = @"QuestionAndAnswer";
    
    // Start the OAuth background operation, disabling the Talk button until
    // it's done.
    [self validateOAuthForService: speechService];
    
    // Wake the audio components so there is minimal delay on the first request.
    [speechService prepare];
}

- (void) startTTS: (NSString*) textToSpeak
{
    TTSRequest* tts = [TTSRequest forService: TTSUrl() withOAuth: self.oauthToken];
    self.ttsInProgress = textToSpeak;
    [tts postText: textToSpeak forClient: ^(NSData* audioData, NSError* error) {
        if (![textToSpeak isEqualToString: self.ttsInProgress]) {
            // TTS was canceled, so don't play it back.
        }
        else if (audioData != nil) {
            NSLog(@"Text to Speech returned %d bytes of audio.", audioData.length);
            [self playAudioData: audioData];
        }
        else {
            NSLog(@"Unable to convert text to speech: %@", error);
            // Real applications probably shouldn't display an alert.

        }
    }];
}

- (void) playAudioData: (NSData*) audioData
{
    //[self stopPlaying];
    NSError* error = nil;
    // Set up this application for audio output.
    // We have to do this after microphone input, because otherwise the OS
    // will route audio to the phone receiver, not the speaker.
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error != nil) {
        NSLog(@"Not able to set audio session for playback: %@", error);
    }
    AVAudioPlayer* newPlayer = [[AVAudioPlayer alloc] initWithData: audioData error: &error];
    if (newPlayer == nil) {
        NSLog(@"Unable to play TTS audio data: %@", error);
        // Real applications probably shouldn't display an alert.
    }
    [newPlayer play];
    self.audioPlayer = newPlayer;
}
*/

- (IBAction)readTextField:(id)sender
{
    [self.easyAccess readText:self.textField.text];
}

/*
- (void) validateOAuthForService: (ATTSpeechService*) speechService
{
    [[SpeechAuth authenticatorForService: SpeechOAuthUrl()
                                  withId: SpeechOAuthKey()
                                  secret: SpeechOAuthSecret()
                                   scope: SpeechOAuthScope()]
     fetchTo: ^(NSString* token, NSError* error) {
         if (token) {
             self.oauthToken = token;
             speechService.bearerAuthToken = token;
#warning commented out code, implement later
             //[self readyForSpeech];
         }
         else {
             self.oauthToken = nil;
             //[self speechAuthFailed: error];
         }
     }];
}


#pragma mark Speech Service Delegate Methods

- (void) speechServiceSucceeded: (ATTSpeechService*) speechService
{
    NSLog(@"Speech service succeeded");
    
    // Extract the needed data from the SpeechService object:
    // For raw bytes, read speechService.responseData.
    // For a JSON tree, read speechService.responseDictionary.
    // For the n-best ASR strings, use speechService.responseStrings.
    
    // In this example, use the ASR strings.
    // There can be 0 strings, 1 empty string, or 1 non-empty string.
    // Display the recognized text in the interface is it's non-empty,
    // otherwise have the user try again.
    NSArray* nbest = speechService.responseStrings;
    NSString* recognizedText = @"";
    if (nbest != nil && nbest.count > 0)
        recognizedText = [nbest objectAtIndex: 0];
    if (recognizedText.length) { // non-empty?
        //[self handleRecognition: recognizedText];
    }
    else {

    }
}

- (void) speechService: (ATTSpeechService*) speechService
       failedWithError: (NSError*) error
{
    if ([error.domain isEqualToString: ATTSpeechServiceErrorDomain]
        && (error.code == ATTSpeechServiceErrorCodeCanceledByUser)) {
        NSLog(@"Speech service canceled");
        // Nothing to do in this case
        return;
    }
    NSLog(@"Speech service had an error: %@", error);
}

*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
