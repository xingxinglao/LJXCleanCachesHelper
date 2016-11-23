//
//  ViewController.m
//  clean
//
//  Created by 劳景醒 on 16/11/22.
//  Copyright © 2016年 laojingxing. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "LJXCleanCachesHelper.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *_cachesString;
}
@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self _initSubViews];
}

- (void)_initSubViews
{
    [[NSUserDefaults standardUserDefaults] setObject:@"劳景醒" forKey:@"laojingxing"];
    // 这个是AppData文件夹，下面的三个文件夹都在这个里面
    NSString *homePath = NSHomeDirectory();
    NSLog(@"homePath:%@",homePath);
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"docPath:%@",docPath);
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"cachesPath:%@",cachesPath);
    
    NSString *tmpPath = NSTemporaryDirectory();
    NSLog(@"tmpDir:%@",NSTemporaryDirectory());
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/large/abb64acagw1fa22m698pyj20q20smqv5.jpg"]];
    self.tableView.tableFooterView = self.imageView;
    
    //    [LJXCleanCachesHelper getCachesSize:^(NSString *cacheSize) {
    //        NSLog(@"删除前%@", cacheSize);
    //    }];
    //
    //    [LJXCleanCachesHelper cleanCaches:^(BOOL isSuccess) {
    //
    //        [LJXCleanCachesHelper getCachesSize:^(NSString *cacheSize) {
    //            NSLog(@"删除后%@", cacheSize);
    //        }];
    //    }];
    
    // 删除指定这个文件夹下面的文件
    //    NSString *SDImagePath = [cachesPath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    //    [LJXCleanCachesHelper cleanCachesAtPath:SDImagePath completeBlock:^(BOOL isSuccess) {
    //        if (isSuccess) {
    //            NSLog(@"删除成功");
    //        } else {
    //            NSLog(@"删除失败");
    //        }
    //    }];
    
    // 少于200M的时候提醒
    if ([LJXCleanCachesHelper remindCleanCache:(200*1000*1000)]) {
        NSLog(@"该清除空间了");
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"正在计算...";
        [LJXCleanCachesHelper getCachesSize:^(NSString *cacheSize) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@M", cacheSize];
            _cachesString = cacheSize;
        }];
    } else {
        cell.textLabel.text = @"";
    }
  
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertController *alerContrl = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否清除%@M缓存", _cachesString] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cleanAction = [UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 这里可以加一个正在删除的菊花转转
        [LJXCleanCachesHelper cleanCaches:^(BOOL isSuccess) {
            if (isSuccess) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    
    [alerContrl addAction:cancleAction];
    [alerContrl addAction:cleanAction];
    [self presentViewController:alerContrl animated:YES completion:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated..
}


@end
