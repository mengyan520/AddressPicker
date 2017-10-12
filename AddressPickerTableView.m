//
//  AddressPickerTableView.m
//  Fresh
//
//  Created by Youcai on 2017/7/5.
//  Copyright © 2017年 shequcun. All rights reserved.
//

#import "AddressPickerTableView.h"
#import "PickerCell.h"
@interface AddressPickerTableView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *dataArray;

@end
@implementation AddressPickerTableView
- (void)setPid:(NSString *)pid {
    _pid = pid;
    
    [self fetchCityList];
}
- (void)setIndex:(NSInteger)index {
    
    _index = index;
    
}
#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.tableFooterView = [[UIView alloc]init];
        
    }
    return self;
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CELL";
    PickerCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[PickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    RegionInfo *info = _dataArray[indexPath.row];
    cell.textLabel.font = FONT(14);
    cell.textLabel.text = info.name;
    cell.textLabel.highlightedTextColor = RGB_COLOR(242, 36, 36);
    cell.textLabel.textColor = BLACK_COLOR;
    
    if (info.rid == self.index) {
        
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if (!self.isLast) {
            [self tableView:self didSelectRowAtIndexPath:indexPath];
            
        }
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.del respondsToSelector:@selector(didSelectItemAtView:name:pid:index:isleaf:)]) {
        RegionInfo *info = _dataArray[indexPath.row];
        
        [self.del didSelectItemAtView:self name:info.name pid:[NSString stringWithFormat:@"%zd",info.rid] index:info.rid  isleaf:info.isleaf];
    }
    
}

#pragma mark - fetchCityList

- (void)fetchCityList {
    [[NetWorkingTools shardTools]regionListWithPid:self.pid finished:^(id result, NSError *error) {
        if (result) {
            Regions *region = [Regions mj_objectWithKeyValues:result];
            self.dataArray = region.regions;
            [self reloadData];
            if (self.index == 0) {
                
                [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                
            }else {
                for (int i = 0; i<self.dataArray.count; i++) {
                    RegionInfo *info = _dataArray[i];
                    if (self.index == info.rid) {
                        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    }
                }
            }
        }
        
    }];
}
@end
