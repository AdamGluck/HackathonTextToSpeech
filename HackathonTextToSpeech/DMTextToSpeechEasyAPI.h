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
#import "DMViewController.h"
#import "SpeechAuth.h"
#import "TTSRequest.h"
#import "ATTSpeechKit.h"

@protocol DMTextToSpeechEasyAPIDelegate <NSObject>

typedef NS_ENUM(NSInteger, SimpleSpeechError){
    SpeechFailed,
    SpeechNotRecognized,
    SpeechCanceledByUser,
    AudioError
};
@optional
/* these are called in response to attempts to authentication after an object is initialized... if it fails you should simply call retry with the object returned from initialization */
-(void)speechPreparationSucceeded;
-(void)speechPreparationFailed;

/* this is called when text is not converted into speech... you might want to call -(void)readText:(NSSTring*)text and put the failed text string returned here into that method to attempt again */
-(void)textConversionFailedFromText:(NSString *)text withError:(NSError *)error;

/* this is called when speech is recognized */
-(void)speechWasRecognizedWithText:(NSString *)text;

/* these methods are called when speech is failed to be recognized...
 if you just get "speech failed" you may want to use error.localizedDescription for more introspection
 in particular with audio errors */
-(void)speechFailedWithSimpleSpeechError:(SimpleSpeechError)simpleError andNSError:(NSError *)error;

@end

@interface DMTextToSpeechEasyAPI : NSObject

/* simplest, just call this after the object is initialized and you'll hear your phone speak the text back to you! */
-(void)readText:(NSString *)text;

/* two important delegate methods: recommended is implementing the delegate method speechPreparationSucceeded before allowing text to be read, also speechWasRecognizedWithText: needs to be implemented to get the response to listening */
@property (weak, nonatomic) id <DMTextToSpeechEasyAPIDelegate> delegate;

/* need to implement the method speechWasRecognizedWithText: in the delegate to get the speech returned from listen! */
-(ATTSpeechService *)listen;

/* this simply attempts to re-initialize the object */
-(void)retry;

@end
