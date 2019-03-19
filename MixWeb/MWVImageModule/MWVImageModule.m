//
//  MWVImageModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2017/10/9.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVImageModule.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <MixExtention/MixExtention.h>
#import "MXPhotoViewer.h"
#import "MixWebUtils.h"

@interface MWVImageModule ()

@property (nonatomic, copy) MixWebJSResponseCallback saveImageCallback;

@end

@implementation MWVImageModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    __weak typeof(self) weaks = self;

    [self.webView registerBridgeHandler:@"chooseImage" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        int count = [value intK:@"count"];
        TZImagePickerController *avc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:nil];
        avc.allowPickingVideo = NO;
        avc.allowPickingOriginalPhoto = NO;
        avc.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            NSMutableArray *images = [NSMutableArray new];
            for (int i = 0; i < photos.count; i++) {
                UIImage *photo = photos[i];
                NSData *imageData = UIImageJPEGRepresentation(photo, 0.8);
                NSString *base64Data = [imageData base64EncodedStringWithOptions:0];
                [images addObject: base64Data];
            }
            if (responseCallback) responseCallback(@{@"images": images});
        };
        UIViewController *vc = [UIViewControllerMixExtention topViewController];
        [vc.navigationController presentViewController:avc animated:YES completion:nil];
    }];

    [self.webView registerBridgeHandler:@"previewImage" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSArray *urls = [value arrayK:@"urls"];
        int cntIndex = [value intK:@"index"];
        MiXPhotoPreviewController *avc = [[MiXPhotoPreviewController alloc] initWithCount:urls.count cntIndex:cntIndex detailViewSetter:^(MXPhotoDetailView *dview, NSInteger index) {
            [MixWebImage getImageWithURL:urls[index] completion:^(UIImage *image, NSString *url) {
                [dview addImage:image];
            }];
        }];
        UIViewController *vc = [UIViewControllerMixExtention topViewController];
        [vc.navigationController pushViewController:avc animated:YES];
    }];

    [self.webView registerBridgeHandler:@"saveImageToAlbum" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *url = [value stringK:@"url"];
        [MixWebImage getImageWithURL:url completion:^(UIImage *image, NSString *url) {
            weaks.saveImageCallback = responseCallback;
            UIImageWriteToSavedPhotosAlbum(image, weaks, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (self.saveImageCallback) self.saveImageCallback(@{@"success": @(!error)});
}

@end
