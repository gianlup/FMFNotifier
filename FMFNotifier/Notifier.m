//
//  Notifier.m
//  FMFNotifier
//
//  Created by Gianluca Puglia on 18/02/14.
//
//

#import "Notifier.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Notifier

static Notifier *controller = nil;

+ (Notifier *)sharedInstance {
	@synchronized(self) {
		if (controller == nil) {
			controller = [[self alloc] init];
		}
	}
	return controller;
}

- (void)showNotificationWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID {
	BBBulletinRequest *request = [[objc_getClass("BBBulletinRequest") alloc] init];
	[request setTitle:title];
	[request setMessage:message];
	[request setSectionID:bundleID];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/shake.caf" isDirectory:NO], &sound);
    if(sound) {
        [request setSound:[objc_getClass("BBSound") alertSoundWithSystemSoundID:sound]];
    }
    [[objc_getClass("BBServer") sharedServer] publishBulletinRequest:request destinations:14 alwaysToLockScreen:YES];
}

@end