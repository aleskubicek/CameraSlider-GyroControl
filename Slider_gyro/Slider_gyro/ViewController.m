//
//  ViewController.m
//  Slider_gyro
//
//  Created by Aleš Kubiček on 14.11.15.
//  Copyright © 2015 Aleš Kubiček. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    CMMotionManager *cm_manager;
    UILabel *BT_state;
    UILabel *BT_devName;
    CBUUID *serviceUUID;
    CBUUID *characteristicUUID;
    CBCharacteristic *HM10_characteristic;
    CALayer *scale_layer;
    BOOL isZero;
    UISwitch *gyro_active;
    UIStepper *steperCode;
    UILabel *speedLabel;
}

@end

@implementation ViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    
    CALayer *header = [CALayer layer];
    header.frame = CGRectMake(0, 0, self.view.frame.size.width, 173/2);
    header.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0].CGColor;
    [self.view.layer addSublayer:header];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(90.0/2, 350.0/2, 198.0/2, 128.0/2);
    [left setBackgroundImage:[UIImage imageNamed:@"left_off.png"] forState:UIControlStateNormal];
    [left addTarget:self action:(@selector(LeftButtonPressedDown:)) forControlEvents:UIControlEventTouchDown];
    [left setBackgroundImage:[UIImage imageNamed:@"left_on.png"] forState:UIControlStateHighlighted];
    [left addTarget:self action:(@selector(LeftButtonReleased:)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:left];
    
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    right.frame = CGRectMake(351.0/2, 350.0/2, 198.0/2, 128.0/2);
    [right setBackgroundImage:[UIImage imageNamed:@"right_off.png"] forState:UIControlStateNormal];
    [right addTarget:self action:(@selector(RightButtonPressedDown:)) forControlEvents:UIControlEventTouchDown];
    [right setBackgroundImage:[UIImage imageNamed:@"right_on.png"] forState:UIControlStateHighlighted];
    [right addTarget:self action:(@selector(RightButtonReleased:)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:right];
    
    UIButton *shotCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    shotCamera.frame = CGRectMake(260.0/2, 670.0/2, 120.0/2, 118.0/2);
    [shotCamera setBackgroundImage:[UIImage imageNamed:@"button_off.png"] forState:UIControlStateNormal];
    [shotCamera setBackgroundImage:[UIImage imageNamed:@"button_on.png"] forState:UIControlStateHighlighted];
    [shotCamera addTarget:self action:@selector(shootFrame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shotCamera];

    
    UILabel *header_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 85.0/2, self.view.frame.size.width, 40.0/2)];
    header_title.text = @"Camera Slider - movement control";
    header_title.textAlignment = NSTextAlignmentCenter;
    header_title.font = [UIFont systemFontOfSize:34.0/2];
    header_title.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    [self.view addSubview:header_title];
    
    UILabel *gyro_switch = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 180.0/2, self.view.frame.size.width, 40.0/2)];
    gyro_switch.text = @"Gyroscope:";
    gyro_switch.textAlignment = NSTextAlignmentCenter;
    gyro_switch.font = [UIFont systemFontOfSize:20.0/2];
    gyro_switch.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:gyro_switch];
    
    gyro_active = [[UISwitch alloc] initWithFrame: CGRectMake(133, 120, 51, 31)];
    gyro_active.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0];
    gyro_active.tintColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0];
    gyro_active.layer.cornerRadius = 16.0;
    [gyro_active addTarget: self action: @selector(gyro_activation:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview: gyro_active];
    
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 187.0, self.view.frame.size.width, 80.0/2)];
    speedLabel.text = @"1";
    speedLabel.textAlignment = NSTextAlignmentCenter;
    speedLabel.font = [UIFont systemFontOfSize:75.0/2];
    speedLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:speedLabel];
    
    steperCode = [[UIStepper alloc] initWithFrame:CGRectMake(114, 247, 40, 20)];
    [steperCode addTarget:self action:@selector(stepChanged:) forControlEvents:UIControlEventValueChanged];
    steperCode.tintColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0];
    steperCode.maximumValue = 4;
    steperCode.minimumValue = 1;
    steperCode.stepValue=1.0;
    [self.view addSubview:steperCode];
    
    UILabel *monitor_header = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 842.0/2, self.view.frame.size.width, 20.0/2)];
    monitor_header.text = @"Communication monitor:";
    monitor_header.textAlignment = NSTextAlignmentCenter;
    monitor_header.font = [UIFont systemFontOfSize:25.0/2];
    monitor_header.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:monitor_header];
    
    CALayer *monitor_line = [CALayer layer];
    monitor_line.frame = CGRectMake(44.0/2, 873.0/2, 551.0/2, 3.0/2);
    monitor_line.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0].CGColor;
    [self.view.layer addSublayer:monitor_line];
    
    UILabel *BT_stateDes = [[UILabel alloc] initWithFrame:CGRectMake(42.0/2, 909.0/2, 280.0/2, 20.0/2)];
    BT_stateDes.text = @"Bluetooth state:";
    BT_stateDes.font = [UIFont systemFontOfSize:20.0/2];
    BT_stateDes.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:BT_stateDes];
    
    BT_state = [[UILabel alloc] initWithFrame:CGRectMake(415.0/2, 909.0/2, 180.0/2, 20.0/2)];
    BT_state.font = [UIFont systemFontOfSize:20.0/2];
    BT_state.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:BT_state];
    
    UILabel *BT_devDes = [[UILabel alloc] initWithFrame:CGRectMake(42.0/2, 950.0/2, 280.0/2, 20.0/2)];
    BT_devDes.text = @"Device name:";
    BT_devDes.font = [UIFont systemFontOfSize:20.0/2];
    BT_devDes.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:BT_devDes];
    
    BT_devName = [[UILabel alloc] initWithFrame:CGRectMake(415.0/2, 950.0/2, 180.0/2, 20.0/2)];
    BT_devName.font = [UIFont systemFontOfSize:20.0/2];
    BT_devName.textAlignment = NSTextAlignmentRight;
    BT_devName.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    [self.view addSubview:BT_devName];
    
    UILabel *footer_names = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 1095.0/2-10, self.view.bounds.size.width, 25.0/2+10)];
    footer_names.textAlignment = NSTextAlignmentCenter;
    footer_names.text = @"A.Kubiček, V.Kaniok";
    footer_names.font = [UIFont systemFontOfSize:30.0/2];
    footer_names.textColor = [UIColor colorWithRed:212.0/255 green:84.0/255 blue:78.0/255 alpha:1.0];
    [self.view addSubview:footer_names];
    
    UIImageView *roll_scale = [[UIImageView alloc] initWithFrame:CGRectMake(45.0/2, 573.0/2, 550.0/2, 66.0/2)];
    roll_scale.image = [UIImage imageNamed:@"scale.png"];
    [self.view addSubview:roll_scale];
    
    scale_layer = [CALayer layer];
    [self.view.layer addSublayer:scale_layer];
    [self.view bringSubviewToFront:roll_scale];
    
    self.iPhone = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    serviceUUID = [CBUUID UUIDWithString:@"FFE0"];
    characteristicUUID = [CBUUID UUIDWithString:@"FFE1"];
}


- (void)LeftButtonPressedDown:(id)sender {
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 20.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)LeftButtonReleased:(id)sender {
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 25.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)RightButtonPressedDown:(id)sender {
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 30.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)RightButtonReleased:(id)sender {
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 35.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)shootFrame:(id)sender {
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 150.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)gyro_activation:(id)sender {
    if (gyro_active.on) {
        [self runGyro];
    } else {
        [cm_manager stopDeviceMotionUpdates];
    }
}

- (void)stepChanged:(id)sender {
    speedLabel.text = [NSString stringWithFormat:@"%i", (int)steperCode.value];
    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", steperCode.value+100.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)runGyro {
    cm_manager = [[CMMotionManager alloc] init];
    cm_manager.deviceMotionUpdateInterval = 0.02;
    [cm_manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
        if (motion.attitude.roll*10 < 0) {
            if (motion.attitude.roll*10 < -10.0) {
                scale_layer.frame = CGRectMake(320/2-(-10)*27.5*(-1)/2, 588/2, (-10)*27.5*(-1)/2, 28/2);
                [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", -10.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
            } else {
                scale_layer.frame = CGRectMake(320/2-motion.attitude.roll*10*27.5*(-1)/2, 588/2, motion.attitude.roll*10*27.5*(-1)/2, 28/2);
                if (scale_layer.frame.size.width < 72.0/2) {
                    scale_layer.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0].CGColor;
                    if (isZero == true) {
                        [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 0.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
                        isZero = false;
                    }
                } else {
                    isZero = true;
                    scale_layer.backgroundColor = [UIColor colorWithRed:255.0/255 green:184.0/255 blue:82.0/255 alpha:1.0].CGColor;
                    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", motion.attitude.roll*10] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
                }
            }
        } else {
            if (motion.attitude.roll*10 > 10.0) {
                scale_layer.frame = CGRectMake(320/2, 588/2, 27.5*10/2, 28/2);
                [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 10.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
            } else {
                scale_layer.frame = CGRectMake(320/2, 588/2, 27.5*motion.attitude.roll*10/2, 28/2);
                if (scale_layer.frame.size.width < 72.0/2) {
                    scale_layer.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0].CGColor;
                    if (isZero == true) {
                        [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", 0.0] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
                        isZero = false;
                    }
                } else {
                    isZero = true;
                    scale_layer.backgroundColor = [UIColor colorWithRed:255.0/255 green:184.0/255 blue:82.0/255 alpha:1.0].CGColor;
                    [self.HM10_module writeValue:[[NSString stringWithFormat:@"%.2f ", motion.attitude.roll*10] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:HM10_characteristic type:CBCharacteristicWriteWithoutResponse];
                }
            }
        }
        
    }];

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            BT_state.text = @"powered off";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            break;
            
        case CBCentralManagerStatePoweredOn:
            BT_state.text = @"powered on";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            [self scanForPeripherals];
            break;
            
        case CBCentralManagerStateResetting:
            BT_state.text = @"resetting";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            break;
            
        case CBCentralManagerStateUnauthorized:
            BT_state.text = @"unauthorized";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            break;
            
        case CBCentralManagerStateUnknown:
            BT_state.text = @"unknown";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            break;
            
        case CBCentralManagerStateUnsupported:
            BT_state.text = @"unsupported";
            BT_state.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
            break;
            
        default:
            break;
    }
}

- (void)scanForPeripherals {
    [self.iPhone scanForPeripheralsWithServices:[NSArray arrayWithObject:serviceUUID] options:nil];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    [self.iPhone connectPeripheral:peripheral options:nil];
    self.HM10_module = peripheral;
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    if (self.HM10_module != peripheral) {
        self.HM10_module = peripheral;
        [self.iPhone connectPeripheral:peripheral options:nil];
    }
    [self scanForPeripherals];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    BT_state.text = @"disconnected";
    BT_state.textColor = [UIColor colorWithRed:212.0/255.0 green:84.0/255.0 blue:78.0/255.0 alpha:1.0];
    [self scanForPeripherals];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    BT_state.text = @"connected";
    BT_state.textColor = [UIColor colorWithRed:254.0/255 green:168.0/255 blue:45.0/255 alpha:1.0];
    BT_devName.text = [NSString stringWithFormat:@"%@", peripheral.name];
    [self.iPhone stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:[NSArray arrayWithObject:serviceUUID]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error)
        return;
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:[NSArray arrayWithObject:characteristicUUID] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error)
        return;
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:characteristicUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            HM10_characteristic = characteristic;
//            [self runGyro];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
}

//__________________________________________________________


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
