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
//#import "SpeechConfig.h"
#import "SpeechAuth.h"
#import "TTSRequest.h"
#import "ATTSpeechKit.h"

@interface DMTextToSpeechEasyAPI : NSObject


-(void)readText:(NSString *)text;

@end
