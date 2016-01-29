//
//  ViewController.m
//  ios-mc-sample
//
//  Created by nick on 16/1/29.
//  Copyright © 2016年 nick. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString * const kNSDefaultPeerName = @"peerNameKey";
NSString * const kNSDefaultServiceType = @"serviceTypeKey";

NSString * const  peerCellIdentifier=@"peerCellIdentifier";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,MCNearbyServiceBrowserDelegate,SettingsViewControllerDelegate,MCSessionDelegate>

@property(nonatomic,strong)NSMutableArray *peerArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *AdSwitch;
@property (weak, nonatomic) IBOutlet UILabel *noticeLab;

@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyBrowser;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;


@property (strong, nonatomic) NSString *peerName;
@property (strong, nonatomic) NSString *serviceType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPeerArray];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _peerName = [defaults objectForKey:kNSDefaultPeerName];
    _serviceType = [defaults objectForKey:kNSDefaultServiceType];
    
    if (_peerName&&_serviceType) {
        [self searchNearBy];
    }else{
        _noticeLab.hidden=NO;
    }
}
#pragma mark - SettingsViewControllerDelegate methods

// Delegate method implementation handling return from the "Create Chat Room" pages
- (void)controller:(SettingsViewController *)controller didCreateChatRoomWithDisplayName:(NSString *)displayName serviceType:(NSString *)serviceType
{
    // Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Cache these for MC session creation and changing later via the "info" button
    _peerName = displayName;
    _serviceType = serviceType;
    
    // Save these for subsequent app launches
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:displayName forKey:kNSDefaultPeerName];
    [defaults setObject:serviceType forKey:kNSDefaultServiceType];
    [defaults synchronize];
    
    // begin search
    [self searchNearBy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _peerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:peerCellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:peerCellIdentifier];
    }
    MCPeerID *peer=_peerArray[indexPath.row];
    cell.textLabel.text=peer.displayName;
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self inviteNearbyPeer:_peerArray[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - MCNearbyServiceBrowserDelegate

- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"OH MY GOD! I FOUND ONE %@",peerID.displayName);
    if (![_peerArray containsObject:peerID]&&![peerID.displayName isEqualToString:_peerName]) {
        [_peerArray addObject:peerID];
        [_tableView reloadData];
    }
}

// A nearby peer has stopped advertising.
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"OH MY GOD! I LOST ONE %@",peerID.displayName);
    if ([_peerArray containsObject:peerID]) {
        [_peerArray removeObject:peerID];
        [_tableView reloadData];
    }

}
#pragma mark - MCSessionDelegate
// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"Connected");
            
        case MCSessionStateConnecting:
            NSLog(@"Connecting");
            
        case MCSessionStateNotConnected:
            NSLog(@"NotConnected");
    }
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{

}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID
{

}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress
{

}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error
{

}


#pragma mark - private action
-(void)searchNearBy
{
    //init session
    [self initSession];
    //init adveryoser
    [self initAdvertiser];
    //init browser
    [self initBrowser];
    // begin qv search
    [_nearbyBrowser startBrowsingForPeers];
    // hidden the notice
    _noticeLab.hidden=YES;
    [self advertiserSwitchDidChange:nil];
}
-(void)inviteNearbyPeer:(MCPeerID*)peerID
{
    [_nearbyBrowser invitePeer:peerID toSession:_session withContext:nil timeout:30];
}
#pragma mark - event action
- (IBAction)advertiserSwitchDidChange:(id)sender {
    if (_AdSwitch.on) {
        NSLog(@"advertiser open");
        [_advertiserAssistant start];
    }else{
        NSLog(@"advertiser close");
        [_advertiserAssistant stop];
    }
}
-(IBAction)presentToSetting
{
    //获取storyboard: 通过bundle根据storyboard的名字来获取我们的storyboard,
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    SettingsViewController *settingVC = (SettingsViewController*)[story instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    settingVC.delegate=self;
    [self presentViewController:settingVC animated:YES completion:nil];
}
#pragma mark - init
-(void)initBrowser
{
    MCPeerID * peerID=[[MCPeerID alloc]initWithDisplayName:_peerName];
    _nearbyBrowser=[[MCNearbyServiceBrowser alloc]initWithPeer:peerID serviceType:_serviceType];
    _nearbyBrowser.delegate=self;
}
-(void)initPeerArray
{
    if (_peerArray==nil) {
        _peerArray =[[NSMutableArray alloc]init];
    }
    [_peerArray removeAllObjects];
}
-(void)initSession
{
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:_peerName];
    _session=[[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    _session.delegate = self;

}
-(void)initAdvertiser
{
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:_serviceType discoveryInfo:nil session:_session];
}
@end
