//
//  Stack.m
//  LocationReminders
//
//  Created by mike davis on 9/1/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import "Stack.h"

@interface Stack()
@property (strong, nonatomic) NSMutableArray *array;
@end

@implementation Stack

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
-(NSObject *)pop {
  if (!self.array.count) {
    return nil;
  }
  NSObject *item = self.array[self.array.count-1];
  [self.array removeLastObject];
  return item;
}
-(NSObject *)peek {
  if (!self.array.count) {
    return nil;
  }
  NSObject *item = self.array[self.array.count-1];
  return item;
}
-(void)push:(NSObject *)item {
  [self.array addObject:item];
}
-(NSString *)description {
  return [[self.array valueForKey:@"description"] componentsJoinedByString:@", "];
}

@end
