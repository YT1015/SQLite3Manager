#import "ViewController.h"
#import "model.h"
#import "SQLiteManager.h"
@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    
    
}
- (IBAction)insertAction:(id)sender {
    
    model *m=[[model alloc] init];
    
    m.name=[NSString stringWithFormat:@"小杨%d",arc4random()% 100 +1];
    
    m.age = arc4random() %50+5;
    
    m.height = [NSString stringWithFormat:@"%d",arc4random() %180 +10];
    
    m.sex =(arc4random() % 2) ? @"男" : @"女";
    
    [[SQLiteManager sharedDatabaseManger] sqliteInsertWith:m];
    
}
- (IBAction)deleteAction:(id)sender {
    model *m=[[model alloc] init];
#if 0
    [[SQLiteManager sharedDatabaseManger] sqliteDeleteAllDataWithTableName:m];
#else
    [[SQLiteManager sharedDatabaseManger] sqliteDeleteWith:@"height" andValue:@"162" andTableName:m];
#endif
}
- (IBAction)updataAction:(id)sender {
    
    model *m=[[model alloc] init];
    
    m.name=@"小杨99";
    m.height=@"190";
    m.age=30;
    m.sex=@"太监";
    
    [[SQLiteManager sharedDatabaseManger] sqliteUpdataWith:@"name" andValue:@"小杨99" andObjcName:m];
    
}

- (IBAction)selectAction:(id)sender {
#if 0
    model *m=[[model alloc] init];
    NSArray *arr= [[SQLiteManager sharedDatabaseManger] sqliteSelectDataWith:@"name" andValue:@"小杨99" andTableName:NSStringFromClass([m class])];
    
    
    model *mode=arr[0];
    
    NSLog(@"%@-%ld-%@-%@",mode.name,(long)mode.age,mode.height,mode.sex);
    
#else
    model *m=[[model alloc] init];
    NSArray *arr= [[SQLiteManager sharedDatabaseManger] sqliteLikeSelectWith:@"name" andValue:@"小杨" andTableName:NSStringFromClass([m class])];
    for (int i=0; i<arr.count; i++) {
        model *mode=arr[i];
        NSLog(@"%@-%ld-%@-%@",mode.name,(long)mode.age,mode.height,mode.sex);
    }
    
#endif
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
