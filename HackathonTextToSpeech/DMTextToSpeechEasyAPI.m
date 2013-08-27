//
//  DMTextToSpeechEasyAPI.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "DMTextToSpeechEasyAPI.h"
@interface DMTextToSpeechEasyAPI()<ATTSpeechServiceDelegate>
@property (strong,nonatomic) NSString* oauthToken;
@property (strong,nonatomic) NSString* ttsInProgress;
@property (retain,nonatomic) AVAudioPlayer* audioPlayer;
@property (strong, nonatomic) NSURL * speechServiceURL;
@property (strong, nonatomic) NSURL * TTSUrl;
@property (strong, nonatomic) NSURL * oauthURL;
@property (strong, nonatomic) NSString * oauthKey;
@property (strong, nonatomic) NSString * oauthSecret;
@property (strong, nonatomic) NSString * oauthScope;
@end

@implementation DMTextToSpeechEasyAPI

#pragma mark - public methods

-(DMTextToSpeechEasyAPI *) init
{
    self = [super init];
    if (self){
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
        self.oauthKey = dictionary[@"ATTOauthKey"];
        self.oauthSecret = dictionary[@"ATTSecret"];
        self.speechServiceURL = [NSURL URLWithString: @"https://api.att.com/speech/v3/speechToText"];
        self.TTSUrl = [NSURL URLWithString: @"https://api.att.com/speech/v3/textToSpeech"];
        self.oauthURL = [NSURL URLWithString: @"https://api.att.com/oauth/token"];
        self.oauthScope = @"TTS,SPEECH";
        [self prepareSpeech];
    }
    return self;
}


-(void)readText:(NSString *)text
{
    [self startTTS: text];
}


#pragma mark - speech methods
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
    speechService.recognitionURL = self.oauthURL;
    speechService.delegate = self;
    speechService.speechContext = @"QuestionAndAnswer";
    [self validateOAuthForService: speechService];
    // Wake the audio components so there is minimal delay on the first request.
    [speechService prepare];
}

#pragma mark - implementation methods
- (void) startTTS: (NSString*) textToSpeak
{
    TTSRequest* tts = [TTSRequest forService: self.TTSUrl withOAuth: self.oauthToken];
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
        }
    }];
}

- (void) playAudioData: (NSData*) audioData
{
    //[self stopPlaying];
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error != nil) {
        NSLog(@"Not able to set audio session for playback: %@", error);
    }
    AVAudioPlayer* newPlayer = [[AVAudioPlayer alloc] initWithData: audioData error: &error];
    if (newPlayer == nil) {
        NSLog(@"Unable to play TTS audio data: %@", error);
    }
    [newPlayer play];
    self.audioPlayer = newPlayer;
}

- (void) validateOAuthForService: (ATTSpeechService*) speechService
{
    [[SpeechAuth authenticatorForService: self.oauthURL
                                  withId: self.oauthKey
                                  secret: self.oauthSecret
                                   scope: self.oauthScope]
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


#pragma mark - delegate methods
/**
 * The AT&T Speech to Text service returned a result.
 **/
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

/**
 * The AT&T Speech SDK or Speech to Text service returned an error.
 **/
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

@end
