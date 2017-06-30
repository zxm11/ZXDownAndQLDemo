//
//  ZXDLAndQLViewController.m
//  ZXDownAndQLDemo
//
//  Created by Rocent on 2017/6/30.
//  Copyright © 2017年 Rocent. All rights reserved.
//

#import "ZXDLAndQLViewController.h"
#import <QuickLook/QuickLook.h>
@interface ZXDLAndQLViewController ()<UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    NSInteger myIndex;
}
@property (strong , nonatomic) UITableView *tableView;

/**  QuickLook预览页面  */
@property(nonatomic,strong)  QLPreviewController  *previewController;


@end

@implementation ZXDLAndQLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createZXDLAndQLViewControllerUI];
    // Do any additional setup after loading the view.
}
- (void)createZXDLAndQLViewControllerUI{
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//返回多少组
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _downLoadData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell的样式可以自己定义
    static NSString * ID = @"ZXDLCellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];//复用
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.text = _downLoadData[indexPath.row];
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * urlStr = _downLoadData[indexPath.row];
    NSArray * arr = [urlStr componentsSeparatedByString:@"/"];
    NSString * nameStr = arr.lastObject;
    NSString * fileLastName = [NSString stringWithFormat:@"/%@",nameStr];
    //写个方法判断是否存在缓存文件,如果已经下载了,则点击的时候呈现预览:
    if ([self readDataFromPlistWithName:fileLastName]){
        self.previewController  =  [[QLPreviewController  alloc]  init];
        /**  这里我们要使用QLPreviewController的代理方法  */
        [self.previewController setCurrentPreviewItemIndex:indexPath.row];
        self.previewController.dataSource  =  self;
        self.previewController.delegate  =  self;
        self.previewController.view.frame  =  [UIScreen mainScreen].bounds;
        myIndex = indexPath.row;
        /** 这里需要注意的是，我们不使用Controller，而是使用Controller的View，为的是避免QLController在Navgation等Controller中带来的坑 */
        [self.view  addSubview:self.previewController.view];
        
    }else{
        [self downloadFileWithPath:urlStr andName:fileLastName];
    }

}

#pragma mark - 从plist文件中读取数据
-(BOOL)readDataFromPlistWithName:(NSString *)name{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:name];
    NSData * data = [[NSData alloc] initWithContentsOfFile:savePath];
    //那怎么证明我的数据写入了呢？读出来看看
    //    NSLog(@"缓存的的文件数据 %@", data);
    if (data){
        return YES;
    }
    return NO;
}

#pragma mark - QLPreviewController代理
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *urlStr = _downLoadData[myIndex];
    NSArray * arr = [urlStr componentsSeparatedByString:@"/"];
    NSString * nameStr = arr.lastObject;
    NSString * fileLastName = [NSString stringWithFormat:@"/%@",nameStr];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:fileLastName];
    return [NSURL fileURLWithPath:savePath];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    NSLog(@"预览界面已经消失");
}

//文件内部链接点击不进行外部跳转
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return NO;
}

- (void)downloadFileWithPath:(NSString *)urlStr andName:(NSString *)name{
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSError *saveError;
            
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
            NSString *savePath = [cachePath stringByAppendingPathComponent:name];
            
            NSURL *saveUrl = [NSURL fileURLWithPath:savePath];
            
            //把下载的内容从cache复制到document下
            
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&saveError];
            
            if (!saveError) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD showSuccess:@"文件下载成功!"];
//                });
                
                NSLog(@"save success");
                
            }else{
                
                NSLog(@"save error:%@",saveError.localizedDescription);
                
            }
            
        }else{
            
            NSLog(@"download error:%@",error.localizedDescription);
            
        }
        
    }];
    
    [downloadTask resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
