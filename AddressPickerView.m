//
//  AddressPickerView.m
//  Fresh
//
//  Created by Youcai on 2017/7/5.
//  Copyright © 2017年 shequcun. All rights reserved.
//

#import "AddressPickerView.h"
#import "AddressPickerTableView.h"
#define IPHONE6_SIZE SCREEN_WIDTH/375
@interface AddressPickerView ()<UIScrollViewDelegate,AddressPickerTableViewDelegate>
@property (nonatomic, copy)PickerBlk blk;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *showView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *redLineView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy  ) NSString   *cityName;
@property (nonatomic, strong) NSArray *tableArray;
@property (nonatomic, strong) NSArray *rpath;
@property (nonatomic, strong) NSMutableArray *rpathM;
@property (nonatomic, assign) BOOL isAnimation;//是否滚动动画;
@property (nonatomic, strong) NSMutableArray *lblArray;
@end
@implementation AddressPickerView
#pragma mark - instance
+ (instancetype)instance
{
    
    static AddressPickerView *view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        view = [[self alloc]initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, SCREEN_HEIGHT-200)];
        
    });
    return view;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = WHITE_COLOR;
        self.lblArray = [NSMutableArray array];
    }
    return self;
}
#pragma mark - setUI
- (void)showInView:(UIView *)view rpath:(NSArray *)rpath level:(NSInteger)level blk:(PickerBlk)blk{
    self.level = level;
    self.hidden = NO;
    _blk = blk;
    self.showView = view;
    self.top = SCREEN_HEIGHT;
    self.rpath = rpath;
    [self setUI];
    [self initBaseSettings];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        view.layer.transform = [self Transform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            view.transform = CGAffineTransformMakeScale(0.90, 0.95);
            self.top = 200;
            
        }];
        
    }];
    
    
}
- (void)initBaseSettings {
    self.rpathM = [NSMutableArray array];
    
    for (AddressPickerTableView *talbeView in self.scrollView.subviews) {
        talbeView.index = 0;
    }
    if (self.lblArray.count == 0) {
        for (int i = 0; i<self.level-1; i++) {
            UILabel *lbl =  [[UILabel alloc] init];
            lbl.font = [UIFont systemFontOfSize:15];
            lbl.textAlignment = NSTextAlignmentCenter;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectLabelTapClick:)];
            [lbl addGestureRecognizer:tap];
            lbl.hidden = YES;
            lbl.userInteractionEnabled = YES;
            lbl.tag = 200 + i;
            lbl.text = nil;
            [self addSubview:lbl];
            [self.lblArray addObject:lbl];
        }
    }else {
        for (UILabel *lbl in self.lblArray) {
            lbl.text = nil;
            [self addSubview:lbl];
        }
    }
    self.isAnimation = YES;
    if (self.rpath) {
        
        self.isAnimation = NO;
        for (int i = 0; i<self.rpath.count; i++) {
            
            AddressPickerTableView *tableView = self.tableArray[i];
            tableView.index = [self.rpath[i] integerValue];
            tableView.isLast = NO;
            
            if (i == self.rpath.count - 1) {
                tableView.isLast = YES;
            }
            
        }
        
    }
    ((AddressPickerTableView *)self.tableArray[0]).pid = @"0";
    
}
- (void)setUI {
    [APPDELEGATE window] .backgroundColor = BLACK_COLOR;
    [[APPDELEGATE window] addSubview:self];
    [[APPDELEGATE window] insertSubview:self.backView belowSubview:self];
    self.selectLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), 75, 30 *IPHONE6_SIZE);
    self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,0);
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeBtn];
    [self addSubview:self.selectLabel];
    [self addSubview:self.lineView];
    [self addSubview:self.redLineView];
    [self addSubview:self.scrollView];
    if (self.scrollView.subviews.count ==  0) {
        
        
        for (int i = 0; i<self.level; i++) {
            AddressPickerTableView *tableView = [[AddressPickerTableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH *i, 0, SCREEN_WIDTH, self.scrollView.frame.size.height)];
            tableView.del = self;
            tableView.tag = 100 + i;
            tableView.index = 0;
            tableView.hidden = YES;
            if (i == 0) {
                tableView.hidden = NO;
                
            }
            [self.scrollView addSubview:tableView];
        }
        self.tableArray = self.scrollView.subviews;
        
    }
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    for (AddressPickerTableView *tableView in self.tableArray) {
        tableView.isLast = YES;
    }
    CGFloat OffsetX = scrollView.contentOffset.x /SCREEN_WIDTH;
    if (OffsetX == 0) {
        UILabel *provinceLabel = self.lblArray.firstObject;
        [UIView animateWithDuration:0.5f animations:^{
            
            self.redLineView.frame = CGRectMake(15, CGRectGetMaxY(self.selectLabel.frame), [provinceLabel.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 1);
            
        }];
        
    }else if (OffsetX > 0 && OffsetX < self.tableArray.count-1) {
        UILabel *cityLabel = self.lblArray[(NSInteger)OffsetX];
        UILabel *lastlbl = self.lblArray[cityLabel.tag-200 - 1];
        if (cityLabel.text) {
            
            
            [UIView animateWithDuration:0.5f animations:^{
                
                self.redLineView.frame = CGRectMake(CGRectGetMaxX(lastlbl.frame) +15, CGRectGetMaxY(self.selectLabel.frame), [cityLabel.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 1);
            }];
        }else{
            
            [UIView animateWithDuration:0.5f animations:^{
                
                self.redLineView.frame = CGRectMake(CGRectGetMaxX(lastlbl.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
            }];
        }
    }else {
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
        }];
    }
    
}

#pragma mark - AddressPickerTableViewDelegate

- (void)didSelectItemAtView:(AddressPickerTableView *)view name:(NSString *)name pid:(NSString *)pid index:(NSInteger)index isleaf:(BOOL)isleaf {
    
    if (view.tag == 100) {
        
        self.rpathM = [NSMutableArray array];
        
    }
    
    self.rpathM[view.tag-100] = pid;
    
    if (view.tag == 100) {
        view.index = index;
        UILabel *provinceLabel = self.lblArray.firstObject;
        UILabel *nextlbl = self.lblArray[provinceLabel.tag-200 + 1];
        provinceLabel.hidden = NO;
        if ([provinceLabel.text isEqualToString:name]) {
            
        }else {
            
            for (UILabel *lbl in self.lblArray) {
                if (lbl.tag > 200) {
                    lbl.text = nil;
                    lbl.hidden = YES;
                }
            }
        }
        provinceLabel.frame = CGRectMake(0, 55 *IPHONE6_SIZE, 30 + [name ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 30 *IPHONE6_SIZE);
        
        
        for (AddressPickerTableView *tableView in self.tableArray) {
            if (tableView.tag > 101) {
                tableView.hidden = YES;
            }else if (tableView.tag == 101) {
                tableView.hidden = NO;
                tableView.pid = pid;
            }
        }
        if (!self.isAnimation) {
            provinceLabel.text = name;
            self.selectLabel.frame = CGRectMake(CGRectGetMaxX(provinceLabel.frame), CGRectGetMaxY(self.titleLabel.frame), 75, 30 *IPHONE6_SIZE);
            
            self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
            
            
            
        }else {
            
            if ([provinceLabel.text isEqualToString:name]) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.redLineView.frame = CGRectMake(CGRectGetMaxX(provinceLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), nextlbl.text != nil ? [nextlbl.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH]:[self.selectLabel.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 1);
                }];
            }else {
                
                if (provinceLabel.text) {
                    provinceLabel.text = name;
                }
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.selectLabel.frame = CGRectMake(CGRectGetMaxX(provinceLabel.frame), CGRectGetMaxY(self.titleLabel.frame), 75, 30 *IPHONE6_SIZE);
                    self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
                } completion:^(BOOL finished) {
                    provinceLabel.text = name;
                    
                }];
            }
        }
        
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *2,0);
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:self.isAnimation == YES ? YES:NO];
        
    }else if (view.tag > 100 && view.tag < (self.tableArray.count-1 + 100)) {
        UILabel *cityLabel = self.lblArray[view.tag-100];
        UILabel *lastlbl = self.lblArray[cityLabel.tag-200 - 1];
        if (isleaf) {
            [self block:name];
        }else {
            
            
            cityLabel.hidden = NO;
            cityLabel.frame = CGRectMake(CGRectGetMaxX(lastlbl.frame), 55 *IPHONE6_SIZE, 30 + [name ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 30 *IPHONE6_SIZE);
            for (AddressPickerTableView *tableView in self.tableArray) {
                if (tableView.tag ==  view.tag) {
                    tableView.index = index;
                    if (tableView.index != [self.rpath[view.tag-100] integerValue]) {
                        AddressPickerTableView *nextView = self.tableArray[view.tag-100 + 1];
                        nextView.index = 0;
                    }
                }else if (tableView.tag == view.tag+1) {
                    tableView.hidden = NO;
                    tableView.pid = pid;
                }
            }
            if (!self.isAnimation) {
                cityLabel.text = name;
                self.selectLabel.frame = CGRectMake(CGRectGetMaxX(cityLabel.frame), CGRectGetMinY(cityLabel.frame), 75, 30 *IPHONE6_SIZE);
                
                self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
                
            }else {
                
                if (cityLabel.text) {
                    cityLabel.text = name;
                }
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.selectLabel.frame = CGRectMake(CGRectGetMaxX(cityLabel.frame), CGRectGetMinY(cityLabel.frame), 75, 30 *IPHONE6_SIZE);
                    self.redLineView.frame = CGRectMake(CGRectGetMinX(self.selectLabel.frame) +15, CGRectGetMaxY(self.selectLabel.frame), 45, 1);
                } completion:^(BOOL finished) {
                    cityLabel.text = name;
                    
                }];
            }
            self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH *(view.tag-100 + 2), 0);
            [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH *(view.tag-100 + 1), 0) animated:self.isAnimation == YES ? YES:NO];
        }
        //
    }else {
        
        [self block:name];
    }
    self.cityName = name;
    
    if (view.tag-100 == self.rpath.count-2) {
        self.isAnimation = YES;
    }
}
#pragma mark - action
- (void)selectLabelTapClick:(UITapGestureRecognizer *)tap{
    UILabel *lbl = (UILabel *)tap.view;
    for (AddressPickerTableView *tableView in self.tableArray) {
        tableView.isLast = YES;
    }
    if (lbl.tag == 200) {
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.redLineView.frame = CGRectMake(15, CGRectGetMaxY(self.selectLabel.frame), [lbl.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 1);
            
        }];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else {
        UILabel *lastlbl = self.lblArray[lbl.tag-200 - 1];
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.redLineView.frame = CGRectMake(CGRectGetMaxX(lastlbl.frame) +15, CGRectGetMaxY(self.selectLabel.frame), [lbl.text ew_widthWithFont:FONT(15) lineWidth:SCREEN_WIDTH], 1);
        }];
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*(lbl.tag-200), 0) animated:YES];
        
    }
    
}
- (void)block:(NSString *)name {
    
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:self.cityName];
    [temp addObject:name];
    NSString *address = [temp componentsJoinedByString:@" "];
    self.blk(address, self.rpathM);
    [self hideSelf];
    
}
- (void)hideSelf
{
    [UIView animateWithDuration:0.25 animations:^{
        
        
        self.showView.layer.transform = [self Transform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
          self.showView.transform = CGAffineTransformIdentity;
            
            [self.backView removeFromSuperview];
        }];
        [UIView animateWithDuration:0.6 animations:^{
            
            
            self.top = SCREEN_HEIGHT;
        }completion:^(BOOL finished) {
            [APPDELEGATE window] .backgroundColor = WHITE_COLOR;
            
            [self removeAllSubViews];
            [self removeFromSuperview];
            
        }];
    }];
    

}
// 后靠效果
- (CATransform3D)Transform{
    
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    //带点缩小的效果
    t1 = CATransform3DScale(t1, 0.90, 0.95, 1);
    //绕x轴旋转
    t1 = CATransform3DRotate(t1, 10.0 * M_PI/180.0, 1, 0, 0);
    return t1;
}
#pragma mark - Getter
- (UIView  *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.tag = 20000;
        
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
        [_backView addGestureRecognizer:tap];
        
    }
    return  _backView;
}
- (UILabel  *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55 *IPHONE6_SIZE)];
        
        _titleLabel.text = @"所在地区";
        _titleLabel.textColor = RGB_COLOR(142, 143, 148);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _titleLabel;
}
- (UILabel  *)selectLabel {
    if (_selectLabel == nil) {
        _selectLabel =  [[UILabel alloc] init];
        _selectLabel.textColor = RGB_COLOR(242, 36, 36);
        _selectLabel.text = @"请选择";
        _selectLabel.font = [UIFont systemFontOfSize:15.f];
        _selectLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _selectLabel;
}
- (UIView  *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.selectLabel.frame), SCREEN_WIDTH, 1)];
        _lineView.backgroundColor = RGB_COLOR(229, 229, 229);
        
    }
    return  _lineView;
}
- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(hideSelf) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _closeBtn;
}
- (UIView  *)redLineView {
    if (_redLineView == nil) {
        _redLineView = [[UIView alloc] init];
        _redLineView.backgroundColor = RGB_COLOR(242, 36, 36);
        
    }
    return  _redLineView;
}
- (UIScrollView  *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.redLineView.frame), SCREEN_WIDTH, self.frame.size.height - CGRectGetMaxY(self.redLineView.frame))];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return  _scrollView;
}



@end
