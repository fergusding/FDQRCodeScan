//
//  ViewController.m
//  FDQRCodeScanDemo
//
//  Created by fergusding on 15/7/3.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "FDQRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface FDQRCodeScanController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *scanAreaView;
@property (strong, nonatomic) CALayer *scanLine;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation FDQRCodeScanController

#pragma mark - Lifecircle

- (void)viewDidAppear:(BOOL)animated {
    [self startReading];
    [self setupScanAreaView];
    [self setupScanLine];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopReading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _captureSession = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)startReading {
    // Create a instance of AVCaptureDevice
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a instance of AVCaptureDeviceInput
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    // Create a instance of AVCaptureMetadataOutput
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // Create a instance of AVCaptureSession
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    // Add input into captureSession
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    }
    
    // Add output into captureSession
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    }
    
    // Set the metadata type of output with QRCode
    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    // Set the scanning area size
    output.rectOfInterest = CGRectMake(0.2, 0.4, 0.8, 0.8);
    
    // Set the delegate of output
    dispatch_queue_t queue = dispatch_queue_create("FDQRCodeScan", NULL);
    [output setMetadataObjectsDelegate:self queue:queue];
    
    // Create a instance of AVCaptureVideoPreviewLayer
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.frame = self.view.layer.bounds;
    
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    // start Scanning
    [_captureSession startRunning];
}

- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    [_timer invalidate];
    _timer = nil;
    [_scanLine removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
}

// Config the view of scanning area
- (void)setupScanAreaView {
    _scanAreaView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) * 0.25, (CGRectGetHeight(self.view.bounds) - CGRectGetWidth(self.view.bounds) * 0.5) * 0.5, CGRectGetWidth(self.view.bounds) * 0.5, CGRectGetWidth(self.view.bounds) *0.5)];
    _scanAreaView.layer.borderColor = [UIColor colorWithRed:211 / 255.0 green:211 / 255.0 blue:211 / 255.0 alpha:1.0].CGColor;
    _scanAreaView.layer.borderWidth = 1.0;
    [self.view addSubview:_scanAreaView];
    
    // Add the top left corner view
    UIColor *bgColor = [UIColor colorWithRed:56 / 255.0 green:196 / 255.0 blue:169 / 255.0 alpha:1.0];
    UIView *viewTLH = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 5)];
    viewTLH.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewTLH];
    
    UIView *viewTLV = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 5, 15)];
    viewTLV.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewTLV];
    
    // Add the top right corner view
    UIView *viewRTH = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scanAreaView.frame) - 20, 0, 20, 5)];
    viewRTH.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewRTH];
    
    UIView *viewRTV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scanAreaView.frame) - 5, 5, 5, 15)];
    viewRTV.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewRTV];
    
    // Add the bottom left corner view
    UIView *viewBLH = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_scanAreaView.frame) - 5, 20, 5)];
    viewBLH.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewBLH];
    
    UIView *viewBLV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_scanAreaView.frame) - 20, 5, 15)];
    viewBLV.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewBLV];
    
    // Add the bottom right corner view
    UIView *viewBRH = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scanAreaView.frame) - 20, CGRectGetHeight(_scanAreaView.frame) - 5, 20, 5)];
    viewBRH.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewBRH];
    
    UIView *viewBRV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scanAreaView.frame) - 5, CGRectGetHeight(_scanAreaView.frame) - 20, 5, 15)];
    viewBRV.backgroundColor = bgColor;
    [_scanAreaView addSubview:viewBRV];
}

// Config the scanning line and it's moving animation
- (void)setupScanLine {
    _scanLine = [[CALayer alloc] init];
    _scanLine.frame = CGRectMake(20, 0, CGRectGetWidth(_scanAreaView.frame) - 40, 3);
    _scanLine.contents = (__bridge id)([UIImage imageNamed:@"scanning-line"].CGImage);
    
    [_scanAreaView.layer addSublayer:_scanLine];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(moveScanLine) userInfo:nil repeats:YES];
    [_timer fire];
}

// Define the animation of moving the scan line
- (void)moveScanLine {
    CGRect rect = _scanLine.frame;
    if (CGRectGetMaxY(_scanLine.frame) + 5 > CGRectGetHeight(_scanAreaView.frame)) {
        rect.origin.y = 0;
        _scanLine.frame = rect;
    } else {
        rect.origin.y += 5;
        [UIView animateWithDuration:0.1 animations:^{
            _scanLine.frame = rect;
        }];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Judge the metadataObjects
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        // Judge the type of metadataObject
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"Scan Result: %@", [metadataObject stringValue]);
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
        }
    }
}

@end
