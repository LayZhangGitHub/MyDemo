//
//  ConCommandA.m
//  LayZhangDemo
//
//  Created by Lay on 2019/6/4.
//  Copyright © 2019 Zhanglei. All rights reserved.
//

#import "ConCommandA.h"

@implementation ConCommandA

- (void)execute
{
    if (self.receiver) {
        [self.receiver doActionA];
    }
}

@end
