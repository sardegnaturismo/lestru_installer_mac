//
//  ViewController.m
//  TestShell
//
//  Created by Emanuele  on 15/11/16.
//  Copyright © 2016 Emanuele . All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

int numberOfRows = 0;
int countedRows = 0;
bool visible = YES;
NSString *fileContents;
NSArray *lines;
NSString *logsPath = @"/Applications/LocandaServer9/logs";


-(IBAction)startServer:(id)sender{
    
    //Thread che gestisce l'avvio del server tomcat
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //stoppo il server
        NSTask *task = [[NSTask alloc] init];
        NSString *launchPath = @"/Applications/LocandaServer9/bin/shutdown.sh";
        [task setLaunchPath:launchPath];
        [task launch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopped];
        });
        
        //avvio il server
        task = [[NSTask alloc] init];
        launchPath = @"/Applications/LocandaServer9/bin/catalina.sh";
        [task setLaunchPath:launchPath];
        [task setArguments:@[ @"run"]];
        [task launch];
        
    });
    //TODO: non so se necessario
    [NSThread sleepForTimeInterval:2.0f];
    
    
    //questo è il path dell'ultimo file di log
    NSString *logFilePath = [self getLogFile];
    
    
    
    numberOfRows = [lines count] + 1000;
    
    
    //thread che gestisce l'update della progress bar
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self starting];
        });
        
        
        for (NSInteger i = 1; i <= progressBar.maxValue; i = i + 1){
            
            fileContents = [NSString stringWithContentsOfFile:logFilePath];
            lines = [fileContents componentsSeparatedByString:@"\n"];
            NSString *last = lines[[lines count] - 2];
    
            if([last rangeOfString:@"Server startup in"].location == NSNotFound){
                [NSThread sleepForTimeInterval:1.0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressBar setDoubleValue:(double)i];
                    [progressBar displayIfNeeded];
                });
            }else{
                while(i <  progressBar.maxValue){
                    [NSThread sleepForTimeInterval:0.5];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressBar setDoubleValue:(double)i];
                        [progressBar displayIfNeeded];
                    });
                    i += 10;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self started];
                });
            }
        }
        
    });
    
    
    
}

- (void) stopped {
    progressBar.hidden = YES;
    [progressBar setDoubleValue:(double)0];
    
    startButton.enabled = YES;
    stopButton.enabled = YES;
    
    stoppedLabel.hidden = NO;
    startingLabel.hidden = YES;
    startedLabel.hidden = YES;
}

- (void) starting {
    progressBar.hidden = NO;
    
    stoppedLabel.hidden = YES;
    startingLabel.hidden = NO;
    startedLabel.hidden = YES;
}

- (void) started {
    progressBar.hidden = YES;
    
    startButton.enabled = YES;
    stopButton.enabled = YES;
    
    stoppedLabel.hidden = YES;
    startingLabel.hidden = YES;
    startedLabel.hidden = NO;
}

// metodo che ritorna il path all'ultimo file di log creato da catalina
- (NSString*) getLogFile{
    
    //genero il path al file di log.
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:logsPath];
    
    NSString *filename;
    NSString *targetFile;
    //data di riferimento
    NSDate *refDate = [NSDate dateWithTimeIntervalSince1970:0];
    while ((filename = [dirEnum nextObject])) {
        
        if ([filename rangeOfString:@"catalina."].location != NSNotFound){
            NSString *stringDate;
            stringDate = [filename stringByReplacingOccurrencesOfString:@"catalina." withString:@""];
            stringDate = [stringDate stringByReplacingOccurrencesOfString:@".log" withString:@""];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:stringDate];
            
            //se il log che sto analizzando è stato generato dopo la data di riferimento
            //lo considero
            if([date compare:refDate] == NSOrderedDescending){
                targetFile = [@"/" stringByAppendingString:filename];
                refDate = date;
            }
        }
    }
    
    NSString *logPath = [logsPath stringByAppendingString:targetFile];
    
    return logPath;
}



-(IBAction)stopServer:(id)sender{
    //stoppo il server
    NSTask *task = [[NSTask alloc] init];
    NSString *launchPath = @"/Applications/LocandaServer9/bin/shutdown.sh";
    [task setLaunchPath:launchPath];
    [task launch];
    
    [self stopped];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    progressBar.hidden = YES;
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
