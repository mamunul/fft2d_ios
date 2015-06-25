//
//  ImageProcessing.h
//  EffectTest
//
//  Created by Mamunul on 6/17/15.
//  Copyright © 2015 Mamunul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <UIKit/UIKit.h>
#import "ShaderHelper.h"


@interface ImageProcessing : NSObject

-(UIImage *) processImage:(UIImage *) originalImage;

@end
