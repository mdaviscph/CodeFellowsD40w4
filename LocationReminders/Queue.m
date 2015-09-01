//
//  Queue.m
//  LocationReminders
//
//  Created by mike davis on 9/1/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "Queue.h"

@interface Queue()
@property (strong, nonatomic) NSMutableArray *array;
@end

@implementation Queue

-(NSMutableArray *)array {
  if (!_array) {
    _array = [[NSMutableArray alloc] init];
  }
  return _array;
}

-(instancetype)init {
  self = [super init];
  if (self) {
    
  }
  return self;
}
-(NSObject *)dequeue {
  if (!self.array.count) {
    return nil;
  }
  NSObject *item = self.array[0];
  [self.array removeObjectAtIndex:0];
  return item;
}
-(NSObject *)peek {
  if (!self.array.count) {
    return nil;
  }
  NSObject *item = self.array[0];
  return item;
}
-(void)enqueue:(NSObject *)item {
  [self.array addObject:item];
}
-(NSString *)description {
  return [[self.array valueForKey:@"description"] componentsJoinedByString:@", "];
}

@end
