//
//  ViewController.h
//  TestShell
//
//  Created by Emanuele  on 15/11/16.
//  Copyright © 2016 Emanuele . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
{
    __weak IBOutlet NSButton *stopButton;
    __weak IBOutlet NSButton *startButton;
    __weak IBOutlet NSTextField *startedLabel;
    __weak IBOutlet NSTextField *stoppedLabel;
    __weak IBOutlet NSTextField *startingLabel;
    __weak IBOutlet NSProgressIndicator *progressBar;
}


-(IBAction)startServer:(id)sender;
-(IBAction)stopServer:(id)sender;


@end

