//
//  DMTextToSpeechEasyAPI.h
//  HackathonTextToSpeech
//
//  Created by Adam Gluck on 8/13/13.
//  Copyright (c) 2013 DataMason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "SpeechAuth.h"
#import "TTSRequest.h"
#import "ATTSpeechKit.h"

@protocol TTSEasyAPIDelegate <NSObject>

typedef NS_ENUM(NSInteger, SimpleSpeechError){
    SpeechFailed,
    SpeechNotRecognized,
    SpeechCanceledByUser,
    AudioError
};
@optional
/* these are called in response to attempts to authentication after an object is initialized... if it fails you should simply call retry with the object returned from initialization */
-(void)speechAuthenticationSucceeded;
-(void)speechAuthenticationFailed;

/* this is called when text is not converted into speech... you might want to call -(void)readText:(NSSTring*)text and put the failed text string returned here into that method to attempt again */
-(void)textConversionFailedFromText:(NSString *)text withError:(NSError *)error;

/* this is called when speech is recognized */
-(void)speechWasRecognizedWithText:(NSString *)text;

/* these methods are called when speech is failed to be recognized...
 if you just get "speech failed" you may want to use error.localizedDescription for more introspection
 in particular with audio errors */
-(void)speechFailedWithSimpleSpeechError:(SimpleSpeechError)simpleError andNSError:(NSError *)error;

@end

@interface TTSEasyAPI : NSObject

/* The regular init handles all authentication under the hood as long as you set your key and oauth token in Info.plist under your supporting files. The key should be under ATTOauthKey and the secret should be under ATTOauthSecret.  You can get these by creating a developer account at developer.att.com.  If the idea of a plist scares you though you can use the method below, though. */
/* Also note that initializing an object starts an authentication request, if you want to be able to see the results of that initial authentication request, you need to initWithDelegate: */

-(TTSEasyAPI *) initWithOauthKey: (NSString *)oauthKey andOauthSecret: (NSString *) oauthSecret andDelegate: (id) delegate;
-(TTSEasyAPI *) initWithDelegate: (id) delegate;

/* simplest, just call this after the object is initialized and you'll hear your phone speak the text back to you! Two lines of code.
    Note: To avoid delays when reading text you should implement the delegate method speechPreparationSucceeded: and make sure it is called before allowing the user to interact with readText*/
-(void)readText:(NSString *)text;

/* two important delegate methods: recommended is implementing the delegate method speechPreparationSucceeded before allowing text to be read, also speechWasRecognizedWithText: needs to be implemented to get the response to listening */
@property (weak, nonatomic) id <TTSEasyAPIDelegate> delegate;

/* need to implement the method speechWasRecognizedWithText: in the delegate to get the speech returned from listen! */
-(ATTSpeechService *)listen;

/* this simply attempts to re-initialize the object if speechPrepartionFailed returns, call this to try to authenticate again*/
-(void)retry;

typedef NS_ENUM(NSInteger, AuthenticationStatus){
    AuthenticationFailed,
    Authenticated,
    AuthenticationInProgress
};

@property (assign) AuthenticationStatus authenticationStatus;


@end
