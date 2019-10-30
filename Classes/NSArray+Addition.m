//
//  NSArray+Addition.m
//  TouchNumber
//
//  Created by Takishima on 11/08/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Addition.h"


@implementation NSArray (Addition)

- (NSArray *) randomizedArray {
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];
    int i = (int)[results count];
    
    while(--i) {
        int j = rand() % (i + 1);
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    return results;
}

- (NSInteger)sumIntArray {

    NSInteger sum = 0;
    for (int i = 0; i < [self count]; i++) {
        sum += [[self objectAtIndex:i] intValue];
    }
    
    return sum;
}

@end
