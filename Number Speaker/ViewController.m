//
//  ViewController.m
//  Number Speaker
//
//  Created by Joshua Sullivan on 11/11/12.
//  Copyright (c) 2012 Joshua Sullivan. All rights reserved.
//

#import "ViewController.h"

@import AVFoundation;

#define kMaximumNumberLength 16

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *outputLabel;
@property (nonatomic, strong) NSString *numberString;
@property (nonatomic, strong) NSString *spelledString;
@property (nonatomic, strong) NSNumberFormatter *inputFormatter;
@property (nonatomic, strong) NSNumberFormatter *outputFormatter;
@property (nonatomic, strong) NSNumberFormatter *spelledFormatter;

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberString = @"0";
    self.inputFormatter = [[NSNumberFormatter alloc] init];
    self.inputFormatter.numberStyle = NSNumberFormatterNoStyle;
    
    self.outputFormatter = [[NSNumberFormatter alloc] init];
    self.outputFormatter.groupingSeparator = @",";
    self.outputFormatter.groupingSize = 3;
    self.outputFormatter.usesGroupingSeparator = YES;
    
    self.spelledFormatter = [[NSNumberFormatter alloc] init];
    self.spelledFormatter.numberStyle = NSNumberFormatterSpellOutStyle;
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    [self updateDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Display the current number
- (void)updateDisplay
{
    if (self.numberString.length == 0) {
        self.outputLabel.attributedText = [self createFormattedString:@"0"];
    } else {
        self.outputLabel.attributedText = [self createFormattedString:self.numberString];
    }
}

#pragma mark - Format the string
- (NSAttributedString *)createFormattedString:(NSString *)string
{
    NSNumber *num = [self.inputFormatter numberFromString:string];
    NSString *numString = [self.outputFormatter stringFromNumber:num];
    self.spelledString = [self.spelledFormatter stringFromNumber:num];
    NSString *combinedString = [NSString stringWithFormat:@"%@\n%@", numString, self.spelledString];
    NSMutableAttributedString *outString = [[NSMutableAttributedString alloc] initWithString:combinedString];
    NSRange numRange = NSMakeRange(0, numString.length);
    NSRange spellRange = NSMakeRange(numRange.length + 1, self.spelledString.length);
    NSDictionary *spellDict = @{
        NSFontAttributeName : [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0],
        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1.0]
    };
    [outString addAttributes:spellDict range:spellRange];
    return outString;
}

#pragma mark - IBActions

- (IBAction)numberTouched:(id)sender
{
    NSInteger buttonValue = ((UIButton *)sender).tag;
    NSUInteger strLen = self.numberString.length;
    NSString *digitString = [NSString stringWithFormat:@"%d", buttonValue];
    [self speakString:digitString];
    
    if (strLen == 1) {
        if (buttonValue == 0) {
            return;
        }
        if ([self.numberString isEqualToString:@"0"]) {
            self.numberString = digitString;
        } else {
            self.numberString = [self.numberString stringByAppendingString:digitString];
        }
        
    } else {
        if (strLen >= kMaximumNumberLength) {
            return;
        }
        self.numberString = [self.numberString stringByAppendingString:digitString];
    }
    
    [self updateDisplay];
}

- (IBAction)deleteTouched:(id)sender
{
    NSUInteger strLen = self.numberString.length;
    if (strLen == 1) {
        self.numberString = @"0";
    } else if (strLen >= 2) {
        NSRange range = NSMakeRange(strLen - 1, 1);
        self.numberString = [self.numberString stringByReplacingCharactersInRange:range withString:@""];
    }
    [self updateDisplay];
}

- (IBAction)clearTouched:(id)sender
{
    self.numberString = @"0";
    [self updateDisplay];
}

- (IBAction)screenTouched:(id)sender
{
    [self speakString:self.numberString];
    
}

- (void)speakString:(NSString *)stringToSpeak
{
    if (self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:stringToSpeak];
    utterance.rate = 0.25f;
    [self.synthesizer speakUtterance:utterance];
}

@end
