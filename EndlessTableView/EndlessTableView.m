//
//  EndlessTableView.m
//  OmsaTech
//
//  Created by Anıl Oruç on 06/05/14.
//  Copyright (c) 2014 OmsaTech. All rights reserved.
//

#import "EndlessTableView.h"
#import <objc/runtime.h>

#define AUTO_SCROLLING_DEFAULT_VALUE 1.0f
#define DIFFERENCE_SCROLL_DEFAULT_VALUE 1.0f

@interface NSTimer (BlocksSupport)

+ (NSTimer*)autoScrolling_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats;
@end

@implementation NSTimer (BlocksSupport)

+ (NSTimer*)autoScrolling_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats
{
    
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(autoScrolling_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)autoScrolling_blockInvoke:(NSTimer*)timer {
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end

@interface EndlessTableViewDelegate : NSObject

@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id middleMan;

@end

@implementation EndlessTableViewDelegate

- (id) forwardingTargetForSelector:(SEL)aSelector {
    
	if ([_middleMan respondsToSelector:aSelector])
		return _middleMan;
	
	if ([_receiver respondsToSelector:aSelector])
		return _receiver;
	
	return	[super forwardingTargetForSelector:aSelector];
	
}

- (BOOL) respondsToSelector:(SEL)aSelector {
    
    BOOL autoScrollingMethodControl = (sel_isEqual(aSelector, @selector(scrollViewDidEndDragging:willDecelerate:)) || sel_isEqual(aSelector, @selector(scrollViewWillBeginDragging:)) || sel_isEqual(aSelector, @selector(scrollViewDidEndDecelerating:)) || sel_isEqual(aSelector, @selector(scrollViewWillBeginDecelerating:)) || sel_isEqual(aSelector, @selector(scrollViewDidScroll:)));
    
    if (autoScrollingMethodControl) {
        if ([_middleMan respondsToSelector:aSelector])
            return YES;
    }
	
	if ([_receiver respondsToSelector:aSelector])
		return YES;
	
	return [super respondsToSelector:aSelector];
	
}

@end

@interface EndlessTableView ()

@property (nonatomic,strong) EndlessTableViewDelegate *dataSourceEndless,*delegateEndless;
@property (nonatomic) NSInteger totalRows,totalCellsVisible;
@property (nonatomic) CGFloat lastContentOffsetY;
@property (nonatomic,strong) NSTimer* timerAutoScrolling;
@property (nonatomic,readonly) BOOL isScrolling;

@end

@implementation EndlessTableView

#pragma mark Initialization
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self customIntitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if( self )
    {
        [self customIntitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self customIntitialization];
    }
    return self;
}

-(void)dealloc
{
    [self stopAutoScrolling];
}

- (void)customIntitialization
{
    _enableEndlessScrolling = YES;
    _autoScrollValue = 0.0f;
    _differenceRateValue = DIFFERENCE_SCROLL_DEFAULT_VALUE;
}

- (NSIndexPath*)editIndexPathForIndexPath:(NSIndexPath*)oldIndexPath totalRows:(NSInteger)totalRows
{
    return _enableEndlessScrolling ? [NSIndexPath indexPathForRow:oldIndexPath.row % totalRows inSection:oldIndexPath.section] : oldIndexPath;
}

- (void)resetContentOffsetIfNeeded
{
    if( !_enableEndlessScrolling )
        return;
    
    NSArray *indexpaths = [self indexPathsForVisibleRows];
    int totalVisibleCells = [indexpaths count];
    if( _totalCellsVisible > totalVisibleCells )
    {
        //we dont have enough content to generate scroll
        return;
    }
    CGPoint contentOffset  = self.contentOffset;
    BOOL control = NO;
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    if( contentOffset.y <= 0.0 )
    {
        control = YES;
        contentOffset.y = self.contentSize.height/3.0f;
    }
    else if( contentOffset.y >= ( self.contentSize.height - self.bounds.size.height) )//scrollview content offset reached bottom minus the height of the tableview
    {
        control = YES;
        //this scenario is same as the data repeating for 2nd time minus the height of the table view
        contentOffset.y = self.contentSize.height/3.0f- self.bounds.size.height;
    }
    
    if (control) {
        /*
        [_attachedTableView stopAutoScrolling];
        [self stopAutoScrolling];
         */
        _lastContentOffsetY = contentOffset.y;
        [self setContentOffset:contentOffset];
        /*
        if (_attachedTableView.enableAutoScrolling) {
            [_attachedTableView startAutoScrollingWithDelay:NO];
        }
        else if(self.enableAutoScrolling){
            [self startAutoScrollingWithDelay:NO];
        }
         */
    }
}

-(void)startAutoScrollingWithDelay:(BOOL)isDelay
{
    double delayInSeconds = (isDelay ? 0.15f : 0.0f);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!_timerAutoScrolling)
        {
            __weak id weakSelf = self;
            _timerAutoScrolling = [NSTimer autoScrolling_scheduledTimerWithTimeInterval:0.05 block:^{
                EndlessTableView * strongSelf = weakSelf;
                [strongSelf autoScrollingAction];
            } repeats:YES];
            
            [[NSRunLoop mainRunLoop] addTimer:_timerAutoScrolling forMode:UITrackingRunLoopMode];
        }
    });
}

-(void)stopAutoScrolling
{
    //[self.layer removeAllAnimations];
    [_timerAutoScrolling invalidate];
    _timerAutoScrolling = nil;
}

-(void)autoScrollingAction
{
    [UIView animateWithDuration:0.05 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + (_autoScrollValue <= 0.0f ? AUTO_SCROLLING_DEFAULT_VALUE : _autoScrollValue))];
        
    } completion:nil];
    
}

#pragma mark Layout

- (void)layoutSubviews
{
    _totalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
    [super layoutSubviews];
}

#pragma mark Setter/Getter

-(void)reloadData{
    [super reloadData];
    if (_enableAutoScrolling) {
        [self startAutoScrollingWithDelay:YES];
    }
}

-(void)setDifferenceRateValue:(CGFloat)differenceRateValue
{
    _differenceRateValue = differenceRateValue;
    if(_attachedTableView) {
        [_attachedTableView setPrivateDifferenceRateValue:1/_differenceRateValue];
        [_attachedTableView reloadData];
    }
}


-(void)setPrivateDifferenceRateValue:(CGFloat)differenceRateValue
{
    _differenceRateValue = differenceRateValue;
    
}

-(void)setEnableEndlessScrolling:(BOOL)enableEndlessScrolling
{
    _enableEndlessScrolling = enableEndlessScrolling;
    
    [self reloadData];
}

-(void)setEnableAutoScrolling:(BOOL)enableAutoScrolling
{
    _enableAutoScrolling = enableAutoScrolling;
    
    if (_enableAutoScrolling) {
        [self startAutoScrollingWithDelay:YES];
    }
    else {
        [self stopAutoScrolling];
    }
}

-(void)setAttachedTableView:(EndlessTableView *)attachedTableView
{
    _attachedTableView = attachedTableView;
    [_attachedTableView setPrivateAttachedTableView:self];
}

-(void)setPrivateAttachedTableView:(EndlessTableView *)attachedTableView
{
    _attachedTableView = attachedTableView;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    if( !_dataSourceEndless)
    {
        _dataSourceEndless = [[EndlessTableViewDelegate alloc] init];
    }
    
    _dataSourceEndless.receiver = dataSource;
    _dataSourceEndless.middleMan = self;
    
    [super setDataSource:(id<UITableViewDataSource>)_dataSourceEndless];
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (delegate == nil) {
        [super setDelegate:delegate];
        return;
    }
    if( !_delegateEndless)
    {
        _delegateEndless = [[EndlessTableViewDelegate alloc] init];
    }
    
    _delegateEndless.receiver = delegate;
    _delegateEndless.middleMan = self;
    
    [super setDelegate:(id<UITableViewDelegate>)_delegateEndless];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
 */

#pragma mark - UIScrollViewDelegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if ([self numberOfRowsInSection:0] > 0 && [_attachedTableView numberOfRowsInSection:0] > 0 && !_attachedTableView.isScrolling && !_attachedTableView.timerAutoScrolling.isValid){
        
        CGFloat differenceRate = (_attachedTableView.contentSize.height / scrollView.contentSize.height);
        
        CGFloat diffY = scrollView.contentOffset.y - _lastContentOffsetY;
        
        if (0.8f < differenceRate < 1.2f) {
            differenceRate = differenceRate * _differenceRateValue;
        }
        
        CGFloat value = _attachedTableView.contentOffset.y + (diffY * differenceRate);
        
        if (_attachedTableView.contentSize.height >= value) {
            
            _lastContentOffsetY = scrollView.contentOffset.y;
            
            _attachedTableView.lastContentOffsetY = value;
            
            [_attachedTableView setContentOffset:CGPointMake(_attachedTableView.contentOffset.x, value)];
        }
        
    }
    
    if ([_delegateEndless.receiver respondsToSelector:@selector(scrollViewDidScroll:)]) {
        return [_delegateEndless.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_enableAutoScrolling && !decelerate) {
        [self startAutoScrollingWithDelay:YES];
    }
    
    _isScrolling = NO;
    
    if (_attachedTableView.enableAutoScrolling && !decelerate && !_attachedTableView.isDragging)
    {
        [_attachedTableView startAutoScrollingWithDelay:YES];
    }
    
    if ([_delegateEndless.receiver respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        return [_delegateEndless.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_enableAutoScrolling) {
        [self stopAutoScrolling];
    }
    
    _isScrolling = YES;
    
    if (_attachedTableView.enableAutoScrolling)
    {
        [_attachedTableView stopAutoScrolling];
    }
    
    if ([_delegateEndless.receiver respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        return [_delegateEndless.receiver scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_enableAutoScrolling) {
        [self startAutoScrollingWithDelay:YES];
    }
    
    _isScrolling = NO;
    
    if (_attachedTableView.enableAutoScrolling) {
        [_attachedTableView startAutoScrollingWithDelay:YES];
    }
    
    if ([_delegateEndless.receiver respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        return [_delegateEndless.receiver scrollViewDidEndDecelerating:scrollView];
    }
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    _totalRows = [_dataSourceEndless.receiver tableView:tableView numberOfRowsInSection:section];
    
    return _totalRows * ( _enableEndlessScrolling ? 3 : 1 );
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSourceEndless.receiver tableView:tableView cellForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSourceEndless.receiver tableView:tableView canEditRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSourceEndless.receiver tableView:tableView canMoveRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSourceEndless.receiver tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    return [_dataSourceEndless.receiver tableView:tableView moveRowAtIndexPath:[self editIndexPathForIndexPath:sourceIndexPath  totalRows:_totalRows] toIndexPath:[self editIndexPathForIndexPath:destinationIndexPath  totalRows:_totalRows]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView willDisplayCell:cell forRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView heightForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView estimatedHeightForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView accessoryButtonTappedForRowWithIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView shouldHighlightRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didHighlightRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didUnhighlightRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView willSelectRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView willDeselectRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didSelectRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didDeselectRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView editingStyleForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView shouldIndentWhileEditingRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView willBeginEditingRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView didEndEditingRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return [_delegateEndless.receiver tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:[self editIndexPathForIndexPath:sourceIndexPath  totalRows:_totalRows] toProposedIndexPath:[self editIndexPathForIndexPath:proposedDestinationIndexPath  totalRows:_totalRows]];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView indentationLevelForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegateEndless.receiver tableView:tableView shouldShowMenuForRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows]];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return [_delegateEndless.receiver tableView:tableView canPerformAction:action forRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows] withSender:sender];
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return [_delegateEndless.receiver tableView:tableView performAction:action forRowAtIndexPath:[self editIndexPathForIndexPath:indexPath  totalRows:_totalRows] withSender:sender];
}


@end
