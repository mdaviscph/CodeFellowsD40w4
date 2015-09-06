//
//  NodeLinkedList.m
//  LocationReminders
//
//  Created by mike davis on 9/6/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "NodeLinkedList.h"
#import "Node.h"

@implementation NodeLinkedList

- (void) insertInSortedOrder: (Node *)node {
  Node *next = self.head;
  Node *prev = nil;
  while (next && next.data < node.data) {
    prev = next;
    next = next.next;
  }
  if (prev) {
    prev.next = node;
    node.next = next;
  } else {
    self.head = node;
    node.next = next;
  }
}

- (void) removeAll {
  Node *next = self.head;
  while (next) {
    Node *this = next;
    next = next.next;
    this.next = nil;
  }
  self.head = nil;
}

- (void) removeMatching: (NSNumber *)data {
  Node *next = self.head;
  Node *prev = nil;
  while (next && next.data != data) {
    prev = next;
    next = next.next;
  }
  if (next && prev) {
    prev.next = next.next;
  } else if (next) {
    self.head = next.next;
  }
}

- (void) nslogEmAll {
  Node *next = self.head;
  NSString *output = @"";
  while (next) {
    output = [output stringByAppendingString: [NSString stringWithFormat: @"%@, ", next.data]];
    next = next.next;
  }
  NSLog(@"linked list: %@", output);
}
@end
