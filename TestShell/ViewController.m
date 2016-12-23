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
NSString *fileContents;
NSArray *lines;
NSString *logsPath = @"/Applications/LocandaServer9/logs";


-(IBAction)startServer:(id)sender{

    startingLabel.hidden = NO;
    stoppedLabel.hidden = YES;
    startedLabel.hidden = YES;
    
    startButton.enabled = NO;
    stopButton.enabled = NO;
    
    //Thread che gestisce l'avvio del server tomcat
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
    //TODO: non so se necessario
    [NSThread sleepForTimeInterval:5.0f];
    
    
    //questo è il path dell'ultimo file di log
    NSString *logFilePath = [self getLogFile];
    fileContents = [NSString stringWithContentsOfFile:logFilePath];
    lines = [fileContents componentsSeparatedByString:@"\n"];
    
    numberOfRows = [lines count] + 1000;
    
    
    //thread che gestisce l'update della progress bar
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //fintanto che le righe contate sono minori di quelle complessive aggiorno la bar
        while(countedRows < numberOfRows){
            [NSThread sleepForTimeInterval:1.0f];
            //TODO: update bar
            [progressBar incrementBy:1.0];
            
            Boolean endReached = false;
            while(!endReached){
                
                [NSThread sleepForTimeInterval:1.0f];
                
                fileContents = [NSString stringWithContentsOfFile:logFilePath];
                lines = [fileContents componentsSeparatedByString:@"\n"];
                
                countedRows = [lines count];
                
                NSString *last = lines[[lines count] - 2];
                
                if([last rangeOfString:@"Server startup in"].location != NSNotFound){
                    endReached = true;
                    [self stopSpinner];
                }
            }
        }
    });
    
    
    
}

- (void) stopSpinner {
    startButton.enabled = YES;
    stopButton.enabled = YES;
    startedLabel.hidden = NO;
    startingLabel.hidden = YES;
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
