//
//  ValueTransformerTest.m
//  AppHider
//
//  Created by Dustin Sallings on 3/23/11.
//  Copyright 2011 NorthScale. All rights reserved.
//

#import "ValueTransformerTests.h"


@implementation ValueTransformerTests

- (void)setUp
{
    [super setUp];

    transformer = [[ReadableTimeValueTransformer alloc] init];
}

- (void)tearDown
{
    [transformer release];
    [super tearDown];
}

- (void)testEmptyReverse
{
    STAssertEquals(1, [[transformer reverseTransformedValue:@""] intValue],
                   @"Failed reverse.");
}

- (void)testZero
{
    STAssertEquals(1, [[transformer reverseTransformedValue:@"0s"] intValue],
                   @"Failed zero reverse.");
}

- (void)testJunk
{
    STAssertEquals(1, [[transformer reverseTransformedValue:@"Hello!"] intValue],
                   @"Failed junk.");
}

- (void)testOneSecond
{
    NSString *parsed = [transformer transformedValue:[NSNumber numberWithInt:1]];
    STAssertEqualObjects(@"1s", parsed, @"Broke");
    STAssertEquals(1, [[transformer reverseTransformedValue:parsed] intValue],
                   @"Failed reverse.");
}

- (void)testOneMinute
{
    STAssertEquals(60, [[transformer reverseTransformedValue:@"1m"] intValue],
                   @"Failed reverse.");
    
    STAssertEqualObjects(@"1m", [transformer transformedValue:[NSNumber numberWithInt:(60)]],
                         @"Error transforming to 1m");
}

- (void)testThreeMinutes
{
    STAssertEquals(3*60, [[transformer reverseTransformedValue:@"3m"] intValue],
                   @"Failed reverse.");

    STAssertEqualObjects(@"3m", [transformer transformedValue:[NSNumber numberWithInt:(3*60)]],
                         @"Error transforming to 3m");
}

- (void)testOneHour
{
    STAssertEquals(3600, [[transformer reverseTransformedValue:@"1h"] intValue],
                   @"Failed reverse.");
    
    STAssertEqualObjects(@"1h", [transformer transformedValue:[NSNumber numberWithInt:(3600)]],
                         @"Error transforming to 1h");
    
}

- (void)testTwoHours
{
    STAssertEquals(2*3600, [[transformer reverseTransformedValue:@"2h"] intValue],
                   @"Failed reverse.");

    STAssertEqualObjects(@"2h", [transformer transformedValue:[NSNumber numberWithInt:(2*3600)]],
                         @"Error transforming to 2h");

}

- (void)testFourDays
{
    STAssertEquals(4*24*3600, [[transformer reverseTransformedValue:@"96h"] intValue],
                   @"Failed reverse.");
    
    STAssertEqualObjects(@"96h", [transformer transformedValue:[NSNumber numberWithInt:(4*24*3600)]],
                         @"Error transforming to 96h");
    
}



@end
