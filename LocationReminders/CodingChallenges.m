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

-(BOOL) isAnagramOf:(NSString *)string1 string:(NSString *)string2 {
  NSMutableDictionary *countCharacters = [[NSMutableDictionary alloc] init];
  for (int i = 0; i < string1.length; i++) {
    unichar character = [string1 characterAtIndex:i];
    NSNumber *count = [countCharacters objectForKey:@(character)];
    if (!count) {
      [countCharacters setObject:@1 forKey:@(character)];
    } else {
      NSNumber *count = @([[countCharacters objectForKey:@(character)] intValue] + 1);
      [countCharacters setObject:count forKey:@(character)];
    }
  }
  for (int i = 0; i < string2.length; i++) {
    unichar character = [string2 characterAtIndex:i];
    NSNumber *count = [countCharacters objectForKey:@(character)];
    if (!count) {
      return NO;
    } else {
      NSNumber *count = @([[countCharacters objectForKey:@(character)] intValue] - 1);
      if ([count isEqualToNumber:@-1]) {
        return NO;
      } else if ([count isEqualToNumber:@0]) {
        [countCharacters removeObjectForKey:@(character)];
      } else {
        [countCharacters setObject:count forKey:@(character)];
      }
    }
  }
  if (countCharacters.count == 0) {
    return YES;
  }
  return NO;
}

-(void) tuesday {
  NSString *string1 = @"abcdefgh";
  NSString *string2 = @"badcfehg";
  NSString *string3 = @"aabbccddeeffgghh";
  NSString *string4 = @"😸😡😀";
  
  BOOL anagramA = [self isAnagramOf:string1 string:string2];
  NSLog(@"string1: %@ string2: %@ is anagram: %@", string1, string2, anagramA ? @"YES" : @"NO");
  BOOL anagramB = [self isAnagramOf:string1 string:string3];
  NSLog(@"string1: %@ string3: %@ is anagram: %@", string1, string3, anagramB ? @"YES" : @"NO");
  BOOL anagramC = [self isAnagramOf:string4 string:string4];
  NSLog(@"string4: %@ to itself is anagram: %@", string4, anagramC ? @"YES" : @"NO");
}
@end
