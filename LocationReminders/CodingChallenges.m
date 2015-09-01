//
//  CodingChallenges.m
//  LocationReminders
//
//  Created by mike davis on 9/1/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "CodingChallenges.h"
#import "Stack.h"
#import "Queue.h"

@implementation CodingChallenges

-(void)monday {
  
  {
    Stack *stack = [[Stack alloc] init];
    [stack push:@1];
    [stack push:@2];
    [stack push:@3];
    [stack push:@4];
    [stack push:@5];
    NSLog(@"after push: %@", stack);
    NSLog(@"peek: %@, %@", [stack peek], [stack peek]);
    NSLog(@"after peek: %@", stack);
    NSLog(@"pop: %@, %@, %@", [stack pop], [stack pop], [stack pop]);
    NSLog(@"after pop: %@", stack);
    NSLog(@"pop: %@, %@, %@", [stack pop], [stack pop], [stack pop]);
    NSLog(@"after pop: %@", stack);
  }
  
  {
    Queue *queue = [[Queue alloc] init];
    [queue enqueue:@1];
    [queue enqueue:@2];
    [queue enqueue:@3];
    [queue enqueue:@4];
    [queue enqueue:@5];
    NSLog(@"after enqueue: %@", queue);
    NSLog(@"peek: %@, %@", [queue peek], [queue peek]);
    NSLog(@"after peek: %@", queue);
    NSLog(@"dequeue: %@, %@, %@", [queue dequeue], [queue dequeue], [queue dequeue]);
    NSLog(@"after dequeue: %@", queue);
    NSLog(@"dequeue: %@, %@, %@", [queue dequeue], [queue dequeue], [queue dequeue]);
    NSLog(@"after dequeue: %@", queue);
  }
}

@end
