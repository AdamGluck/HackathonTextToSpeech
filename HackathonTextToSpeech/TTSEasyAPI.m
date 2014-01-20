//
//  DMTextToSpeechEasyAPI.m
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import "TTSEasyAPI.h"

@interface TTSEasyAPI()<ATTSpeechServiceDelegate>

@property (strong, nonatomic) NSString* oauthToken;
@property (strong, nonatomic) NSString* ttsInProgress;
@property (retain, nonatomic) AVAudioPlayer* audioPlayer;
@property (strong, nonatomic) NSURL * speechServiceURL;
@property (strong, nonatomic) NSURL * TTSUrl;
@property (strong, nonatomic) NSURL * oauthURL;
@property (strong, nonatomic) NSString * oauthKey;
@property (strong, nonatomic) NSString * oauthSecret;
@property (strong, nonatomic) NSString * oauthScope;
@end

@implementation TTSEasyAPI

#pragma mark - public methods

-(TTSEasyAPI *) initWithOauthKey: (NSString *)oauthKey andOauthSecret: (NSString *) oauthSecret andDelegate: (id) delegate
{
    self = [super init];
    if (self){
        self.oauthKey = [oauthKey copy];
        self.oauthSecret = [oauthSecret copy];
        self.speechServiceURL = [NSURL URLWithString: @"https://api.att.com/speech/v3/speechToText"];
        self.TTSUrl = [NSURL URLWithString: @"https://api.att.com/speech/v3/textToSpeech"];
        self.oauthURL = [NSURL URLWithString: @"https://api.att.com/oauth/token"];
        self.oauthScope = @"TTS,SPEECH";
        self.delegate = delegate;
        [self prepareSpeech];
    }
    return self;
}

-(TTSEasyAPI *) initWithDelegate: (id) delegate
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    self = [self initWithOauthKey:dictionary[@"ATTOauthKey"] andOauthSecret:dictionary[@"ATTSecret"] andDelegate:delegate];
    return self;
}

-(TTSEasyAPI *) init
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    self = [self initWithOauthKey:dictionary[@"ATTOauthKey"] andOauthSecret:dictionary[@"ATTSecret"] andDelegate:nil];
    return self;
}

-(void)readText:(NSString *)text
{
    __weak typeof(self) weakSelf = self;

    if (self.authenticationStatus == AuthenticationInProgress){
        dispatch_queue_t blockQueue = dispatch_queue_create("Block if authenticating", NULL);
        dispatch_async(blockQueue, ^{
            // block on async thread so it doesn't hold up drawing on main thread
            // this makes it so the app doesn't break with lazy instantiation and instead just delays
            NSInteger tries = 0;
            while (weakSelf.authenticationStatus == AuthenticationInProgress && tries < 5){
                sleep(1);
                tries++;
            }
            
            if (weakSelf.authenticationStatus == Authenticated){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startTTS: text];
                });
            }
        });
    } else {
        [self startTTS:text];
    }
}

-(void)retry
{
    [self prepareSpeech];
}

#pragma mark - speech methods
- (void) prepareSpeech
{
    // Set up this application for audio output.
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error != nil) {
        [self delegateMethodSpeechFailedWithSimpleSpeechError:AudioError andNSError:error];
    }
    // Access the SpeechKit singleton.
    ATTSpeechService* speechService = [ATTSpeechService sharedSpeechService];
    speechService.recognitionURL = self.speechServiceURL;
    speechService.delegate = self;
    speechService.speechContext = @"QuestionAndAnswer";
    [self validateOAuthForService: speechService];
    // Wake the audio components so there is minimal delay on the first request.
    [speechService prepare];
}

#pragma mark - implementation methods
#pragma mark - start/stop TTS
- (void) startTTS: (NSString*) textToSpeak
{
    TTSRequest* tts = [TTSRequest forService: self.TTSUrl withOAuth: self.oauthToken];
    self.ttsInProgress = textToSpeak;
    
    [tts postText: textToSpeak forClient: ^(NSData* audioData, NSError* error) {
        if (![textToSpeak isEqualToString: self.ttsInProgress]) {
            [self delegateMethodSpeechFailedWithSimpleSpeechError:SpeechCanceledByUser andNSError:error];
        }
        else if (audioData != nil) {
            [self playAudioData: audioData];
        }
        else {
            [self delegateMethodTextConversionFailedFromText:textToSpeak withError:error];
        }
    }];
}

- (void) playAudioData: (NSData*) audioData
{
    [self stopPlaying];
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    if (error != nil) {
        [self delegateMethodSpeechFailedWithSimpleSpeechError:AudioError andNSError:error];
    }
    AVAudioPlayer* newPlayer = [[AVAudioPlayer alloc] initWithData: audioData error: &error];
    if (newPlayer == nil) {
        [self delegateMethodSpeechFailedWithSimpleSpeechError:AudioError andNSError:error];
    }
    [newPlayer play];
    self.audioPlayer = newPlayer;
}

- (void) stopTTS
{
    self.ttsInProgress = nil;
    [self stopPlaying];
}

- (void) stopPlaying
{
    AVAudioPlayer* oldPlayer = self.audioPlayer;
    if (oldPlayer != nil) {
        [oldPlayer stop];
        self.audioPlayer = nil;
    }
}

#pragma mark - Security
#pragma mark - Oauth Validation

- (void) validateOAuthForService: (ATTSpeechService*) speechService
{
    self.authenticationStatus = AuthenticationInProgress;
    [[SpeechAuth authenticatorForService: self.oauthURL
                                  withId: self.oauthKey
                                  secret: self.oauthSecret
                                   scope: self.oauthScope]
     fetchTo: ^(NSString* token, NSError* error) {
         if (token) {
             self.authenticationStatus = Authenticated;
             self.oauthToken = token;
             speechService.bearerAuthToken = token;
             [self delegateMethodSpeechAuthenticationSucceeded];
         }
         else {
             self.authenticationStatus = AuthenticationFailed;
             self.oauthToken = nil;
             [self delegateMethodSpeechAuthenticationFailed];
         }
     }];
}


#pragma mark - Speech to text
#pragma mark - Start/stop STT

- (ATTSpeechService *) listen
{
    // Don't let TTS playback interfere with audio capture.
    [self stopTTS];
    ATTSpeechService* speechService = [ATTSpeechService sharedSpeechService];
    speechService.xArgs =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"main", @"ClientScreen", nil];
    [speechService startListening];
    return speechService;
}

#pragma mark - delegate methods

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
        [self delegateMethodSpeechWasRecognizedWithText:recognizedText];
    } else {
        [self delegateMethodSpeechFailedWithSimpleSpeechError:SpeechNotRecognized andNSError:nil];
    }
}

- (void) speechService: (ATTSpeechService*) speechService
       failedWithError: (NSError*) error
{
    if ([error.domain isEqualToString: ATTSpeechServiceErrorDomain]
        && (error.code == ATTSpeechServiceErrorCodeCanceledByUser)) {
        NSLog(@"Speech service canceled");
        return;
    }
    NSLog(@"speech service failed with error %@", error.localizedDescription);
    [self delegateMethodSpeechFailedWithSimpleSpeechError:SpeechFailed andNSError:error];
}

#pragma mark - DMTextToSpeechEasyAPI delegate methods

-(void)delegateMethodSpeechAuthenticationSucceeded
{
    if ([self.delegate respondsToSelector:@selector(speechAuthenticationSucceeded)]){
        [self.delegate speechAuthenticationSucceeded];
    }
}

-(void)delegateMethodSpeechAuthenticationFailed
{
    if ([self.delegate respondsToSelector:@selector(speechPreparationFailed)]){
        [self.delegate speechAuthenticationFailed];
    }
}

-(void)delegateMethodSpeechWasRecognizedWithText:(NSString *)text
{
    if ([self.delegate respondsToSelector:@selector(speechWasRecognizedWithText:)]){
        [self.delegate speechWasRecognizedWithText:text];
    }
}

-(void)delegateMethodSpeechFailedWithSimpleSpeechError: (SimpleSpeechError) simpleError andNSError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(speechFailedWithSimpleSpeechError:)]){
        [self.delegate speechFailedWithSimpleSpeechError:simpleError andNSError:error];
    }
}

-(void)delegateMethodTextConversionFailedFromText:(NSString *) text withError:(NSError *) error
{
    if ([self.delegate respondsToSelector:@selector(textConversionFailedFromText:)]){
        [self.delegate textConversionFailedFromText:text withError:error];
    }
}
@end
