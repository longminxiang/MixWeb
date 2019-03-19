//
//  MXPhotoViewer.m
//
//  Created by eric on 15/6/11.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import "MXPhotoViewer.h"
#import "MixWebUtils.h"

@interface MixPhotoScrollView : UIScrollView

@end

@implementation MixPhotoScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    [super gestureRecognizerShouldBegin:gestureRecognizer];
    CGPoint point = [gestureRecognizer locationInView:self];
    return point.x < 44 ? NO : YES;
}


@end

#pragma mark
#pragma mark === MXPhotoViewer ===

@interface MiXPhotoPreviewController ()<UIScrollViewDelegate>

@property (nonatomic) BOOL toolbarHide;

@property (nonatomic, readonly) NSMutableArray *detailViews;

@property (nonatomic, strong) MixPhotoScrollView *scrollView;

@property (nonatomic, assign) NSInteger kNumberOfPages,currentPage;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture, *doubleGesture;

@property (nonatomic, copy) MXPhotoViewerDetailViewSetter detailViewSetter;

@end

@implementation MiXPhotoPreviewController

- (instancetype)initWithCount:(NSInteger)count cntIndex:(NSInteger)cntIndex detailViewSetter:(MXPhotoViewerDetailViewSetter)detailViewSetter
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.currentPage = cntIndex;
        self.kNumberOfPages = count;
        self.detailViewSetter = detailViewSetter;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", (long)self.currentPage + 1, (long)self.kNumberOfPages];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    
    UIImage *image = [MixWebImage imageName:@"save"];
    
    [rightButton setImage:image forState:UIControlStateNormal];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton addTarget:self action:@selector(rightBarButtonItemTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    self.doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.doubleGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.doubleGesture];
    
    _detailViews = [NSMutableArray new];
    for (int i = 0; i < self.kNumberOfPages; i++) {
        [_detailViews addObject:[NSNull null]];
    }
    
    CGRect bounds = self.view.bounds;
    
    MixPhotoScrollView *scrollView = [[MixPhotoScrollView alloc] initWithFrame:bounds];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    scrollView.contentSize = CGSizeMake(bounds.size.width * self.kNumberOfPages, bounds.size.height);
    [scrollView setContentOffset:CGPointMake(bounds.size.width * self.currentPage, 0)];
    
    [self startLoadDetailViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark === scrollview ===

- (void)limitPageCount:(NSInteger)pCount cnPage:(NSInteger)page
{
    NSInteger rPage = page - pCount;
    if (rPage >= 0 && rPage < self.kNumberOfPages) {
        UIView *view = [self.detailViews objectAtIndex:rPage];
        if (![view isKindOfClass:[NSNull class]]) {
            [view removeFromSuperview];
            [self.detailViews replaceObjectAtIndex:rPage withObject:[NSNull null]];
        }
    }
}

- (void)startLoadDetailViews
{
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld",(long)self.currentPage + 1,(long)self.kNumberOfPages];
}

- (void)loadScrollViewWithPage:(NSInteger)page
{
    if (page < 0 || page >= self.kNumberOfPages)
        return;
    [self limitPageCount:5 cnPage:page];
    [self limitPageCount:-5 cnPage:page];
    
    if ((NSNull *)[self.detailViews objectAtIndex:page] == [NSNull null]) {
        MXPhotoDetailView *view = [[MXPhotoDetailView alloc] initWithFrame:self.scrollView.bounds];
        if (self.detailViewSetter) self.detailViewSetter(view, page);
        [self.detailViews replaceObjectAtIndex:page withObject:view];
    }
    UIView *view = [self.detailViews objectAtIndex:page];
    if ([view superview] == nil) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        [view setFrame:frame];
        [self.scrollView addSubview:view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (self.currentPage != page) {
        self.currentPage = page;
        [self startLoadDetailViews];
    }
}

- (void)view:(UIView *)view showOrHideWithFade:(BOOL)showOrHide completion:(void (^)(BOOL finished))completion
{
    CGFloat alpha = showOrHide ? 1 : 0;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = alpha;
    } completion:completion];
}

#pragma mark === action ===

- (void)leftBarButtonItemTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonItemTouched
{
    [self savePictureToAlbum];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    MXPhotoDetailView *view = self.detailViews[self.currentPage];
    [view resetZoomScale];
}

- (void)savePictureToAlbum
{
    if (self.detailViews.count <= self.currentPage) return;
    MXPhotoDetailView *view = self.detailViews[self.currentPage];
    if (![view isKindOfClass:[MXPhotoDetailView class]]) return;
    UIImage *image = view.imageView.image;
    if (!image) return;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [MixWebHUD showText:@"保存成功"];
    }
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

@end
