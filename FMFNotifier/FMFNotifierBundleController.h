//
//  FMFNotifierBundleController.h
//  FMFNotifier
//
//  Created by Gianluca Puglia on 21/02/14.
//  Copyright (c) 2014 Gianluca Puglia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>

@interface FMFNotifierBundleController : PSListController {
    
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;

- (void)makeEmail:(PSSpecifier*)specifier;
- (void)makeDonation:(PSSpecifier*)specifier;

@end