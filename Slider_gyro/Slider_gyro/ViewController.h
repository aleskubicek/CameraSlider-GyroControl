//
//  ViewController.h
//  Slider_gyro
//
//  Created by Aleš Kubiček on 14.11.15.
//  Copyright © 2015 Aleš Kubiček. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *iPhone;
@property (nonatomic, strong) CBPeripheral *HM10_module;

@end

