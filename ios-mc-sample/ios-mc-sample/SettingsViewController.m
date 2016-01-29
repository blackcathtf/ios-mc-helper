//
//  SettingsViewController.m
//  ios-mc-sample
//
//  Created by nick on 16/1/29.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "SettingsViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString * const  kServiceType=@"kServiceType";

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *peerTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - private action

- (BOOL)isDisplayNameAndServiceTypeValid
{
    MCPeerID *peerID;
    @try {
        peerID = [[MCPeerID alloc] initWithDisplayName:_peerTextField.text];
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid display name [%@]", _peerTextField.text);
        return NO;
    }
    
    // Check if using this service type string causes a framework exception
    //
//    MCNearbyServiceAdvertiser *advertiser;
//    @try {
//        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:kServiceType];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Invalid service type [%@]", kServiceType);
//        return NO;
//    }
    NSLog(@"Room Name [%@] (aka service type) and display name [%@] are valid", kServiceType, peerID.displayName);
    // all exception checks passed
    return YES;
}
#pragma mark - event action

- (IBAction)doneBtnDidClick:(id)sender {
    if ([_peerTextField.text isEqualToString:@""]||[_peerTextField.text isEqual:nil]) {
        return;
    }else{
        [_delegate controller:self didCreateChatRoomWithDisplayName:_peerTextField.text serviceType:kServiceType];
    }
}
@end
