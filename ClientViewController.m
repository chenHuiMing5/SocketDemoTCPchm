//
//  ClientViewController.m
//  SocketDemo
//
//  Created by lzxuan on 15/9/20.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ClientViewController.h"
#import "AsyncSocket.h"
/*
 TCP 客户端
 1.导入头文件AsyncSocket.h
 2.打开 套接字
 3.连接服务器
  建立连接  收发数据
 */
@interface ClientViewController () <AsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textFielf;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong )NSMutableArray *dataArr;

@property (nonatomic,strong) AsyncSocket *clientSocket;
@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户端";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendData:)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"连接" style:UIBarButtonItemStylePlain target:self action:@selector(startConnect:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"断开" style:UIBarButtonItemStylePlain target:self action:@selector(stopConnect:)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItems = @[item1,item2,item3];
    //创建套接字
    [self createTcpSocket];
}
- (void)back:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}
//开始连接
- (void)startConnect:(UIBarButtonItem *)item {
    if (self.clientSocket.isConnected  ) {
        return;
        
    }
    [self.clientSocket connectToHost:@"10.8.151.63" onPort:8888 withTimeout:60 error:nil];
    

}
//断开连接
- (void)stopConnect:(UIBarButtonItem *)item {
    if (self.clientSocket.isConnected) {
        [self.clientSocket disconnect];
    }
}
- (void)sendData:(UIBarButtonItem *)item {
    
    if (self.clientSocket.isConnected) {
        [self.clientSocket writeData:[self.textFielf.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60 tag:201];

    }
    
    
}
#pragma mark - TCP
- (void)createTcpSocket {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.clientSocket = [[AsyncSocket alloc]initWithDelegate:self];
    
    
}

#pragma mark - tcp 套接字

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{

    NSLog(@"客户端  发送成功 ");

}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    NSString *aw = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.dataArr addObject: aw];
    [self.tableView reloadData];
    
    if (self.dataArr.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    
    NSString *sr = @"即将完成";
    [sock writeData:[sr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60 tag:101];
    
    [sock readDataWithTimeout:-1 tag:201];



}


-(BOOL)onSocketWillConnect:(AsyncSocket *)sock{

    NSLog(@"客户端将要 连接");
    return YES;
    
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"客户端 已经 和 服务器 连接");

    [sock readDataWithTimeout:-1 tag:101];
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{

    NSLog(@" 客户端 将要 和 服务器 断开");
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"客户端 已经 和 服务器 断开");

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textFielf resignFirstResponder];
}
#pragma mark - tableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}



@end
