//
//  NodeLinkedList.h
//  LocationReminders
//
//  Created by mike davis on 9/6/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Node;

@interface NodeLinkedList: NSObject

@property (strong, nonatomic) Node *head;

- (void) insertInSortedOrder: (Node *)node;
- (void) removeAll;
- (void) removeMatching: (NSNumber *)data;
- (void) nslogEmAll;

@end
