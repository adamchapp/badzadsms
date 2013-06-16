//
//  DeviceNameUtil.m
//  MapMessage
//
//  Created by Adam Chappell on 15/06/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "DeviceNameUtil.h"

@implementation DeviceNameUtil

+ (NSArray*)newNamesFromDevice
{
    NSString *deviceName = [[UIDevice currentDevice] name];
    
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@" '’\\"];
    NSArray* words = [deviceName componentsSeparatedByCharactersInSet:characterSet];
    NSMutableArray* names = [[NSMutableArray alloc] init];
    
    bool foundShortWord = false;
    for (NSString __strong *word in words)
    {
        if ([word length] <= 2)
            foundShortWord = true;
        if ([word compare:@"iPhone"] != 0 && [word compare:@"iPod"] != 0 && [word compare:@"iPad"] != 0 && [word length] > 2)
        {
            word = [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[word substringToIndex:1] uppercaseString]];
            [names addObject:word];
        }
    }
    if (!foundShortWord && [names count] > 1)
    {
        int lastNameIndex = [names count] - 1;
        NSString* name = [names objectAtIndex:lastNameIndex];
        unichar lastChar = [name characterAtIndex:[name length] - 1];
        if (lastChar == 's')
        {
            [names replaceObjectAtIndex:lastNameIndex withObject:[name substringToIndex:[name length] - 1]];
        }
    }
    return names;
}


+ (NSString *)nameFromDevice
{
    return [[self newNamesFromDevice] objectAtIndex:0];
}

@end
