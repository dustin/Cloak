//
//  ReadableTimeValueTransformer.h
//  AppHider
//
//  Created by Dustin Sallings on 3/23/11.
//  Copyright 2011 NorthScale. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ReadableTimeValueTransformer : NSValueTransformer {
@private
    
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;


@end
