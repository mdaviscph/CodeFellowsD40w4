//
//  Queue.h
//  LocationReminders
//
//  Created by mike davis on 9/1/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject

-(instancetype)init;
-(NSObject *)dequeue;
-(NSObject *)peek;  // should we protect against modification?
-(void)enqueue:(NSObject *)item;
-(NSString *)description;

@end
