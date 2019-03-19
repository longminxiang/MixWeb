//
//  MXPhotoViewer.h
//
//  Created by eric on 15/6/11.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXPhotoDetailView.h"

@interface MiXPhotoPreviewController : UIViewController

typedef void (^MXPhotoViewerDetailViewSetter)(MXPhotoDetailView *dview, NSInteger index);

- (instancetype)initWithCount:(NSInteger)count cntIndex:(NSInteger)cntIndex detailViewSetter:(MXPhotoViewerDetailViewSetter)detailViewSetter;

@end
