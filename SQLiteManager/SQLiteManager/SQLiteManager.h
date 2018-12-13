//
//  SQLiteManager.h
//  SQLite_001
//
//  Created by 杨彤 on 2018/12/12.
//  Copyright © 2018年 JJXT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLiteManager : NSObject

+ (SQLiteManager *)sharedDatabaseManger;
//插入数据
- (void)sqliteInsertWith:(id)objc;
//删除数据
- (void)sqliteDeleteWith:(NSString *)keyName andValue:(NSString *)value andTableName:(id)tableName;
//删除所有数据
- (void)sqliteDeleteAllDataWithTableName:(id)objc;
//修改数据
- (void)sqliteUpdataWith:(NSString *)keyName andValue:(NSString *)value andObjcName:(id)objc;
//查询数据
- (NSArray *)sqliteSelectDataWith:(NSString *)keyName andValue:(NSString *)value andTableName:(NSString *)tableName;
//模糊查询
- (NSArray *)sqliteLikeSelectWith:(NSString *)keyName andValue:(NSString *)value andTableName:(NSString *)tableName;
@end

NS_ASSUME_NONNULL_END
