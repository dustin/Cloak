//
//  ReadableTimeValueTransformer.m
//  AppHider
//
//  Created by Dustin Sallings on 3/23/11.
//  Copyright 2011 NorthScale. All rights reserved.
//

#import "ReadableTimeValueTransformer.h"


@implementation ReadableTimeValueTransformer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    char *extensions="smh";
    int offset = 0;
    int x = [value intValue];

    while (x >= 60 && offset < strlen(extensions) - 1) {
        ++offset;
        x /= 60;
    }
    return [NSString stringWithFormat:@"%d%c", x, extensions[offset]];
}

- (id)reverseTransformedValue:(id)value {
    int multiplier = 1;
    if ([value length] > 0) {
        switch([value cStringUsingEncoding:NSUTF8StringEncoding][[value length]-1]) {
            case 's':
                multiplier = 1;
                break;
            case 'm':
                multiplier = 60;
                break;
            case 'h':
                multiplier = 3600;
                break;
            default:
                multiplier = 1;
                break;
        }
        return [NSNumber numberWithInt:([value intValue] * multiplier)];
    } else {
        return [NSNumber numberWithInt:1];
    }
}


@end
