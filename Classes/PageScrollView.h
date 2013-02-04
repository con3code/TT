
#import <UIKit/UIKit.h>
#import "TT_Define.h"


@interface PageScrollView : UIView <UIScrollViewDelegate> {
	
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    
    CGRect _pageRegion, _controlRegion;
    NSMutableArray *_pages;
    id _delegate;
    BOOL _showsPageControl;
    int _zeroPage;
	BOOL _lastPage;
	
	
	UIView *backtoView;
	
}

@property(nonatomic,retain) UIView *backtoView;
@property(nonatomic,assign,getter=getPages) NSMutableArray *pages; /* UIViewのサブクラスの格納用 */
@property(nonatomic,assign,getter=getCurrentPage) int currentPage; 
//@property(nonatomic,assign) int startPage; 
@property(nonatomic,assign,getter=getDelegate) id delegate; /* PageScrollViewDelegate */
//@property(nonatomic,assign,getter=getShowsPageControl) BOOL showsPageControl;


- (void)layoutViews;
- (void)layoutScroller;
- (void)notifyPageChange;

@end

@protocol PageScrollViewDelegate<NSObject>

@optional

- (void) pageScrollViewDidChangeCurrentPage:(PageScrollView *)pageScrollView currentPage:(int)currentPage;

@end
