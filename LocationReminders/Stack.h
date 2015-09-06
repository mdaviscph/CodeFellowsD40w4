//
//  Stack.h
//  LocationReminders
//
//  Created by mike davis on 9/1/15.
//  Copyright (c) 2015 mike davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack: NSObject

-(instancetype)init;
-(NSObject *)pop;
-(NSObject *)peek;  // should we protect against modification?
-(void)push:(NSObject *)item;
-(NSString *)description;

@end
