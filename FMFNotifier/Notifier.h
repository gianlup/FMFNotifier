//
//  Notifier.h
//  FMFNotifier
//
//  Created by Gianluca Puglia on 18/02/14.
//
//

#import <objc/runtime.h>

@interface BBServer : NSObject { }
+ (BBServer *)sharedServer;
- (void)publishBulletinRequest:(id)arg1 destinations:(unsigned int)arg2 alwaysToLockScreen:(BOOL)arg3;
@end

@interface BBSound : NSObject { }
+ (id)alertSoundWithSystemSoundID:(unsigned long)arg1;
@end

@interface BBBulletin : NSObject { }
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *sectionID;
@property (nonatomic, retain) BBSound *sound;
@end

@interface BBBulletinRequest : BBBulletin { }
@end

@interface Notifier : NSObject { }
+ (Notifier *)sharedInstance;
- (void)showNotificationWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
@end