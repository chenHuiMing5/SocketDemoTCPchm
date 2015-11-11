//
//  SeverViewController.m
//  SocketDemo
//
//  Created by lzxuan on 15/9/20.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "SeverViewController.h"
#import "ClientViewController.h"

#import "AsyncSocket.h"
/*
 TCP协议 的套接字
 Server
 1.导入头文件AsyncSocket.h
 2.打开套接字
 3.绑定端口号 监听 等待接收连接 accept(iOS)<--> （C语言）bind listen accept
 4.等待接收 数据
 
 收发数据
 */

@interface SeverViewController () <UITableViewDataSource,UITableViewDelegate,AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;

//保存服务器的套接字
//套接字就是一个文件
//这个 socket 负责监听客户端的连接 不管收发数据
@property (nonatomic,strong) AsyncSocket *serverSocket;
//保存与客户端通信的套接字
@property (nonatomic,strong) NSMutableArray *socketArr;
@end

@implementation SeverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务端";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"给自己聊天" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick:)];
    self.navigationItem.rightBarButtonItem = item;
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    //创建 套接字
    [self createTcpSocket];
    
}
- (void)itemClick:(UIBarButtonItem *)item {
    ClientViewController *client = [[ClientViewController alloc] init];
    [self.navigationController pushViewController:client animated:YES];
}
#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArr[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
#pragma mark - Tcp套接字
- (void)createTcpSocket {
    
    self.socketArr  = [[NSMutableArray alloc] init];
    
    self.serverSocket = [[AsyncSocket alloc]initWithDelegate:self];
    [self.serverSocket acceptOnPort:8888 error:nil];
    
   
    
    
}
#pragma mark - tcp 代理需要实现的
/*
 当服务器的监听套接字 收到客户端的连接请求的时候调用
 //如果 要服务器同意 建立连接 那么必须要 保存 newSocket newSocket 就是负责与指定客户端通信(收发数据)的套接字,如果不保存 那么就会自动释放掉 连接级断开了
 
 */
//监听的时候 下面的参数sock 就是监听套接字 后面再进行调用的函数就不是了

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{

    NSLog(@"服务端监听到客服端 :%@",newSocket.connectedHost);
    
    [self.socketArr addObject:newSocket];


}




-(BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"服务器将要和客户端连接:%@",sock.connectedHost);
    
    

    return YES;
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{

    NSLog(@"服务器已经 和客户端 连接 :%@",sock.connectedHost);
    
    [sock readDataWithTimeout:-1 tag:201];
    
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
 NSLog(@"服务器将要 和客户端 断开 :%@",sock.connectedHost);
    [self.dataArr removeObject:sock];
    

}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock{

    NSLog(@"服务器已经 和客户端 断开 :%@",sock.connectedHost);

}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"服务器接收到 客服端 的数据 :%@",sock.connectedHost);

    NSString *aw = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.dataArr addObject: aw];
    [self.tableView reloadData];
    
    if (self.dataArr.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    
    NSString *sr = @"即将完成";
    [sock writeData:[sr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60 tag:101];
    
    [sock readDataWithTimeout:-1 tag:301];
    
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{

    NSLog(@"已经接收");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
