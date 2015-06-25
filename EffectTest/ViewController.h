//
//  ViewController.h
//  EffectTest
//
//  Created by Mamunul on 6/16/15.
//  Copyright (c) 2015 Mamunul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessing.h"
#import "ShaderHelper.h"

@interface ViewController : UIViewController
{

	IBOutlet UIImageView *originalImageView;
	IBOutlet UIImageView *processedImageView;
	IBOutlet GLKView *glkview;

}


@end

