//
//  ViewController.m
//  TestShell
//
//  Created by Emanuele  on 15/11/16.
//  Copyright © 2016 Emanuele . All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(IBAction)startServer:(id)sender{

    
    startingLabel.hidden = NO;
    stoppedLabel.hidden = YES;
    startedLabel.hidden = YES;
    
    startButton.enabled = NO;
    stopButton.enabled = NO;
    
    [spinner setHidden:NO];
    [spinner setIndeterminate:YES];
    [spinner setUsesThreadedAnimation:YES];
    [spinner startAnimation:nil];
    
    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //stoppo il server
        NSTask *task = [[NSTask alloc] init];
        NSString *launchPath = @"/Applications/LocandaServer9/bin/shutdown.sh";
        [task setLaunchPath:launchPath];
        [task launch];
        
        
        //avvio il server
        task = [[NSTask alloc] init];
        launchPath = @"/Applications/LocandaServer9/bin/catalina.sh";
        [task setLaunchPath:launchPath];
        [task setArguments:@[ @"run"]];
        [task launch];

    });
    
    
    [NSThread sleepForTimeInterval:5.0f];
    
    
    
    NSString *docPath = @"/Applications/LocandaServer9/logs";
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:docPath];
    
    NSString *filename;
    NSString *targetFile;
    NSDate *zeroDate = [NSDate dateWithTimeIntervalSince1970:0];
    while ((filename = [dirEnum nextObject])) {
        
        if ([filename rangeOfString:@"catalina."].location != NSNotFound){
            NSString *stringDate;
            stringDate = [filename stringByReplacingOccurrencesOfString:@"catalina." withString:@""];
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".log" withString:@""];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:stringDate];
            
            if([date compare:zeroDate] == NSOrderedDescending){
                targetFile = [@"/" stringByAppendingString:filename];
            }
        }
    }
    
    NSString *filePath = [docPath stringByAppendingString:targetFile];
    
    Boolean endReached = false;
    
    
    
    while(!endReached){
        [NSThread sleepForTimeInterval:1.0f];
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath];
        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        
        NSString *last = lines[[lines count] - 2];
        
        if([last rangeOfString:@"Server startup in"].location != NSNotFound){
            endReached = true;
            [self stopSpinner];
        }
    }
}

- (void) stopSpinner {
    [spinner setHidden:YES];
    startButton.enabled = YES;
    stopButton.enabled = YES;
    startedLabel.hidden = NO;
    startingLabel.hidden = YES;
}



-(IBAction)stopServer:(id)sender{
    startedLabel.hidden = YES;
    stoppedLabel.hidden = NO;
    
    //stoppo il server
    NSTask *task = [[NSTask alloc] init];
    NSString *launchPath = @"/Applications/LocandaServer9/bin/shutdown.sh";
    [task setLaunchPath:launchPath];
    [task launch];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    startedLabel.hidden = YES;
    stoppedLabel.hidden = NO;
    startingLabel.hidden = YES;
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
