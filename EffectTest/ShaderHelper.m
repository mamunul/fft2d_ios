//
//  ShaderHelper.m
//  EffectTest
//
//  Created by Mamunul on 6/18/15.
//  Copyright © 2015 Mamunul. All rights reserved.
//

#import "ShaderHelper.h"

#import "ShaderHelper.h"

typedef struct {
	GLKVector4 position;
	GLKVector2 texCoord;
} Vertex;

@implementation ShaderHelper

+ (EAGLContext *)eaglContext
{
	static EAGLSharegroup *sharegroup = nil;
	if (sharegroup == nil) {
		EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		sharegroup = context.sharegroup;
		return context;
	}
	else {
		return [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
	}
}


-(UIImage *) runShader:(NSString *) shader OnImage:(UIImage *) image{
	
	//
	
	
	
	EAGLContext *context = [ShaderHelper eaglContext];
	
	[EAGLContext setCurrentContext:context];
	
	GLuint imageQuadVertexBuffer;
	
	// Make sure depth testing will be kept disabled
	glDisable(GL_DEPTH_TEST);
	
	// Create vertices
	Vertex vertices[] = {
		{{ 1,  1, 0, 1}, {1, 1}},
		{{-1,  1, 0, 1}, {0, 1}},
		{{ 1, -1, 0, 1}, {1, 0}},
		{{-1, -1, 0, 1}, {0, 0}}
	};
	
	// Create vertex buffer and fill it with data
	glGenBuffers(1, &imageQuadVertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, imageQuadVertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	
	
	glActiveTexture(GL_TEXTURE0);
	
	NSError *error = nil;
	
	GLint program = [self createProgramWithShader:shader error:&error];
	
	[self setupAttributesWithProgram:program Error:&error];
	
	GLubyte *textureData = [self textureDataFromUIImage:image];
	
	GLuint inputTextureToFilter = [self textureWithWidth:image.size.width Height:image.size.height Data:textureData];
	
	return [self filteredImageWithProgram:program Width:image.size.width Height:image.size.height onCompletion:^{
		glDeleteTextures(1, &inputTextureToFilter);
	}];
	
}

-(void)runShader:(NSString *)shader OnImageView:(UIView *) imageView WithImage:(UIImage *) image{
	
	EAGLContext *context = [ShaderHelper eaglContext];
	
	[EAGLContext setCurrentContext:context];
	
	GLuint framebuffer = [self createFramebufferInContext:context ForImageView:imageView WithImage:image];
	
	GLuint imageQuadVertexBuffer;
	
	// Make sure depth testing will be kept disabled
	glDisable(GL_DEPTH_TEST);
	
	// Create vertices
	Vertex vertices[] = {
		{{ 1,  1, 0, 1}, {1, 1}},
		{{-1,  1, 0, 1}, {0, 1}},
		{{ 1, -1, 0, 1}, {1, 0}},
		{{-1, -1, 0, 1}, {0, 0}}
	};
	
	// Create vertex buffer and fill it with data
	glGenBuffers(1, &imageQuadVertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, imageQuadVertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	NSError *error = nil;
	
	glActiveTexture(GL_TEXTURE0);
	
	GLint program = [self createProgramWithShader:shader error:&error];
	
	[self setupAttributesWithProgram:program Error:&error];
	
	GLubyte *textureData = [self textureDataFromUIImage:image];
	
	GLuint inputTextureToFilter = [self textureWithWidth:image.size.width Height:image.size.height Data:textureData];
	
	[self renderOnContext:context Program:program FrameBuffer:framebuffer];
	
	
}


-(void)renderOnContext:(EAGLContext *) context Program:(GLuint) program FrameBuffer:(GLint) framebuffer{
	
	GLint width,height;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
	
	
	glViewport(0, 0, width, height);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	
	glUseProgram(program);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, 1);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	[context presentRenderbuffer:GL_RENDERBUFFER];
	
	
}

- (GLuint)createFramebufferInContext:(EAGLContext *)context ForImageView:(UIView *) imageView WithImage:(UIImage *) image
{
	GLuint framebuffer,colorRenderbuffer;
	
	GLint width,height;
	
	glGenFramebuffers(1, &framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, image.size.width, image.size.height);
	
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)imageView.layer];
	
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	//
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
	
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Failed to create framebuffer: %x", status);
		return NO;
	}
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	glViewport(0, 0, width, height);
	
	return framebuffer;
}

- (BOOL)setupAttributesWithProgram:(GLuint)program Error:(NSError *__autoreleasing *)error
{
	
	GLint location = glGetAttribLocation(program, "position");
	
	glVertexAttribPointer(location, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
	glEnableVertexAttribArray(location);
	
	GLint location2 = glGetAttribLocation(program, "inputTextureCoordinate");
	
	glVertexAttribPointer(location2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, texCoord));
	glEnableVertexAttribArray(location2);
	
	return YES;
}


- (GLuint)createProgramWithShader:(NSString *)shader error:(NSError *__autoreleasing *)error
{
	NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:shader ofType:@"fsh"];
	NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:shader ofType:@"vsh"];
	
	NSString *vertexShaderSource = [[NSString alloc] initWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:error];
	
	
	NSString *fragmentShaderSource = [[NSString alloc] initWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:error];
	
	
	GLuint vertexShader = [self createShaderWithSource:vertexShaderSource type:GL_VERTEX_SHADER error:error];
	
	if (vertexShader == 0) {
		return 0;
	}
	
	GLuint fragmentShader = [self createShaderWithSource:fragmentShaderSource type:GL_FRAGMENT_SHADER error:error];
	
	if (fragmentShader == 0) {
		return 0;
	}
	
	GLuint prog = glCreateProgram();
	glAttachShader(prog, vertexShader);
	glAttachShader(prog, fragmentShader);
	glLinkProgram(prog);
	
	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);
	
	GLint linked = 0;
	glGetProgramiv(prog, GL_LINK_STATUS, &linked);
	if (linked == 0) {
		if (error != NULL) {
			char errorMsg[2048];
			glGetProgramInfoLog(prog, sizeof(errorMsg), NULL, errorMsg);
			NSString *errorString = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
			//			*error = [[NSError alloc] initWithDomain:GLKProgramErrorDomain code:GLKProgramErrorLinkFailed userInfo:userInfo];
		}
		glDeleteProgram(prog);
		return 0;
	}
	
	return prog;
}


- (GLuint)createShaderWithSource:(NSString *)sourceCode type:(GLenum)type error:(NSError *__autoreleasing *)error
{
	GLuint shader = glCreateShader(type);
	
	if (shader == 0) {
		if (error != NULL) {
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"glCreateShader failed.", NSLocalizedDescriptionKey, nil];
			//			*error = [[NSError alloc] initWithDomain:GLKProgramErrorDomain code:GLKProgramErrorFailedToCreateShader userInfo:userInfo];
		}
		return 0;
	}
	
	const GLchar *shaderSource = [sourceCode cStringUsingEncoding:NSUTF8StringEncoding];
	
	glShaderSource(shader, 1, &shaderSource, NULL);
	glCompileShader(shader);
	
	GLint success = 0;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
	
	if (success == 0) {
		if (error != NULL) {
			char errorMsg[2048];
			glGetShaderInfoLog(shader, sizeof(errorMsg), NULL, errorMsg);
			NSString *errorString = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
			//			*error = [[NSError alloc] initWithDomain:GLKProgramErrorDomain code:GLKProgramErrorCompilationFailed userInfo:userInfo];
		}
		glDeleteShader(shader);
		return 0;
	}
	
	return shader;
}



-(GLubyte *)textureDataFromUIImage:(UIImage *) image{
	
	
	CGImageRef imageRef = [image CGImage];
	int width = (int) CGImageGetWidth(imageRef);
	int height = (int) CGImageGetHeight(imageRef);
	
	
	GLubyte* textureData = (GLubyte *)malloc(width * height * 4); // if 4 components per pixel (RGBA)
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * width;
	NSUInteger bitsPerComponent = 8;
	CGContextRef cgcontext = CGBitmapContextCreate(textureData, width, height,
												   bitsPerComponent, bytesPerRow, colorSpace,
												   kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(cgcontext, CGRectMake(0, 0, width, height), imageRef);
	CGContextRelease(cgcontext);
	
	return textureData;
}


- (GLuint)textureWithWidth:(GLint)width Height:(GLint)height Data:(GLvoid *)data
{
	GLuint texture = 0;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, data);
	glBindTexture(GL_TEXTURE_2D, 0);
	return texture;
}


- (GLuint)framebufferFromTexture:(GLuint)texture
{
	GLuint framebuffer = 0;
	glGenFramebuffers(1, &framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	return framebuffer;
}



- (UIImage *)filteredImageWithProgram:(GLuint) program Width:(GLint)targetWidth Height:(GLint)targetHeight onCompletion:(void (^)(void))textureRelease
{
	
	
	GLuint textureForRendering = [self textureWithWidth:targetWidth Height:targetHeight Data:NULL];
	GLuint framBufferForRendering = [self framebufferFromTexture:textureForRendering];
	
	
	glViewport(0, 0, targetWidth, targetHeight);
	
	glBindFramebuffer(GL_FRAMEBUFFER, framBufferForRendering);
	
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	
	glUseProgram(program);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, 1);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	
	UIImage *image = [self imageFromFramebuffer:framBufferForRendering width:targetWidth height:targetHeight orientation:UIImageOrientationUp];
	
	
	
	return image;
}

- (UIImage *)imageFromFramebuffer:(GLuint)framebuffer width:(GLint)width height:(GLint)height orientation:(UIImageOrientation)orientation
{
	
	
	size_t size = width * height * 4;
	GLvoid *pixels = malloc(size);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	return [self imageFromData:pixels width:width height:height orientation:orientation ownsData:YES];
}

- (UIImage *)imageFromData:(void *)data width:(GLint)width height:(GLint)height orientation:(UIImageOrientation)orientation ownsData:(BOOL)ownsData
{
	size_t size = width * height * 4;
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = width * bitsPerPixel / bitsPerComponent;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, size, NULL);
	CGImageRef cgImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(provider);
	
	UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:orientation];
	CGImageRelease(cgImage);
	CGColorSpaceRelease(colorSpace);
	
	return image;
}

@end
