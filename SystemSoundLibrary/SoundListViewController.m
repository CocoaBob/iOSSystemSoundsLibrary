//
//  SoundListViewController.m
//  SystemSoundLibrary
//
//  Created by Anton Pauli on 12.10.13.
//  Copyright (c) 2013 Anton Pauli. All rights reserved.
//

#import "SoundListViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SoundListViewController ()

@property (nonatomic, strong) NSMutableArray *audioFileList;

@end

@implementation SoundListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAudioFileList];
    [self.tableView reloadData];
}

-(void)loadAudioFileList {
    self.audioFileList = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            [self.audioFileList addObject:url];
        }
    }
    [self.audioFileList sortUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
        return [[obj1 absoluteString] caseInsensitiveCompare:[obj2 absoluteString]];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.audioFileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSUInteger index = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%03ld: %@", (long)index, [self.audioFileList[index] lastPathComponent]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[self.audioFileList objectAtIndex:indexPath.row],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    NSLog(@"%@", [[self.audioFileList objectAtIndex:indexPath.row] description]);
}

@end
