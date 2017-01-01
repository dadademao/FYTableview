//
//  FYNavigateSegement.m
//  NewACE
//
//  Created by fuyuan on 2016/12/30.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "FYNavigateSegement.h"
#import "FYNavigateSegementCell.h"
//在显示中，需要增加读取上下两块未显示区域的cell，以保持滚动流畅，以下为区域高度
#define MORECELLDISVISIBELHEIGHT 200
@interface FYNavigateSegement ()<UIScrollViewDelegate> {
    NSInteger _cellNum;
    NSInteger _index;
    CGFloat   _allHeight;
}
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<FYNavigateSegementDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *visibleCells;
@property (strong, nonatomic) NSMutableDictionary *cacheCells;
@property (strong, nonatomic) NSMutableArray *cellFrames;
@end

@implementation FYNavigateSegement

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame andDelegate:(id <FYNavigateSegementDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.delegate  =  delegate;
        
    }
    
    return self;
}


- (NSMutableDictionary *)visibleCells {
    if (!_visibleCells) {
        _visibleCells = [[NSMutableDictionary alloc] init];
    }
    return _visibleCells;
}

- (NSMutableDictionary *)cacheCells {
    if (!_cacheCells) {
        _cacheCells = [[NSMutableDictionary alloc] init];
    }
    return _cacheCells;
}

- (NSMutableArray *)cellFrames {
    if (!_cellFrames) {
        _cellFrames = [[NSMutableArray alloc] init];
    }
    return _cellFrames;
}

- (void) setupSubviews {
    
    _isOpenCache = YES;
    _cellNum = 0;
    _allHeight = 0;
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:scrollview];
    self.scrollView = scrollview;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(0, self.height);
    
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
}


- (void)reloadData {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfNavigateSegementCells:)]) {
        _cellNum = [self.delegate numberOfNavigateSegementCells:self];
    }
    if (_cellNum == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigateSegementHeightAtIndex:)]) {
        _allHeight = 0;
        for (NSInteger i = 0; i < _cellNum; i++) {
            CGFloat cellheight = [self.delegate navigateSegementHeightAtIndex:i];
            CGRect cellRect = CGRectMake(0, _allHeight, self.frame.size.width, cellheight);
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigateSegementCell:atIndex:)]) {
                FYNavigateSegementCell *cell = [self.delegate navigateSegementCell:self atIndex:i];
                if (!cell) {
                    @throw @"NavigateSegementCell cant be nil";
                }
                cell.frame = cellRect;
                [self.scrollView addSubview:cell];
            }
            
            
            [self.cellFrames addObject:NSStringFromCGRect(cellRect)];
            
            
            _allHeight += cellheight;
            
        }
    }
    if (_allHeight > self.height) {
        self.scrollView.contentSize = CGSizeMake(0, _allHeight);
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_isOpenCache) {
        return;
    }
    
    [self loadMoreRectCell];
    
}


- (FYNavigateSegementCell *)dequeueWithIdentify:(NSString *)identify {
    return _cacheCells[identify];
}

- (void)loadVisibleCell {
    CGRect rect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.width, self.scrollView.height);
    NSInteger index = 0;
    for (NSString *rectStr in self.visibleCells) {
        FYNavigateSegementCell *cell = self.visibleCells[rectStr];
        [cell removeFromSuperview];
        if (cell.identify) {
            [self.cacheCells setObject:cell forKey:cell.identify];
        }
    }
    [self.visibleCells removeAllObjects];
    for (NSString *rectStr in self.cellFrames) {
        CGRect cellRect = CGRectFromString(rectStr);
        BOOL isContain = CGRectContainsRect(rect, cellRect);
        if (isContain) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigateSegementCell:atIndex:)]) {
                FYNavigateSegementCell *cell = [self.delegate navigateSegementCell:self atIndex:index];
                cell.frame = cellRect;
                [self.scrollView addSubview:cell];
                [self.visibleCells setObject:cell forKey:rectStr];
             
            }
          
        }
        index++;
    }
    [self loadMoreRectCell];
}


//显示scrollview上下多一块区域内容，来保证滚动流畅
- (void)loadMoreRectCell {
    CGRect rect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - MORECELLDISVISIBELHEIGHT, self.scrollView.width, self.scrollView.height + MORECELLDISVISIBELHEIGHT);
    NSMutableArray *shouldRemoveCell = [NSMutableArray array];
    for (NSString *rectStr in self.visibleCells) {
        BOOL isContain = CGRectContainsRect(rect, CGRectFromString(rectStr));
        if (!isContain) {
            FYNavigateSegementCell *cell = self.visibleCells[rectStr];
            [cell removeFromSuperview];
            [shouldRemoveCell addObject:rectStr];
            if (cell.identify) {
                [self.cacheCells setObject:cell forKey:cell.identify];
            }
        }
        
    }
    [self.visibleCells removeObjectsForKeys:shouldRemoveCell];

    NSInteger index = 0;
    for (NSString *rectStr in self.cellFrames) {
        CGRect cellRect = CGRectFromString(rectStr);
        BOOL isContain = CGRectContainsRect(rect, cellRect);
        if (isContain) {
            if (![self.visibleCells objectForKey:rectStr]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(navigateSegementCell:atIndex:)]) {
                    FYNavigateSegementCell *cell = [self.delegate navigateSegementCell:self atIndex:index];
                    cell.frame = cellRect;
                    [self.scrollView addSubview:cell];
                    [self.visibleCells setObject:cell forKey:rectStr];
                 
                }
            }
        
        }
        index++;
    }
    
}



@end
