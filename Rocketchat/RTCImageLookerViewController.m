//
//  RTCImageLookerViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 01/09/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCImageLookerViewController.h"
#import "UIImage+Scale.h"
#import "RTCMainViewController.h"

@interface RTCImageLookerViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation RTCImageLookerViewController

#pragma mark - Init

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
        self.isSaving = NO;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Dealloc photo looker");
}

#pragma mark - View Lifecycle

#pragma mark - Saving

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    
    self.scrollView.delegate = self;
    
    CGSize newImageSize = [self.image imageSizeToFitWidth:self.view.bounds.size.width];
    NSLog(@"New image width:%f height:%f", newImageSize.width, newImageSize.height);
    //[self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0, 0, newImageSize.width, newImageSize.height);
    [self.scrollView addSubview:self.imageView];
    NSLog(@"%@", self.imageView);
    
   // self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.maximumZoomScale = self.imageView.image.size.width / self.view.bounds.size.width;
    self.scrollView.minimumZoomScale = 1.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.imageView setCenter:centerPoint];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.imageView setCenter:centerPoint];
    
    CGSize newImageSize = [self.image imageSizeToFitWidth:self.view.bounds.size.width];
    self.imageView.bounds = CGRectMake(0, 0, newImageSize.width, newImageSize.height);
}

- (void)dealloc {
    NSLog(@"Dealloc photo looker");
}

#pragma mark - Removing



#pragma mark - Scroll View Setup

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint {
    CGRect viewFrame = view.frame;
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - viewFrame.size.width / 2.0;
    CGFloat y = centerPoint.y - viewFrame.size.height / 2.0;
    
    if(x < 0) {
        contentOffset.x = -x;
        viewFrame.origin.x = 0.0;
    } else {
        viewFrame.origin.x = x;
    }
    
    if(y < 0) {
        contentOffset.y = -y;
        viewFrame.origin.y = 0.0;
    } else {
        viewFrame.origin.y = y;
    }
    
    view.frame = viewFrame;
    self.scrollView.contentOffset = contentOffset;
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.imageView) {
        return self.imageView;
    }
    
    return nil;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *zoomView = [scrollView.delegate viewForZoomingInScrollView:scrollView];
    CGRect zoomViewFrame = zoomView.frame;
    
    if(zoomViewFrame.size.width < scrollView.bounds.size.width) {
        zoomViewFrame.origin.x = (scrollView.bounds.size.width - zoomViewFrame.size.width) / 2.0;
    } else {
        zoomViewFrame.origin.x = 0.0;
    }
    
    if(zoomViewFrame.size.height < scrollView.bounds.size.height) {
        zoomViewFrame.origin.y = (scrollView.bounds.size.height - zoomViewFrame.size.height) / 2.0;
    } else {
        zoomViewFrame.origin.y = 0.0;
    }
    
    zoomView.frame = zoomViewFrame;
}
*/

@end
