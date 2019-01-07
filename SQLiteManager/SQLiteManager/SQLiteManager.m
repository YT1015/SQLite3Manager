//
//  SQLiteManager.m
//  SQLite_001
//
//  Created by 杨彤 on 2018/12/12.
//  Copyright © 2018年 JJXT. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>
#import <objc/runtime.h>
static SQLiteManager *dataBase=nil;
static sqlite3 *sqlite;

@interface SQLiteManager ()
@property (nonatomic,strong) NSMutableArray *properArr;
@end

@implementation SQLiteManager

#pragma mark 懒加载
- (NSMutableArray *)properArr{
    if (!_properArr) {
        _properArr =[[NSMutableArray alloc] initWithCapacity:1];
    }
    return _properArr;
}
+ (SQLiteManager *)sharedDatabaseManger{
    
    static dispatch_once_t  onceToenk;
    
    dispatch_once(&onceToenk, ^{
        
        dataBase=[[self alloc] init];
       
        
    });
    //打开数据库
    NSString *documentPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *dataBasePath=[documentPath stringByAppendingString:@"dataBase.sqlite"];
    
    NSLog(@"%@",dataBasePath);
    
    if (sqlite3_open(dataBasePath.UTF8String, &sqlite) == SQLITE_OK) {
        
        NSLog(@"打开成功");
        
    }else{
        
        NSLog(@"打开失败");
        sqlite3_close(sqlite);//关闭数据库
        
    }
    
    return dataBase;
}
//判断该表是否存在
- (BOOL)isHaveThisTableWith:(NSString *)tableName{
//
    NSString *sqliteStr = [NSString stringWithFormat:@"select count(*) from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    char *error = NULL;
    int res = sqlite3_exec(sqlite, sqliteStr.UTF8String, nil, nil,&error);
    
    if (   res >0) {
        
        NSLog(@"已拥有");
        return YES;
        
    }else{
        
         NSLog(@"未拥有");
        return NO;
        
    }
    
}
//获取该类的所有属性
- (NSArray *)objc_propertiseWith:(NSString *)className{
    [self.properArr removeAllObjects];
    Class cls=NSClassFromString(className);
    
    unsigned int count ;
    
    objc_property_t *propertises= class_copyPropertyList(cls, &count);
//                    Ivar *ivas =    class_copyIvarList(cls, &count);成员变量 包过属性 和私有变量
    for (int i=0; i<count; i++) {
        
        objc_property_t properName = propertises[i];
        
        //获取属性的名字
        
        [self.properArr addObject:[NSString stringWithUTF8String:property_getName(properName)]];
        
    }
    
    return self.properArr;
}
//建表
- (BOOL)createTableWith:(Class )clas{
    
    NSArray *propers=[self objc_propertiseWith:NSStringFromClass(clas)];
    
    if (propers.count<=0) {
        return NO;
    }
    
    NSMutableString *sql =[NSMutableString stringWithFormat:@"create table if not exists '%@'(",NSStringFromClass(clas)];
    
    for (int i=0; i<propers.count; i++) {
        
        if (i==propers.count-1) {
            
            [sql appendFormat:@"%@ text)",propers[i]];
            
        }else{
            
            [sql appendFormat:@"%@ text,",propers[i]];
            
        }
        
    }
  
    NSLog(@"%@",sql);
    
    if (sqlite3_exec(sqlite, sql.UTF8String, nil, nil, NULL) == SQLITE_OK) {
        NSLog(@"建表成功");
        return YES;
    }else{
          NSLog(@"建表失败");
        
    }
    
    return NO;
    
}

//insert
- (void)sqliteInsertWith:(id)objc{
    //判断该表是否存在  当数据库创建的时候，系统会自动创建一个表（sqlite_master）,保存我们创建的表的信息
    if ([self isHaveThisTableWith:NSStringFromClass([objc class])]) {
        NSLog(@"已用该表");
    }else{//创建p表
        if (![self createTableWith:[objc class]]) {
            return;
        }
    }
    NSArray *propersNameArr=[self objc_propertiseWith:NSStringFromClass([objc class])];
    
    NSMutableString *sqlKey = [NSMutableString stringWithFormat:@"insert into '%@'(",NSStringFromClass([objc class])];
    
    NSMutableString *sqlvalue = [NSMutableString stringWithFormat:@" values("];
    
    
    for (int i=0; i<propersNameArr.count; i++) {
        
        if (i==propersNameArr.count-1) {
            [sqlKey appendFormat:@"%@)",propersNameArr[i]];
            [sqlvalue appendFormat:@"'%@')",[objc valueForKey:propersNameArr[i]]];
        }else{
             [sqlKey appendFormat:@"%@,",propersNameArr[i]];
            [sqlvalue appendFormat:@"'%@',",[objc valueForKey:propersNameArr[i]]];
        }
        
    }
    
    NSString *str = [sqlKey stringByAppendingString:sqlvalue];
    
    NSLog(@"插入语句%@",str);
    
    char *error=NULL;
    
    
    if ( sqlite3_exec(sqlite, str.UTF8String, nil, nil, &error) == SQLITE_OK) {
        
        NSLog(@"插入数据成功");
    }else{
         NSLog(@"插入数据失败");
         NSLog(@"%s",error);
    }
    // 数据库关闭
    sqlite3_close(sqlite);
    
    
}
- (void)sqliteDeleteWith:(NSString *)keyName
                andValue:(NSString *)value
            andTableName:(id)tableName{
    if (keyName==nil && value ==nil) {
        
        NSLog(@"请输入要删除数据的标识");
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@='%@'",NSStringFromClass([tableName class]),keyName,value];
    
    if (sqlite3_exec(sqlite, sql.UTF8String, nil, nil, NULL) == SQLITE_OK) {
        
        NSLog(@"删除数据成功");
        
    }else{
        NSLog(@"删除数据失败");
        
    }
    // 数据库关闭
    sqlite3_close(sqlite);
}
- (void)sqliteDeleteAllDataWithTableName:(id)objc{
    //删除该表的所有数据
    NSString *sql = [NSString stringWithFormat:@"delete from '%@'",NSStringFromClass([objc class])];
    
    if (sqlite3_exec(sqlite, sql.UTF8String, nil, nil, NULL) == SQLITE_OK) {
        
        NSLog(@"删除所有数据成功");
        
    }else{
        NSLog(@"删除所有数据失败");
        
    }
    // 数据库关闭
    sqlite3_close(sqlite);
}
//修改表中某条数据
- (void)sqliteUpdataWith:(NSString *)keyName
                andValue:(NSString *)value
             andObjcName:(id)objc{
   
    NSString *tableName = NSStringFromClass([objc class]);
    
    NSMutableString *sqlStr=[NSMutableString stringWithFormat:@"update %@ set ",tableName];
    
    NSArray *arr =[self objc_propertiseWith:tableName];
    
    for (int i=0; i<arr.count; i++) {
        
        if (i==arr.count-1) {
           
            if ([keyName isEqualToString:arr[i]]) {//如果是最后一个 删掉“,”号 
                [sqlStr deleteCharactersInRange:NSMakeRange(sqlStr.length-1, 1)];
                [sqlStr appendFormat:@" where %@='%@'",keyName,value];
            }else{
                [sqlStr appendFormat:@"%@='%@' where %@='%@'",arr[i],[objc valueForKey:arr[i]],keyName,value];
            }
            
        }else{
            if ([keyName isEqualToString:arr[i]]) {
                continue;
            }
            [sqlStr appendFormat:@"%@='%@',",arr[i],[objc valueForKey:arr[i]]];
        }
        
        
    }
    
    NSLog(@"更新语句%@",sqlStr);
    
    if (sqlite3_exec(sqlite, sqlStr.UTF8String, nil, nil, NULL) == SQLITE_OK) {
        NSLog(@"修改成功");
    }else{
        NSLog(@"修改失败");
    }
    // 数据库关闭
    sqlite3_close(sqlite);
    
}
//单条件查询
- (NSArray *)sqliteSelectDataWith:(NSString *)keyName
                         andValue:(NSString *)value
                     andTableName:(NSString *)tableName{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *sql= [NSString stringWithFormat:@"select *from %@ where %@='%@'",tableName,keyName,value];
    
    sqlite3_stmt *stmt=NULL;
    
   int result = sqlite3_prepare_v2(sqlite, sql.UTF8String, -1, &stmt, NULL);
    
    int count = sqlite3_column_count(stmt);
    Class cls=NSClassFromString(tableName);
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id objc = [[cls alloc] init];
            for (int i=0; i<count; i++) {
                
                NSString *key=[NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
                
                NSString *valueStr=[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)];
                
                [objc setValue:valueStr forKey:key];
                
            }
            
            [arr addObject:objc];
        }
        
        
    }else{
        NSLog(@"查询失败");
    }
    sqlite3_finalize(stmt);
    // 数据库关闭
    sqlite3_close(sqlite);
    return arr;
}

- (NSArray *)sqliteLikeSelectWith:(NSString *)keyName
                         andValue:(NSString *)value
                     andTableName:(NSString *)tableName{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *sql= [NSString stringWithFormat:@"select *from %@ where %@ like '%%%@%%'",tableName,keyName,value];
    
    sqlite3_stmt *stmt=NULL;
    
    int result = sqlite3_prepare_v2(sqlite, sql.UTF8String, -1, &stmt, NULL);
    
    int count = sqlite3_column_count(stmt);
    Class cls=NSClassFromString(tableName);
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            id objc = [[cls alloc] init];
            for (int i=0; i<count; i++) {
                
                NSString *key=[NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
                
                NSString *valueStr=[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)];
                
                [objc setValue:valueStr forKey:key];
                
            }
            
            [arr addObject:objc];
        }
        
        
    }else{
        NSLog(@"查询失败");
    }
    
    sqlite3_finalize(stmt);
    // 数据库关闭
    sqlite3_close(sqlite);
    return arr;
}

@end
