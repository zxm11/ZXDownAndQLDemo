//
//  ViewController.m
//  ZXDownAndQLDemo
//
//  Created by Rocent on 2017/6/30.
//  Copyright © 2017年 Rocent. All rights reserved.
//

#import "ViewController.h"
#import "ZXDLAndQLViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)asasasdasa {
    NSArray * dataArr = [NSArray arrayWithObjects:@"http://pic15.nipic.com/20110625/1033143_180920752000_2.jpg",@"http://img.7160.com/uploads/allimg/161109/12-1611091A500.jpg",nil];
    ZXDLAndQLViewController * vc = [[ZXDLAndQLViewController alloc] init];
    vc.downLoadData = dataArr;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
