//
//  ViewController.m
//  FishEyeRemover
//
//  Created by Adam Jensen on 5/5/15.
//  Copyright (c) 2015 Adam Jensen. All rights reserved.
//

#import "ViewController.h"

CGPoint _sourcePixelForPoint(CGPoint point, CGSize imageSize, float strength, float zoom)
{
  const float halfWidth = imageSize.width / 2;
  const float halfHeight = imageSize.height / 2;
  
  const float correctionRadius = sqrtf(powf(imageSize.width, 2) +
                                       powf(imageSize.height, 2)) / strength;
  
  const int newX = point.x - halfWidth;
  const int newY = point.y - halfHeight;
  
  const float distance = sqrtf(newX * newX + newY * newY);
  const float r = distance / correctionRadius;
  
  float theta = 1;
  
  if (r != 0)
  {
    theta = atanf(r) / r;
  }
  
  return CGPointMake((int)(halfWidth + theta * newX * zoom),
                     (int)(halfHeight + theta * newY * zoom));
}

static NSData* _removeFishEyeFromPixelData(NSData* pixelData, NSInteger width, NSInteger height)
{
  // These parameters need to be tuned for the photo(s) being corrected. A higher strength value
  // increases the amount of outward "pull" applied to the corners of the image. A higher zoom
  // factor allows you to see more of the original image but may increase the amount of distortion
  // that's visible in the output image.
  const float strength = 3.25f;
  const float zoomOut  = 1.25f;
  
  uint32_t* const pixels    = (uint32_t*)[pixelData bytes];
  uint32_t* const newPixels = (uint32_t*)malloc(pixelData.length);
  const CGSize    imageSize = CGSizeMake(width, height);
  
  CGPoint destinationPoint = CGPointZero;
  
  for (int y = 0; y < height; y++)
  {
    for (int x = 0; x < width; x++)
    {
      destinationPoint.x = x;
      destinationPoint.y = y;
      
      CGPoint sourcePixelPoint = _sourcePixelForPoint(destinationPoint, imageSize, strength, zoomOut);
      
      if (sourcePixelPoint.x < 0 || sourcePixelPoint.x > width ||
          sourcePixelPoint.y < 0 || sourcePixelPoint.y > height)
      {
        continue;
      }
      
      NSInteger destinationPixelOffset = x + y*width;
      NSInteger sourcePixelOffset = sourcePixelPoint.x + sourcePixelPoint.y*width;
      
      newPixels[destinationPixelOffset] = pixels[sourcePixelOffset];
    }
  }
  
  return [NSData dataWithBytes:newPixels length:pixelData.length];
}

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView* sourceImageView;
@property (weak, nonatomic) IBOutlet UIImageView* sinkImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIImage* const   image     = [UIImage imageNamed:@"Test"];
  const CGImageRef imageRef  = image.CGImage;
  NSData* const    imageData = (NSData *)CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(imageRef)));
  
  size_t width               = CGImageGetWidth(imageRef);
  size_t height              = CGImageGetHeight(imageRef);
  size_t bitsPerComponent    = CGImageGetBitsPerComponent(imageRef);
  size_t bitsPerPixel        = CGImageGetBitsPerPixel(imageRef);
  size_t bytesPerRow         = CGImageGetBytesPerRow(imageRef);
  
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGBitmapInfo bitmapInfo    = CGImageGetBitmapInfo(imageRef);
  
  NSData* const newPixelData = _removeFishEyeFromPixelData(imageData, width, height);
  CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, newPixelData.bytes, [newPixelData length], NULL);
  
  CGImageRef newImageRef = CGImageCreate(width,
                                         height,
                                         bitsPerComponent,
                                         bitsPerPixel,
                                         bytesPerRow,
                                         colorspace,
                                         bitmapInfo,
                                         provider,
                                         NULL,
                                         false,
                                         kCGRenderingIntentDefault
                                         );
  UIImage* const newImage = [UIImage imageWithCGImage:newImageRef];
  
  self.sourceImageView.image = image;
  self.sinkImageView.image = newImage;
  
  CGImageRelease(imageRef);
  CGColorSpaceRelease(colorspace);
  CGDataProviderRelease(provider);
  CGImageRelease(newImageRef);
}

@end
