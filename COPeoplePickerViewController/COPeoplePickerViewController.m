//
//  COPeoplePickerViewController.m
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//

#import "COPeoplePickerViewController.h"


#pragma mark - COToken

@class COTokenField;

@interface COToken : UIButton
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, strong) COTokenField *container;

+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container;

@end

#pragma mark - COTokenField Interface & Delegate Protocol

@protocol COTokenFieldDelegate <NSObject>

// TODO: implement

@end

#define kTokenFieldFontSize 14.0
#define kTokenFieldPaddingX 6.0
#define kTokenFieldPaddingY 6.0
#define kTokenFieldTokenHeight (kTokenFieldFontSize + 4.0)
#define kTokenFieldMaxTokenWidth 260.0

@interface COTokenField : UIView <UITextFieldDelegate>
@property (nonatomic, weak) id<COTokenFieldDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *addContactButton;
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, readonly) CGFloat computedRowHeight;
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
  
  //[self.view addSubview:self.searchTableView];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - UITableViewDelegate

// TODO: implement

@end

#pragma mark - COTokenField Implementation

@implementation COTokenField
@synthesize delegate = delegate_;
@synthesize textField = textField_;
@synthesize addContactButton = addContactButton_;
@synthesize tokens = tokens_;

static NSString *kCOTokenFieldDetectorString = @"\u200B";

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.tokens = [NSMutableArray new];
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    // Setup contact add button
    self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addContactButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.addContactButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonFrame = self.addContactButton.frame;
    self.addContactButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX,
                                             CGRectGetHeight(self.bounds) - CGRectGetHeight(buttonFrame) - kTokenFieldPaddingY,
                                             buttonFrame.size.height,
                                             buttonFrame.size.width);
    
    [self addSubview:self.addContactButton];
    
    // Setup text field
    CGFloat textFieldHeight = self.computedRowHeight;
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kTokenFieldPaddingX,
                                                                   (CGRectGetHeight(self.bounds) - textFieldHeight) / 2.0,
                                                                   CGRectGetWidth(self.bounds) - CGRectGetWidth(buttonFrame) - kTokenFieldPaddingX * 3.0,
                                                                   textFieldHeight)];
    self.textField.opaque = NO;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.font = [UIFont systemFontOfSize:kTokenFieldFontSize];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.text = kCOTokenFieldDetectorString;
    self.textField.delegate = self;
    
    [self addSubview:self.textField];
    
    [self setNeedsLayout];
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

- (CGFloat)computedRowHeight {
  CGFloat buttonHeight = CGRectGetHeight(self.addContactButton.frame);
  return MAX(buttonHeight, (kTokenFieldPaddingY * 2.0 + kTokenFieldTokenHeight));
}

- (void)layoutSubviews {
  for (COToken *token in self.tokens) {
    [token removeFromSuperview];
  }
  NSUInteger row = 0;
  NSInteger tokenCount = self.tokens.count;
  
  CGFloat left = kTokenFieldPaddingX;
  CGFloat maxLeft = CGRectGetWidth(self.bounds) - kTokenFieldPaddingX;
  CGFloat rowHeight = self.computedRowHeight;
  
  for (NSInteger i=0; i<tokenCount; i++) {
    COToken *token = [self.tokens objectAtIndex:i];
    CGFloat right = left + CGRectGetWidth(token.bounds);
    if (right > maxLeft) {
      row++;
      left = kTokenFieldPaddingX;
    }
    
    // Adjust token frame
    CGRect tokenFrame = token.frame;
    tokenFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(tokenFrame)) / 2.0 + kTokenFieldPaddingY);
    token.frame = tokenFrame;
    
    left += CGRectGetWidth(tokenFrame) + kTokenFieldPaddingX;
    
    [self addSubview:token];
  }
  
  CGFloat maxLeftWithButton = maxLeft - kTokenFieldPaddingX - CGRectGetWidth(self.addContactButton.frame);
  if (maxLeftWithButton - left < 50) {
    row++;
    left = kTokenFieldPaddingX;
  }
  
  CGRect textFieldFrame = self.textField.frame;
  textFieldFrame.origin = CGPointMake(left, (CGFloat)row * rowHeight + (rowHeight - CGRectGetHeight(textFieldFrame)) / 2.0 + kTokenFieldPaddingY);
  textFieldFrame.size = CGSizeMake(maxLeftWithButton - left, CGRectGetHeight(textFieldFrame));
  self.textField.frame = textFieldFrame;
  
  CGRect tokenFieldFrame = self.frame;
  CGFloat minHeight = MAX(rowHeight, CGRectGetHeight(self.addContactButton.frame) + kTokenFieldPaddingY * 2.0);
  tokenFieldFrame.size.height = MAX(minHeight, CGRectGetMaxY(textFieldFrame) + kTokenFieldPaddingY);
  self.frame = tokenFieldFrame;
}

- (void)modifyToken:(COToken *)token {
  if (token != nil) {
    if (token.highlighted) {
      [token removeFromSuperview];
      [self.tokens removeLastObject];
      self.textField.hidden = NO;
    }
    else {
      token.highlighted = YES;
      self.textField.hidden = YES;
      [token setNeedsDisplay];
    }
    [self setNeedsLayout];
  }
}

- (void)modifyLastToken {
  [self modifyToken:[self.tokens lastObject]];
}

- (void)processToken:(NSString *)tokenText {
  COToken *token = [COToken tokenWithTitle:tokenText associatedObject:tokenText container:self];
  [self.tokens addObject:token];
  self.textField.text = kCOTokenFieldDetectorString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (string.length == 0 && [textField.text isEqualToString:kCOTokenFieldDetectorString]) {
    [self modifyLastToken];
    return NO;
  }
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSString *text = self.textField.text;
  if ([text length] > 1) {
    [self processToken:[text substringFromIndex:1]];
    [self setNeedsLayout];
  }
  return YES;
}

@end

#pragma mark - COToken

@implementation COToken
@synthesize title = title_;
@synthesize associatedObject = associatedObject_;
@synthesize container = container_;

+ (COToken *)tokenWithTitle:(NSString *)title associatedObject:(id)obj container:(COTokenField *)container {
  COToken *token = [self buttonWithType:UIButtonTypeCustom];
  token.associatedObject = obj;
  token.container = container;
  token.backgroundColor = [UIColor clearColor];
  
  UIFont *font = [UIFont systemFontOfSize:kTokenFieldFontSize];
  CGSize tokenSize = [title sizeWithFont:font];
  tokenSize.width = MIN(kTokenFieldMaxTokenWidth, tokenSize.width);
  tokenSize.width += kTokenFieldPaddingX * 2.0;
  
  tokenSize.height = MIN(kTokenFieldFontSize, tokenSize.height);
  tokenSize.height += kTokenFieldPaddingY * 2.0;
  
  token.frame = (CGRect){CGPointZero, tokenSize};
  token.titleLabel.font = font;
  
  [token setTitle:title forState:UIControlStateNormal];
  [token setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [token setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  
  return token;
}

- (void)drawRect:(CGRect)rect {
  NSLog(@"drawTokenHighlighted: %i", self.highlighted);
  
  CGFloat radius = CGRectGetHeight(self.bounds) / 2.0;
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextAddPath(ctx, path.CGPath);
  CGContextClip(ctx);
  
  NSArray *colors = nil;
  if (self.highlighted) {
    colors = [NSArray arrayWithObjects:
              (__bridge id)[UIColor colorWithRed:0.322 green:0.541 blue:0.976 alpha:1.0].CGColor,
              (__bridge id)[UIColor colorWithRed:0.235 green:0.329 blue:0.973 alpha:1.0].CGColor,
              nil];
  }
  else {
    colors = [NSArray arrayWithObjects:
              (__bridge id)[UIColor colorWithRed:0.863 green:0.902 blue:0.969 alpha:1.0].CGColor,
              (__bridge id)[UIColor colorWithRed:0.741 green:0.808 blue:0.937 alpha:1.0].CGColor,
              nil];
  }
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFTypeRef)colors, NULL);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, CGRectGetHeight(self.bounds)), 0);
  CGGradientRelease(gradient);
  CGContextRestoreGState(ctx);
  
  if (self.highlighted) {
    [[UIColor colorWithRed:0.275 green:0.478 blue:0.871 alpha:1.0] set];
  }
  else {
    [[UIColor colorWithRed:0.667 green:0.757 blue:0.914 alpha:1.0] set];
  }
  
  path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) cornerRadius:radius];
  [path setLineWidth:1.0];
  [path stroke];
}

@end
