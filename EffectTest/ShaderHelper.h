//
//  ShaderHelper.h
//  EffectTest
//
//  Created by Mamunul on 6/18/15.
//  Copyright © 2015 Mamunul. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <mach/host_info.h>
#import <mach/mach.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ShaderHelper : NSObject

-(UIImage *) runShader:(NSString *) shader OnImage:(UIImage *) image;
-(void)runShader:(NSString *)shader OnImageView:(UIView *) imageView WithImage:(UIImage *) image;

@end

