//
//  BMClient.h
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "BMNode.h"
#import "BMIdentities.h"
#import "BMContacts.h"
#import "BMMessages.h"
#import "BMSubscriptions.h"
#import "BMChannels.h"
#import "BMDatabase.h"

// extra

#import "BMMessage.h"
#import "BMChannel.h"
#import "BMSubscription.h"
#import "BMContact.h"
#import "BMIdentity.h"
#import "BMAddress.h"


@interface BMClient : BMNode

@property (strong, nonatomic) BMIdentities *identities;
@property (strong, nonatomic) BMContacts *contacts;
@property (strong, nonatomic) BMMessages *messages;
@property (strong, nonatomic) BMSubscriptions *subscriptions;
@property (strong, nonatomic) BMChannels *channels;
@property (strong, nonatomic) BMDatabase *readMessagesDB;
@property (strong, nonatomic) BMDatabase *deletedMessagesDB;


+ (BMClient *)sharedBMClient;

- (void)refresh;
- (NSString *)labelForAddress:(NSString *)addressString; // returns address if none found
- (NSString *)addressForLabel:(NSString *)labelString; // returns address if none found

- (NSMutableArray *)fromAddressLabels;
- (NSMutableArray *)toAddressLabels;
- (NSMutableArray *)allAddressLabels;

- (BOOL)hasNoIdentites;

@end
