//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import "QMAddMembersToGroupController.h"
#import "QMGroupDetailsDataSource.h"
#import "SVProgressHUD.h"
#import "QMApi.h"
#import "QMChatReceiver.h"

@interface QMGroupDetailsController ()

<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QBChatRoom *chatRoom;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;

@end

@implementation QMGroupDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[QMGroupDetailsDataSource alloc] initWithChatDialog:self.chatDialog tableView:self.tableView];
    [self subscribeToNotifications];
    
    self.chatRoom = [[QMApi instance] roomWithRoomJID:self.chatDialog.roomJID];
    [self.chatRoom requestOnlineUsers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show chat dialog getails on view:
    [self showQBChatDialogDetails:self.chatDialog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [SVProgressHUD dismiss];
    }];
}

- (void)showQBChatDialogDetails:(QBChatDialog *)chatDialog {
    
    if (chatDialog != nil && chatDialog.type == QBChatDialogTypeGroup) {
        
        // set group name:
        self.groupNameField.text = chatDialog.name;
        // numb of participants:
        NSString *occupantsCountText = [NSString stringWithFormat:@"%lu participants", (unsigned long)[self.chatDialog.occupantIDs count]];
        self.occupantsCountLabel.text = occupantsCountText;
        // default online participants counts:
        NSString *onlineUsersCountText = [NSString stringWithFormat:@"0/%lu online", (unsigned long)[self.chatDialog.occupantIDs count]];
        self.onlineOccupantsCountLabel.text = onlineUsersCountText;
    }
}

- (void)subscribeToNotifications {
    
    [[QMChatReceiver instance] chatRoomDidReceiveListOfOnlineUsersWithTarget:self block:^(NSArray *users, NSString *roomName) {
        // update online participants count:
        NSString *onlineUsersCountText = [NSString stringWithFormat:@"%d/%d online", users.count, self.chatDialog.occupantIDs.count];
        self.onlineOccupantsCountLabel.text = onlineUsersCountText;
    }];
}

//- (void)chatDialogWasUpdated:(NSNotification *)notification {
//    
//    NSString *roomJID = notification.userInfo[@"room_jid"];
////    QBChatDialog *updatedDialog = [QMChatService shared].allDialogsAsDictionary[roomJID];
////    self.chatDialog = updatedDialog;
//    
//    // update UI:
//    [self showQBChatDialogDetails:self.chatDialog];
//    [self updateDataSource];
//    
//    // request online users statuses:
//    [self.chatRoom requestOnlineUsers];
//}

- (void)updateDataSource {
    
    _dataSource = [[QMGroupDetailsDataSource alloc] initWithChatDialog:self.chatDialog tableView:self.tableView];
    self.tableView.dataSource = _dataSource;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:QMAddMembersToGroupController.class]) {
        ((QMAddMembersToGroupController *)segue.destinationViewController).chatDialog = self.chatDialog;
    }
}

@end
