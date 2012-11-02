//
//  AppDelegate.h
//  codegenTst
//
//  Created by Eldhose on 30/10/12.
//  Copyright (c) 2012 Islet Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "/usr/include/sqlite3.h"
#import "FMDatabase.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSBrowserDelegate>
{

    __weak NSBrowser *_brwserTableList;
    __unsafe_unretained NSTextView *_outTxtView;
    NSString * dbFilePath;
    NSMutableDictionary * tableListAndCreateQuery;
    FMDatabase *database;
    NSMutableDictionary * fieldNameAndType;
    __weak NSButton *_btnGenFile;
    NSString *selectedTableName;
}
- (IBAction)generateAllClicked:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)OpenDatabaseSelected:(id)sender;
- (IBAction)clickedBrower:(NSBrowser *)sender;
- (IBAction)btnGenerateFilesClicked:(NSButton *)sender;

-(void) showTableDetails;
-(void) getTableAndCreateQuery;
-(void) createHeaderFileForUrl:(NSURL *) url;
-(void) createImplemenationFileForUrl:(NSURL *) url;


@property (unsafe_unretained) IBOutlet NSTextView *outTxtView;
@property (weak) IBOutlet NSBrowser *brwserTableList;
@property (weak) IBOutlet NSBrowser *bwserTableList;
@property (weak) IBOutlet NSButton *btnGenFile;
@end
