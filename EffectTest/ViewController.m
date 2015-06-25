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
	
//	ShaderHelper *shaderHelper = [[ShaderHelper alloc] init];
	


	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		UIImage *image = [shaderHelper runShader:@"invert" OnImage:originalImage];
		
		UIImage *image = [[[ImageProcessing alloc] init] processImage:originalImage];
		
		
		
		processedImageView.image = image;
		
		NSLog(@"image2:%@",NSStringFromCGSize(image.size));
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
