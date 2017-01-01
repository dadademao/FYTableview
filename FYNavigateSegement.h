//
//  FYNavigateSegement.h
//  NewACE
//
//  Created by fuyuan on 2016/12/30.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FYNavigateSegementCell;
@protocol FYNavigateSegementDelegate;


@interface FYNavigateSegement : UIView



- (instancetype) initWithFrame:(CGRect)frame andDelegate:(id <FYNavigateSegementDelegate>)delegate;
- (FYNavigateSegementCell *)dequeueWithIdentify:(NSString *)identify;
@property (assign, nonatomic) BOOL isOpenCache;
@end



@protocol FYNavigateSegementDelegate <NSObject>

- (NSInteger) numberOfNavigateSegementCells:(FYNavigateSegement *)segement;

- (FYNavigateSegementCell *)navigateSegementCell:(FYNavigateSegement *)segement atIndex:(NSInteger)index;

- (CGFloat)navigateSegementHeightAtIndex:(NSInteger)index;

- (void)navigateSegementCell:(id)segement didSelectCellAtIndex:(NSInteger)index;


@end
