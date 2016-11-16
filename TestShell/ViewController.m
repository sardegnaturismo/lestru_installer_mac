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
        NSString *launchPath = @"/Applications/apache-tomcat-7.0.72/bin/shutdown.sh";
        [task setLaunchPath:launchPath];
        [task launch];
        
        
        //avvio il server
        task = [[NSTask alloc] init];
        launchPath = @"/Applications/apache-tomcat-7.0.72/bin/catalina.sh";
        [task setLaunchPath:launchPath];
        [task setArguments:@[ @"run"]];
        [task launch];

    });
    
    [NSTimer scheduledTimerWithTimeInterval:20.0
                                     target:self
                                   selector:@selector(stopSpinner:)
                                   userInfo:nil
                                    repeats:NO];
    
    
    
    
    NSLog(@"Finito!");
}

- (void) stopSpinner:(NSTimer*)t {
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
    NSString *launchPath = @"/Applications/apache-tomcat-7.0.72/bin/shutdown.sh";
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
