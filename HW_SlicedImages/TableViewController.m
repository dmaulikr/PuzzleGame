//
//  TableViewController.m
//  HW_SlicedImages
//
//  Created by Gena on 18.02.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "TableViewController.h"
#import "NetManager.h"
#import "DetailViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Game.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface TableViewController () {
    NSArray *titles;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadIfNescessary) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadIfNescessary];
}

- (void)loadFromNet
{
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/ListImages.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [self.tableView reloadData];
        //            self.imagesArray = (NSArray *)responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [operation start];
}

- (void)loadData
{
//    titles = [[Game sharedInstance] getTitlesOfImages];
//    [self.tableView reloadData];
    [self loadFromNet];
    [self.refreshControl endRefreshing];
    if (!titles) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.detailsLabelText = @"Please check internet connection";
        [hud hide:YES afterDelay:1.5];
    }
    [self.tableView reloadData];
}

- (void)reloadIfNescessary
{
    [self.refreshControl beginRefreshing];
//    [self loadData];
    [self loadFromNet];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = titles[indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
//    DetailViewController *detail = segue.destinationViewController;
    [[Game sharedInstance] setupGameWithImageNamed:titles[indexPath.row]];
}


@end
