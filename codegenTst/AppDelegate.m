//
//  AppDelegate.m
//  codegenTst
//
//  Created by Eldhose on 30/10/12.
//  Copyright (c) 2012 Islet Systems. All rights reserved.
//

#import "AppDelegate.h"
#import "codeGenHeader.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{ 
    // Insert code here to initialize your application
   
    [_brwserTableList setPathSeparator:@"/"];
    [_btnGenFile setEnabled:FALSE];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "islet.codegenTst" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"islet.codegenTst"];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}


- (IBAction)OpenDatabaseSelected:(id)sender {
    
    int i; // Loop counter.
    [_btnGenFile setEnabled:FALSE];
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        
        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            NSURL* fileName = [files objectAtIndex:i];
            dbFilePath=fileName.absoluteString;
            NSLog(@"%@",fileName );
            // Do something with the filename.
        }
    }
    tableListAndCreateQuery=[[NSMutableDictionary alloc] init];
    
    [self getTableAndCreateQuery];
    
    [_brwserTableList loadColumnZero];
    _outTxtView.string=@"";
}

- (IBAction)clickedBrower:(NSBrowser *)sender {
    
    NSArray * paths=[sender.path componentsSeparatedByString:@"/"] ;
    selectedTableName=[paths objectAtIndex:1];
    NSString * tableQry=[tableListAndCreateQuery objectForKey:selectedTableName];
    NSArray *tempList=[[tableQry stringByReplacingOccurrencesOfString:@")" withString:@""] componentsSeparatedByString:@"("];
    NSArray *fieldLst=[[tempList objectAtIndex:tempList.count-1] componentsSeparatedByString:@","];
    NSString *tmpFieldName;
    NSString *tmpFieldType;
    int i;
    fieldNameAndType=[[NSMutableDictionary alloc] init];
    for (NSString *st in fieldLst) {
        NSLog(@"%@ \n",st);
        NSArray * ars=[st componentsSeparatedByString:@" "];
        i=0;
        tmpFieldType=@"";
        for (NSString * rt in ars) {
            if ([[rt stringByReplacingOccurrencesOfString:@" " withString:@""] length]>0) {
                if (i==0) {
                    tmpFieldName=rt;
                }
                else 
                {
                    tmpFieldType=[NSString stringWithFormat:@"%@ %@",tmpFieldType,rt];
                }
                i++;
                //[txt appendFormat:@"%@ \n",rt];
            }
        }
        [fieldNameAndType setObject:tmpFieldType forKey:tmpFieldName];
    }
    _outTxtView.string=fieldNameAndType.description;
   [_btnGenFile setEnabled:TRUE];
}

- (IBAction)btnGenerateFilesClicked:(NSButton *)sender {

    NSOpenPanel *savePanel=[[NSOpenPanel alloc] init];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setCanChooseDirectories:YES];
    [savePanel setCanChooseFiles:NO];
    if ( [savePanel runModal] == NSOKButton )
    {
        [self createHeaderFileForUrl:savePanel.URL];
        [self createImplemenationFileForUrl:savePanel.URL];
    }

}
-(void) createImplemenationFileForUrl:(NSURL *) url
{
    NSError *err;
    NSString * implementTemplate=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"implementTxt" ofType:@"txt"] encoding:NSStringEncodingConversionAllowLossy error:&err];
    implementTemplate=[implementTemplate stringByReplacingOccurrencesOfString:kTABLENAME withString:selectedTableName];
    NSMutableString *syncthesizeObjectList=[[NSMutableString alloc] init];
    for (NSString *key in [fieldNameAndType allKeys]) {
        NSString *tmpst=[kSYNTHESIZELISTITEM stringByReplacingOccurrencesOfString:kOBJECTNAME withString:key];
        [syncthesizeObjectList appendString:tmpst];
    }
    
    NSURL *filPath=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@Tble.m",selectedTableName]];
    implementTemplate=[implementTemplate stringByReplacingOccurrencesOfString:kSYNTHESIZELIST  withString:syncthesizeObjectList];
    NSLog(@"%@",implementTemplate);
    [implementTemplate writeToURL:filPath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&err];
    if (err) {
        NSLog(@"%@",err.localizedDescription);
    }
    
}

-(void) createHeaderFileForUrl:(NSURL *) url
{
    NSError *err;
    NSString * headerTemplate=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"headerTxt" ofType:@"txt"] encoding:NSStringEncodingConversionAllowLossy error:&err];
    headerTemplate=[headerTemplate stringByReplacingOccurrencesOfString:kTABLENAME withString:selectedTableName];
    headerTemplate=[headerTemplate stringByReplacingOccurrencesOfString:kCREATEQUERY withString:[tableListAndCreateQuery objectForKey:selectedTableName]];
    NSMutableString *localObjectList=[[NSMutableString alloc] init];
    NSMutableString *globalObjectList=[[NSMutableString alloc] init];
    for (NSString *key in [fieldNameAndType allKeys]) {
        NSString *typ=[[[fieldNameAndType objectForKey:key] componentsSeparatedByString:@" "] objectAtIndex:1];
        NSString *tmpst=[kOBJECTLISTLOCALITEM stringByReplacingOccurrencesOfString:kOBJECTNAME withString:key];
        NSString *tmpGlob=[kOBJECTLISTGLOBALITEM stringByReplacingOccurrencesOfString:kOBJECTNAME withString:key];
        if ([typ isEqualToString:@"TEXT"]) {
            tmpst=[tmpst stringByReplacingOccurrencesOfString:kNSTYPE withString:@"NSString"];
            tmpGlob=[tmpGlob stringByReplacingOccurrencesOfString:kNSTYPE withString:@"NSString"];
        }
        else if ([typ isEqualToString:@"INTEGER"])
        {
            tmpst=[tmpst stringByReplacingOccurrencesOfString:kNSTYPE withString:@"NSInteger"];
            tmpGlob=[tmpGlob stringByReplacingOccurrencesOfString:kNSTYPE withString:@"NSInteger"];
        }
        else
        {
            tmpst=[tmpst stringByReplacingOccurrencesOfString:kNSTYPE withString:@"id"];
            tmpGlob=[tmpGlob stringByReplacingOccurrencesOfString:kNSTYPE withString:@"id"];
        }
        [localObjectList appendString:tmpst];
        [globalObjectList appendString:tmpGlob];
    }
    

    NSURL *filPath=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@Tble.h",selectedTableName]];
    NSLog(@"%@",filPath.absoluteString);
    headerTemplate=[headerTemplate stringByReplacingOccurrencesOfString:kOBJECTLISTLOCAL  withString:localObjectList];
    headerTemplate=[headerTemplate stringByReplacingOccurrencesOfString:kOBJECTLISTGLOBAL withString:globalObjectList];
    NSLog(@"%@",headerTemplate);
    [headerTemplate writeToURL:filPath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&err];
    if (err) {
        NSLog(@"%@",err.localizedDescription);
    }
   
}
-(void) showTableDetails
{
    _outTxtView.string=@"";
    
}
#pragma Mark privateFunctions
-(void) getTableAndCreateQuery
{
    database = [FMDatabase databaseWithPath:dbFilePath];
    [database open];
    FMResultSet *results = [database executeQuery:@"select name,sql from sqlite_master where type='table'"];
    while([results next]) {
        NSString *name = [results stringForColumn:@"name"];
        NSString *sql  = [results stringForColumn:@"sql"];
        [tableListAndCreateQuery setValue:sql forKeyPath:name];
        
    }
    [database close];
}


#pragma mark NSBrowserDelegate
- (id)rootItemForBrowser:(NSBrowser *)browser {
       return tableListAndCreateQuery;
}
- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    if ([item isKindOfClass:[NSDictionary class]]) {
        return [[item allKeys] count];
    }
    return 0;
}
- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    if ([item isKindOfClass:[NSDictionary class]]) {
        return [[item allKeys] objectAtIndex:index];
    }
        return @"";
}
- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {

    return YES;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return item;
}

-(void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column {
    
     NSIndexPath *indexPath = [sender indexPathForColumn:column];
     indexPath = [indexPath indexPathByAddingIndex:row];
    [cell setTitle:[[tableListAndCreateQuery allKeys] objectAtIndex:row]];
}

@end
