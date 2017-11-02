//
//  ViewController.m
//  Json基本使用
//
//  Created by YiGuo on 2017/11/2.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController ()
//视频数组
@property (nonatomic,strong)NSArray *videos;
@end

@implementation ViewController
// 字典转Json字符串
-(NSString *)convertToJsonData:(NSDictionary *)dict
{
//    typedef NS_OPTIONS(NSUInteger, NSJSONWritingOptions) {
//        NSJSONWritingPrettyPrinted = (1UL << 0)
//    } NS_ENUM_AVAILABLE(10_7, 5_0);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
// JSON字符串转化为字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
//    typedef NS_OPTIONS(NSUInteger, NSJSONReadingOptions) {
//        NSJSONReadingMutableContainers = (1UL << 0),//创建出来的数组和字典就是可变
//        NSJSONReadingMutableLeaves = (1UL << 1),//数组或者字典里面的字符串是可变的
//        NSJSONReadingAllowFragments = (1UL << 2)//允许解析出来的对象不是字典或者数组，比如直接是字符串或者NSNumber
//    } NS_ENUM_AVAILABLE(10_7, 5_0);
//     kNilOptions为什么都没有
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败");
        return nil;
    }
    return dic;
}

-(void)jsonToPlist{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gw.ws.126.net/live/previewlist?passport=yLJhSeCB7dRA0xKVMvwC2Q%3D%3D&sign=4e2608504c034f04b86ec3a11fb6035e&version=v3"]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //解释JSON
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //写成plist
        [dict writeToFile:@"/Users/XXX/Desktop/plist/live.plist" atomically:YES];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
    // 字典转Json字符串
    NSDictionary *dict = @{@"num":@10,@"str":@"test"};
    NSString *str = [self convertToJsonData:dict];
    NSLog(@"str:%@",str);
    // JSON字符串转化为字典
    NSLog(@"oc类：%@",[self dictionaryWithJsonString:str]);
     */
    // 0.请求路径
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/video"];
    // 1.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //JSON解释
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        // 获得视频数组
        self.videos = dict[@"videos"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];
    
}
#pragma mark - 数据源方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.videos.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Id = @"video";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    NSDictionary *video = self.videos[indexPath.row];
    cell.textLabel.text = video[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"时长：%@", video[@"length"]];
    NSString *image = [@"http://120.25.226.186:32812" stringByAppendingPathComponent:video[@"image"]];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"icn"]];
    return cell;
}
#pragma mark - 数据源方法end
#pragma mark - 代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *video = self.videos[indexPath.row];
    NSString *urlStr = [@"http://120.25.226.186:32812" stringByAppendingPathComponent:video[@"url"]];
    
    // 创建视频播放器
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:urlStr]];
    
    // 显示视频
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
