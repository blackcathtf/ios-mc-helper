//
//  SettingsViewController.h
//  ios-mc-sample
//
//  Created by nick on 16/1/29.
//  Copyright © 2016年 nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)controller:(SettingsViewController *)controller didCreateChatRoomWithDisplayName:(NSString *)displayName serviceType:(NSString *)serviceType;

@end

@interface SettingsViewController : UIViewController

@property (assign, nonatomic) id<SettingsViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSString *serviceType;

@end

