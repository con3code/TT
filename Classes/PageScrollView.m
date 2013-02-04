#import "PageScrollView.h"

@implementation PageScrollView

@synthesize backtoView;

- (id)initWithFrame:(CGRect)frame {
//	NSLog(@"PageScrollView:initWithFrame");

    self = [super initWithFrame:frame];
    if (self != nil) {
        _pages = nil;
        _zeroPage = 0;
        _pageRegion = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
//      _pageRegion = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 60.0);
//      _controlRegion = CGRectMake(frame.origin.x, frame.size.height - 60.0, frame.size.width, 60.0);
        self.delegate = nil;
        
        scrollView = [[UIScrollView alloc] initWithFrame:_pageRegion];
        scrollView.pagingEnabled = YES;
		scrollView.showsHorizontalScrollIndicator = NO;  
		scrollView.showsVerticalScrollIndicator = NO;  
		scrollView.scrollsToTop = YES;  
		scrollView.directionalLockEnabled = YES;
		scrollView.delegate = self;
        [self addSubview:scrollView];
/*        
        pageControl = [[UIPageControl alloc] initWithFrame:_controlRegion];
        [pageControl addTarget:self action:@selector(pageControlDidChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
*/
 }
    return self;
}



- (void)setPages:(NSMutableArray *)pages {
	
    if (pages != nil) {
        for(int i = 0; i < [_pages count]; i++) {
            [[_pages objectAtIndex:i] removeFromSuperview];
        }
    }
    _pages = pages;
    scrollView.contentOffset = CGPointMake(0.0, 0.0);
    if ([_pages count] < 3) {
        scrollView.contentSize = CGSizeMake(_pageRegion.size.width * [_pages count], _pageRegion.size.height);
    } else {
        scrollView.contentSize = CGSizeMake(_pageRegion.size.width * 3, _pageRegion.size.height);
        scrollView.showsHorizontalScrollIndicator = NO;
    }
    pageControl.numberOfPages = [_pages count];
    pageControl.currentPage = 0;
    [self layoutViews];
}

- (void)layoutViews {
		
    if ([_pages count] <= 3) {
        for(int i = 0; i < [_pages count]; i++) {
            UIView *page = [_pages objectAtIndex:i];
            CGRect bounds = page.bounds;
            CGRect frame = CGRectMake(_pageRegion.size.width * i, 0.0, _pageRegion.size.width, _pageRegion.size.height);
            page.frame = frame;
            page.bounds = bounds;
            [scrollView addSubview:page];
        }
        return;
    }
    
    /* ビュー数が3を超える場合、すべてを非表示状態でサブビューとして追加し、必要に応じてページを配置する */
    for(int i = 0; i < [_pages count]; i++) {
        UIView *page = [_pages objectAtIndex:i];
        CGRect bounds = page.bounds;
        CGRect frame = CGRectMake(0.0, 0.0, _pageRegion.size.width, _pageRegion.size.height);
        page.frame = frame;
        page.bounds = bounds;
        page.hidden = YES;
        [scrollView addSubview:page];
    }
    [self layoutScroller];
}

- (void)layoutScroller {
    UIView *page;
    CGRect bounds, frame;
    int pageNum = [self getCurrentPage];
    
    if ([_pages count] <= 3)
        return;
    
//    NSLog(@"スクロールビューにページを配置 現在ページ　%d\n", pageNum);
    
    /* 左端（最初）のページ */
    if (pageNum == 0) {
		for (UIView *p in _pages) {
			p.hidden = YES;			
		}
        for(int i = 0 ; i < 3; i++) {
            page = [_pages objectAtIndex:i];
            bounds = page.bounds;
            frame = CGRectMake(_pageRegion.size.width * i, 0.0, _pageRegion.size.width, _pageRegion.size.height);
//            NSLog(@"\tページ番号%dのオフセット = %f\n", i, frame.origin.x);
            page.frame = frame;
            page.bounds = bounds;
            page.hidden = NO;
        }
//		[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
		scrollView.contentOffset = CGPointMake(0.0, 0.0);
        page = [_pages objectAtIndex:3];
        page.hidden = YES;
        _zeroPage = 0;
    }
    
    /* 右端（最終）のページ */
    else if (pageNum == [_pages count] -1 | _lastPage == YES) {
		for(int i = pageNum-2; i <= pageNum; i++) {
			page = [_pages objectAtIndex:i];
			bounds = page.bounds;
			frame = CGRectMake(_pageRegion.size.width * (2-(pageNum-i)), 0.0, _pageRegion.size.width, _pageRegion.size.height);
			//            NSLog(@"\tページ番号%dのオフセット = %f\n", i, frame.origin.x);
			page.frame = frame;
			page.bounds = bounds;
			page.hidden = NO;
		}
//		[scrollView setContentOffset:CGPointMake(640, 0.0) animated:NO];
		scrollView.contentOffset = CGPointMake(640, 0.0);
		page = [_pages objectAtIndex:[_pages count]-3];
		page.hidden = YES;
		_zeroPage = pageNum-2;
    }
    
    /* 中間のページすべて */
    else if (pageNum < 24) {
		for (UIView *p in _pages) {
			p.hidden = YES;			
		}
		/*
        for(int i=0; i< [_pages count]; i++) {
			UIView *page = [_pages objectAtIndex:i];
			page.hidden = YES;
			
			 if (i < pageNum-1 || i > pageNum + 1) {
			 page = [_pages objectAtIndex:i];
			 page.hidden = YES;
			 }
        }
		*/
	
        for(int i = pageNum-1; i <= pageNum+1; i++) {
            page = [_pages objectAtIndex:i];
            bounds = page.bounds;
            frame = CGRectMake(_pageRegion.size.width * (i-(pageNum-1)), 0.0, _pageRegion.size.width, _pageRegion.size.height);
//            NSLog(@"\tページ番号%dのオフセット = %f\n", i, frame.origin.x);
            page.frame = frame;
            page.bounds = bounds;
            page.hidden = NO;
        }
//		[scrollView setContentOffset:CGPointMake(_pageRegion.size.width, 0.0) animated:NO];
		scrollView.contentOffset = CGPointMake(_pageRegion.size.width, 0.0);
		_zeroPage = pageNum-1;
    }
}

- (id)getDelegate {
    return _delegate;
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}


- (BOOL)getShowsPageControl {
    return _showsPageControl;
}

/*
- (void)setShowsPageControl:(BOOL)showsPageControl {
    _showsPageControl = showsPageControl;
    if (_showsPageControl == NO) {
        _pageRegion = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        pageControl.hidden = YES;
        scrollView.frame = _pageRegion;
    } else {
        _pageRegion = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 60.0);
        pageControl.hidden = NO;
        scrollView.frame = _pageRegion;
    }
}
*/

- (NSMutableArray *)getPages {
    return _pages;
}


/*
- (void)setStartPage:(int)page {
	if (page == 0) {		
		[scrollView setContentOffset:CGPointMake(0.0, 0.0)];
		_zeroPage = page;
	}
	else {
		[scrollView setContentOffset:CGPointMake(_pageRegion.size.width, 0.0)];
		_zeroPage = page-1;
	}

    [self layoutScroller];
	//    pageControl.currentPage = page;
}
*/


- (void)setCurrentPage:(int)page {
	[scrollView setContentOffset:CGPointMake(0.0, 0.0)];
	_zeroPage = page;
    [self layoutScroller];
//    pageControl.currentPage = page;
}

- (int)getCurrentPage {
		int cp = (int) (scrollView.contentOffset.x / _pageRegion.size.width) + _zeroPage;
		return cp;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    pageControl.currentPage = self.currentPage;
    [self layoutScroller];
//    [self notifyPageChange];
}

- (void)pageControlDidChange:(id)sender {
    UIPageControl *control = (UIPageControl *) sender;
    if (control == pageControl) {
        [scrollView setContentOffset:CGPointMake(_pageRegion.size.width * (control.currentPage - _zeroPage), 0.0) animated:YES];
    }
}

/*
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self layoutScroller];
//    [self notifyPageChange];
}
*/

- (void)notifyPageChange {
    if (self.delegate != nil) {
        if ([_delegate conformsToProtocol:@protocol(PageScrollViewDelegate)]) {
            if ([_delegate respondsToSelector:@selector(pageScrollViewDidChangeCurrentPage:currentPage:)]) {
                [self.delegate pageScrollViewDidChangeCurrentPage:(PageScrollView *)self currentPage:self.currentPage];
            }
        }
    }
}

@end
