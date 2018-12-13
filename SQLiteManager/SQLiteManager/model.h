//
//  model.h
//  SQLite3-001
//
//  Created by yangtong on 2018/12/11.
//  Copyright © 2018年 yangtong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface model : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,assign) NSInteger age;
@end
