//
//  MWGlobalManager.m
//  MultiWii
//
//  Created by Eugene Skrebnev on 7/22/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import "MWGlobalManager.h"

@implementation MWGlobalManager

+ (MWGlobalManager *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.bluetoothManager = [MWBluetoothManager sharedInstance];
        self.pidManager = [MWPidSettingsManager sharedInstance];
        self.protocolManager = [MWMultiwiiProtocolManager sharedInstance];
        self.boxManager = [MWBoxSettingsManager sharedInstance];
        [self initDefaultHandlers];
    }
    return self;
}

-(void) copterIdentInfoRecieved:(NSData*) copterInfo
{
    unsigned char *x = (unsigned char*)copterInfo.bytes;
    for (int i = 0; i < copterInfo.length; i++)
    {
        NSLog(@"%d", x[i]);
    }
    int identifier = x[0];
    if ((identifier != MWI_BLE_MESSAGE_IDENT) || (copterInfo.length < 8)) //8 is default size for ident request
    {
        NSLog(@"COPTER INFO ERROR %@", copterInfo);
        return;
    }
    
    self.version = x[1];
    int copterType = x[2];
    
    _copterType = -1;
    if (copterType == 1)
        _copterType = MWGlobalManagerQuadTypeTricopter;
    if (copterType == 2)
        _copterType = MWGlobalManagerQuadTypePlus;
    if (copterType == 3)
        _copterType = MWGlobalManagerQuadTypeX;
    if (copterType == 4)
        _copterType = MWGlobalManagerQuadTypeBicopter;
    if (copterType == 5)
        _copterType = MWGlobalManagerQuadTypeGimbal;
    if (copterType == 6)
        _copterType = MWGlobalManagerQuadTypeY6;
    if (copterType == 7)
        _copterType = MWGlobalManagerQuadTypeHexPlus;
    if (copterType == 8)
        _copterType = MWGlobalManagerQuadTypeFlyingWing;
    if (copterType == 9)
        _copterType = MWGlobalManagerQuadTypeY4;
    if (copterType == 10)
        _copterType = MWGlobalManagerQuadTypeHexX;
    if (self.copterType == -1)
        _copterType = MWGlobalManagerQuadTypeUnknown;

    self.mspVersion = x[3];
    
    self.copterCapabilities = 0;
    if (x[4] != 0 )
        self.copterCapabilities |= MWGlobalManagerQuadBoardCapability1;
    if (x[5] != 0 )
        self.copterCapabilities |= MWGlobalManagerQuadBoardCapability2;
    if (x[6] != 0 )
        self.copterCapabilities |= MWGlobalManagerQuadBoardCapability3;
    if (x[7] != 0 )
        self.copterCapabilities |= MWGlobalManagerQuadBoardCapability4;
}

-(void) copterPidDataRecieved:(NSData*) pidData
{
    [self.pidManager fillPidFromPayload:pidData];
}

-(void) copterBoxNamesDataRecieved:(NSData*) boxNames
{
    [self.boxManager fillBoxesNamesFromPayload:boxNames];
}

-(void) initDefaultHandlers
{
    __weak MWGlobalManager* selfWeak = self;
    
    [self.protocolManager setDefaultHandler:^(NSData *recieveData) {
        [selfWeak copterIdentInfoRecieved:recieveData];
    } forRequestWith:MWI_BLE_MESSAGE_IDENT];
    
    [self.protocolManager setDefaultHandler:^(NSData *recieveData) {
        [selfWeak copterPidDataRecieved:recieveData];
    } forRequestWith:MWI_BLE_MESSAGE_GET_PID];
    
    [self.protocolManager setDefaultHandler:^(NSData *recieveData) {
        [selfWeak copterBoxNamesDataRecieved:recieveData];
    } forRequestWith:MWI_BLE_MESSAGE_GET_BOX_NAMES];
    

}

@end
