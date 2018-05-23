//
//  ViewController.m
//  LAGQiniuUpload
//
//  Created by LAgagggggg on 2018/5/23.
//  Copyright © 2018 notme. All rights reserved.
//

#import "ViewController.h"
#import "UploadManager.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *UploadBtn;
@property (strong, nonatomic) IBOutlet UITextField *nameInputField;

@end

@implementation ViewController

- (IBAction)Upload:(id)sender {
    [[UploadManager sharedInstance]uploadImage:[UIImage imageNamed:@"LAGTestPhoto"] WithName:self.nameInputField.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

@end
