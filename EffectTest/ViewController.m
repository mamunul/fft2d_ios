//
//  ViewController.m
//  EffectTest
//
//  Created by Mamunul on 6/16/15.
//  Copyright (c) 2015 Mamunul. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	int imageHeight = 256;
	
	UIImage *originalImage = [self resizeImage:[UIImage imageNamed:@"e"] heightWidth:imageHeight];
	
	originalImageView.image = originalImage;
	
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		UIImage *image = [[[ImageProcessing alloc] init] processImage:originalImage];
		
		NSLog(@"image:%@",NSStringFromCGSize(image.size));
		processedImageView.image = image;
	});
	
	
}
- (UIImage *)resizeImage:(UIImage *)image heightWidth:(float) maxWidthHeight
{
	
	CGSize size   = CGSizeMake(maxWidthHeight , maxWidthHeight);
	
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context    = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	UIImage* scaledImage    = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
