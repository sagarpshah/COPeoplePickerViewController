//
//  COPeoplePickerViewController.m
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//

#import "COPeoplePickerViewController.h"


#pragma mark - COTokenField Interface & Delegate Protocol

@class COTokenField;

@protocol COTokenFieldDelegate <NSObject>
@required

- (void)tokenField:(COTokenField *)tokenField textChanged:(NSString *)text;
- (void)tokenFieldDidReturn:(COTokenField *)tokenField;

@end

@interface COTokenField : UIView <UITextFieldDelegate>
@property (nonatomic, weak) id<COTokenFieldDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *addContactButton;
@end

#pragma mark - COPeoplePickerViewController

@interface COPeoplePickerViewController () <UITableViewDelegate, UITableViewDataSource, COTokenFieldDelegate>
@property (nonatomic, strong) COTokenField *tokenField;
@property (nonatomic, strong) UITableView *searchTableView;
@end

@implementation COPeoplePickerViewController
@synthesize tokenField = tokenField_;
@synthesize searchTableView = searchTableView_;

- (void)viewDidLoad {
  // Configure content view
  self.view.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.925 alpha:1.0];
  
  // Configure token field
  CGRect viewBounds = self.view.bounds;
  CGRect tokenFieldFrame = CGRectMake(0, 0, CGRectGetWidth(viewBounds), 44.0);
  self.tokenField = [[COTokenField alloc] initWithFrame:tokenFieldFrame];
  self.tokenField.delegate = self;
  self.tokenField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  
  [self.view addSubview:self.tokenField];
  
  // Configure search table
  self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMaxY(self.tokenField.bounds),
                                                                       CGRectGetWidth(viewBounds),
                                                                       CGRectGetHeight(viewBounds) - CGRectGetHeight(tokenFieldFrame))
                                                      style:UITableViewStylePlain];
  self.searchTableView.opaque = NO;
  self.searchTableView.backgroundColor = [UIColor clearColor];
  self.searchTableView.dataSource = self;
  self.searchTableView.delegate = self;
  self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  
  [self.view addSubview:self.searchTableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - UITableViewDelegate

// implement

#pragma mark - COTokenFieldDelegate

- (void)tokenField:(COTokenField *)tokenField textChanged:(NSString *)text {
  NSLog(@"%s", (char *)_cmd);
}

- (void)tokenFieldDidReturn:(COTokenField *)tokenField {
  NSLog(@"%s", (char *)_cmd);
}

@end

#pragma mark - COTokenField Implementation

@implementation COTokenField
@synthesize delegate = delegate_;
@synthesize textField = textField_;
@synthesize addContactButton = addContactButton_;

#define kTokenFieldFontSize 14.0
#define kTokenFieldRowHeight 44.0
#define kTokenFieldAddContactButtonPadding 6.0
#define kTokenFieldTextFieldPadding 6.0

- (id)initWithFrame:(CGRect)frame {
  frame.size.height = kTokenFieldRowHeight;
  self = [super initWithFrame:frame];
  if (self) {
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    // Setup contact add button
    self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addContactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonFrame = self.addContactButton.frame;
    self.addContactButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldAddContactButtonPadding,
                                             (CGRectGetHeight(self.bounds) - CGRectGetHeight(buttonFrame)) / 2.0,
                                             buttonFrame.size.height,
                                             buttonFrame.size.width);
    
    [self addSubview:self.addContactButton];
    
    // Setup text field
    CGFloat textFieldHeight = kTokenFieldFontSize + 4.0;
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldTextFieldPadding,
                                                                   (CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0,
                                                                   CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldAddContactButtonPadding - kTokenFieldTextFieldPadding * 2.0,
                                                                   textFieldHeight)];
    self.textField.opaque = NO;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.delegate = self;
    
    [self addSubview:self.textField];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextMoveToPoint(ctx, 0, CGRectGetHeight(self.bounds));
  CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.0 alpha:0.5].CGColor);
  CGContextStrokePath(ctx);
}

- (void)addContact:(id)sender {
  NSLog(@"%s", (char *)_cmd);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  [self.delegate tokenField:self textChanged:self.textField.text];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.delegate tokenFieldDidReturn:self];
  return YES;
}

@end