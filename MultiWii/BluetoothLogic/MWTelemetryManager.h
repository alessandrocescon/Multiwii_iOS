//
//  MWPidSettingsManager.h
//  MultiWii
//
//  Created by Eugene Skrebnev on 7/21/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWTelemetryRawImu.h"
#import "MWTelemetryAttitude.h"
#import "MWTelemetryAltitude.h"
#import "MWTelemetryRadio.h"
#import "MWTelemetryGPS.h"

@interface MWTelemetryManager : NSObject

@property (nonatomic, strong) MWTelemetryRawImu* raw;
@property (nonatomic, strong) MWTelemetryAttitude* attitude;
@property (nonatomic, strong) MWTelemetryAltitude* altitude;
@property (nonatomic, strong) MWTelemetryRadio* radio;
@property (nonatomic, strong) MWTelemetryGPS* gps;

@end
