//
//  ImageProcessing.m
//  EffectTest
//
//  Created by Mamunul on 6/17/15.
//  Copyright © 2015 Mamunul. All rights reserved.
//

#import "ImageProcessing.h"

@implementation ImageProcessing
{
	COMPLEX_SPLIT in_fft_r;
	COMPLEX_SPLIT in_fft_g;
	COMPLEX_SPLIT in_fft_b;
	COMPLEX_SPLIT in_fft_a;
	
	
	COMPLEX_SPLIT out_fft_r;
	COMPLEX_SPLIT out_fft_g;
	COMPLEX_SPLIT out_fft_b;
	COMPLEX_SPLIT out_fft_a;
	
	UIImage *originalImage ;
	SInt32 rowStride ;
	SInt32 columnStride;
	int width;
	int height;
	unsigned char *bytePtr;

}

-(UIImage *) processImage:(UIImage *) originalImage{
	

	
	width = originalImage.size.width;
	
	height = originalImage.size.height;
	
	originalImage = [self invertImage:originalImage];
	
	[self readImage:originalImage];
	
	[self fftImage];
	
//	[self hpimage];
	
	UIImage *image = [self ifftImage];

	return image;

}

-(void) readImage:(UIImage*)inputImage
{

	
	NSData *data = UIImageJPEGRepresentation(inputImage, 100);
	
	bytePtr = (unsigned char *)[data bytes];
	
	UInt32 byteIndex = 0;

	
	UInt32 N = log2(width*height);
	UInt32 log2nr = N / 2;
	UInt32 log2nc = N / 2;
	UInt32 numElements = 1 << ( log2nr + log2nc );
	
	in_fft_r.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_r.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_g.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_g.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_b.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_b.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_a.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	in_fft_a.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );

	NSLog(@"loop started");
	//Copy RGB values into rawData
	for(UInt32 i = 0;i < width * height; ++i)
	{
		in_fft_r.realp[i] = (float)bytePtr[byteIndex]/255;
		in_fft_r.imagp[i] = 0;
		in_fft_g.realp[i] = (float)bytePtr[byteIndex+1]/255;
		in_fft_g.imagp[i] = 0;
		in_fft_b.realp[i] = (float)bytePtr[byteIndex+2]/255;
		in_fft_b.imagp[i] = 0;
		in_fft_a.realp[i] = (float)bytePtr[byteIndex+3]/255;
		in_fft_a.imagp[i] = 0;

		byteIndex +=4;
	}
	
		NSLog(@"loop ended");

}

-(UIImage *) invertImage:(UIImage *) image{

	UIImage *processedImage = [[[ShaderHelper alloc] init] runShader:@"invert" OnImage:image];


	return processedImage;
}

-(void) fftImage{
	
	
	UInt32 N = log2(width*height);
	UInt32 log2nr = N / 2;
	UInt32 log2nc = N / 2;
	
	NSLog(@"log2nr:%d",log2nc);
	UInt32 numElements = 1 << ( log2nr + log2nc );
	float SCALE = 1.0/numElements;
	rowStride = 1;
	columnStride = 0;
	FFTSetup setup = vDSP_create_fftsetup(MAX(log2nr, log2nc), FFT_RADIX2);
	
	out_fft_r.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_fft_r.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );

	
	vDSP_fft2d_zop( setup, &in_fft_r, rowStride, columnStride, &out_fft_r, rowStride, columnStride, log2nc, log2nr, FFT_FORWARD );
		NSLog(@"After fft");
	
	
	out_fft_g.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_fft_g.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	
	
	vDSP_fft2d_zop( setup, &in_fft_g, rowStride, columnStride, &out_fft_g, rowStride, columnStride, log2nc, log2nr, FFT_FORWARD );
	NSLog(@"After fft");
	
	
	out_fft_b.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_fft_b.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	
	
	vDSP_fft2d_zop( setup, &in_fft_b, rowStride, columnStride, &out_fft_b, rowStride, columnStride, log2nc, log2nr, FFT_FORWARD );
	NSLog(@"After fft");
	
	out_fft_a.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_fft_a.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	
	
	vDSP_fft2d_zop( setup, &in_fft_a, rowStride, columnStride, &out_fft_a, rowStride, columnStride, log2nc, log2nr, FFT_FORWARD );
	NSLog(@"After fft");
	

//	free(in_fft_r.realp);
//	free(in_fft_r.imagp);
//	free(in_fft_g.realp);
//	free(in_fft_g.imagp);
//	free(in_fft_b.realp);
//	free(in_fft_b.imagp);
//	free(in_fft_a.realp);
//	free(in_fft_a.imagp);


}

-(UIImage *)ifftImage{

	UInt32 N = log2(width*height);
	
	UInt32 log2nr = N / 2;
	UInt32 log2nc = N / 2;
	UInt32 numElements = 1 << ( log2nr + log2nc );
	float SCALE = 1.0/numElements;
	COMPLEX_SPLIT out_ifft_r;
	out_ifft_r.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_ifft_r.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );

	FFTSetup setup = vDSP_create_fftsetup(MAX(log2nr, log2nc), FFT_RADIX2);


	vDSP_fft2d_zop(setup, &out_fft_r, rowStride, columnStride, &out_ifft_r, rowStride, columnStride, log2nc, log2nr, FFT_INVERSE);
		NSLog(@"after ifft");

	
	vDSP_vsmul( out_ifft_r.realp, 1, &SCALE, out_ifft_r.realp, 1, numElements );
	vDSP_vsmul( out_ifft_r.imagp, 1, &SCALE, out_ifft_r.imagp, 1, numElements );
	
	
	COMPLEX_SPLIT out_ifft_g;
	out_ifft_g.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_ifft_g.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	

	vDSP_fft2d_zop(setup, &out_fft_g, rowStride, columnStride, &out_ifft_g, rowStride, columnStride, log2nc, log2nr, FFT_INVERSE);
	NSLog(@"after ifft");
	
	
	vDSP_vsmul( out_ifft_g.realp, 1, &SCALE, out_ifft_g.realp, 1, numElements );
	vDSP_vsmul( out_ifft_g.imagp, 1, &SCALE, out_ifft_g.imagp, 1, numElements );
	
	
	COMPLEX_SPLIT out_ifft_b;
	out_ifft_b.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_ifft_b.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	

	
	vDSP_fft2d_zop(setup, &out_fft_b, rowStride, columnStride, &out_ifft_b, rowStride, columnStride, log2nc, log2nr, FFT_INVERSE);
	NSLog(@"after ifft");
	
	
	vDSP_vsmul( out_ifft_b.realp, 1, &SCALE, out_ifft_b.realp, 1, numElements );
	vDSP_vsmul( out_ifft_b.imagp, 1, &SCALE, out_ifft_b.imagp, 1, numElements );
	
	
	COMPLEX_SPLIT out_ifft_a;
	out_ifft_a.realp = ( float* ) malloc ( numElements * sizeof ( float ) );
	out_ifft_a.imagp = ( float* ) malloc ( numElements * sizeof ( float ) );
	
	
	vDSP_fft2d_zop(setup, &out_fft_a, rowStride, columnStride, &out_ifft_a, rowStride, columnStride, log2nc, log2nr, FFT_INVERSE);
	NSLog(@"after ifft");
	
	
	vDSP_vsmul( out_ifft_a.realp, 1, &SCALE, out_ifft_a.realp, 1, numElements );
	vDSP_vsmul( out_ifft_a.imagp, 1, &SCALE, out_ifft_a.imagp, 1, numElements );

	
	bytePtr = ( unsigned char * ) malloc ( width * height*4 * sizeof ( unsigned char ) );
	
		NSLog(@"loop started");
	UInt32 byteIndex = 0;
	for(UInt32 i = 0;i < width * height; ++i)
	{
		bytePtr[byteIndex] = (char)(in_fft_r.realp[i]*255);
	
		bytePtr[byteIndex+1]= (char)(in_fft_g.realp[i]*255);

		bytePtr[byteIndex+2]= (char)(in_fft_b.realp[i]*255);

		bytePtr[byteIndex+3]= (char)(in_fft_a.realp[i]*255);
		byteIndex+=4;
	}
		NSLog(@"loop ended");
	
	free(out_ifft_r.realp);
	free(out_ifft_r.imagp);
	free(out_ifft_g.realp);
	free(out_ifft_g.imagp);
	free(out_ifft_b.realp);
	free(out_ifft_b.imagp);
	free(out_ifft_a.realp);
	free(out_ifft_a.imagp);
	
	
	NSData *data = [[NSData alloc] initWithBytes:bytePtr length:width * height*4 ];

	UIImage *image = [[UIImage alloc] initWithData:data];

	
	return image;
}


-(void)hpimage{


//	UIImage *processedImage = [[[ShaderHelper alloc] init] runShader:@"hpfilter" OnImage:image];
	
	
//	return processedImage;

	


}


-(void)blendImage{




}

@end
