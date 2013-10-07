//
//  MWBoxAuxSettingEntity.m
//  MultiWii
//
//  Created by Eugene Skrebnev on 10/4/13.
//  Copyright (c) 2013 EugeneSkrebnev. All rights reserved.
//

#import "MWBoxAuxSettingEntity.h"

@implementation MWBoxAuxSettingEntity


-(BOOL) isCheckedForAux:(int) auxIndex andPosition:(int) position // 0 - low 1 - mid 2 - high
{
    int bitIndex = auxIndex * 3 + position;
    return (self.bitMask & (1 << bitIndex)) != 0;
}

-(BOOL) isSavedForAux:(int) auxIndex andPosition:(int) position// 0 - low 1 - mid 2 - high
{
    int bitIndex = auxIndex * 3 + position;
    return (((self.savedBitMask & (1 << bitIndex)) ^ (self.bitMask & (1 << bitIndex))) == 0);
}

-(void) setValue:(BOOL) value forAux:(int) auxIndex andPosition:(int) position // 0 - low 1 - mid 2 - high
{
    int bitIndex = auxIndex * 3 + position;
    if (value)
        self.bitMask |=  (1 << bitIndex);
    else
        self.bitMask &= ~(1 << bitIndex);
    
}

-(void) fillbitMaskFromLowBits:(int) lowbits andHighBits:(int) highBits
{
    self.bitMask = lowbits | highBits << 8;
}

@end