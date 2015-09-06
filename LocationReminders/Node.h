//
//  Node.h
//  LocationReminders
//
//  Created by mike davis on 9/6/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node: NSObject

@property (strong, nonatomic) Node *next;
@property (strong, nonatomic) NSNumber *data;

- (instancetype) initWith: (NSNumber *)data;

@end
