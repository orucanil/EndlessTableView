//
//  ViewController.m
//  EndlessTableViewDemo
//
//  Created by Anil Oruc on 4/4/16.
//  Copyright © 2016 Anil Oruc. All rights reserved.
//

#import "ViewController.h"
#import "EndlessTableView.h"
#import "EndlessTableViewCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet EndlessTableView *tableViewProduct;
@property (weak, nonatomic) IBOutlet EndlessTableView *tableViewCampaign;

@property (nonatomic, strong) NSArray *arrayCampaigns;
@property (nonatomic, strong) NSArray *arrayProducts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tableViewProduct registerNib:[UINib nibWithNibName:@"EndlessTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"EndlessTableViewCell"];
    [self.tableViewCampaign registerNib:[UINib nibWithNibName:@"EndlessTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"EndlessTableViewCell"];
    
    self.arrayCampaigns = @[[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor]];
    self.arrayProducts = @[[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor],[self randomColor]];
    
    if (self.arrayCampaigns.count > 2 && self.arrayProducts.count > 2) {
        self.tableViewProduct.attachedTableView = self.tableViewCampaign;
        self.tableViewProduct.enableAutoScrolling = YES;
        self.tableViewProduct.differenceRateValue = 1.3f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

#pragma mark - Setters

-(void)setArrayProducts:(NSArray *)arrayProducts
{
    _arrayProducts = [arrayProducts copy];
    
    [_tableViewProduct reloadData];
}

-(void)setArrayCampaigns:(NSArray *)arrayCampaigns
{
    _arrayCampaigns = [arrayCampaigns copy];
    
    [_tableViewCampaign reloadData];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (tableView == _tableViewCampaign)
        numberOfRows = _arrayCampaigns.count;
    else if (tableView == _tableViewProduct)
        numberOfRows = _arrayProducts.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EndlessTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"EndlessTableViewCell"];
    
    if(cell == nil)
    {
        cell = [[EndlessTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EndlessTableViewCell"];
    }
    
    cell.bgColor = (tableView == _tableViewCampaign ? _arrayCampaigns[indexPath.row] : _arrayProducts[indexPath.row]);
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableViewCampaign)
    {
        
    }
    else
    {
        
    }
}


@end
