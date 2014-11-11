//
//  UserTagsViewController.m
//  NewsBlur
//
//  Created by Samuel Clay on 11/10/14.
//  Copyright (c) 2014 NewsBlur. All rights reserved.
//

#import "UserTagsViewController.h"
#import "FeedTableCell.h"
#import "StoriesCollection.h"

@interface UserTagsViewController ()

@end

@implementation UserTagsViewController

@synthesize appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (NewsBlurAppDelegate *)[[UIApplication sharedApplication] delegate];
    tagsTableView = [[UITableView alloc] init];
    tagsTableView.delegate = self;
    tagsTableView.dataSource = self;
    tagsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);;
    tagsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tagsTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [tagsTableView sizeToFit];
    [tagsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)arrayUserTags {
    return [appDelegate.activeStory objectForKey:@"user_tags"];
}

- (NSArray *)arrayUserTagsNotInStory {
    NSArray *userTags = [self arrayUserTags];
    NSMutableArray *tags = [[NSMutableArray alloc] init];

    for (NSString *tagKey in [appDelegate.dictSavedStoryTags allKeys]) {
        NSString *tagName = [[appDelegate.dictSavedStoryTags objectForKey:tagKey]
                             objectForKey:@"feed_title"];
        if (![userTags containsObject:tagName]) {
            [tags addObject:tagName];
        }
    }
    
    return [tags sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 caseInsensitiveCompare:obj2];
    }];
}

#pragma mark - Table data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // Tagged
        return [[self arrayUserTags] count];
    } else if (section == 1) {
        // Untagged
        return [[self arrayUserTagsNotInStory] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) return 0;
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Saved Tags";
    } else if (section == 1) {
        return @"Available Tags";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString  *cellIdentifier = @"SavedCellIdentifier";
    FeedTableCell *cell = (FeedTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FeedTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        cell.appDelegate = appDelegate;
    }

    NSString *title;
    int count = 0;
    if (indexPath.section == 0) {
        // Tagged
        NSString *tagName = [[self arrayUserTags] objectAtIndex:indexPath.row];
        NSString *savedTagId = [NSString stringWithFormat:@"saved:%@", tagName];
        NSDictionary *tag = [appDelegate.dictSavedStoryTags objectForKey:savedTagId];
        title = [tag objectForKey:@"feed_title"];
        count = [[tag objectForKey:@"ps"] intValue];;
    } else if (indexPath.section == 1) {
        // Untagged
        NSString *tagName = [[self arrayUserTagsNotInStory] objectAtIndex:indexPath.row];
        NSString *savedTagId = [NSString stringWithFormat:@"saved:%@", tagName];
        NSDictionary *tag = [appDelegate.dictSavedStoryTags objectForKey:savedTagId];
        title = [tag objectForKey:@"feed_title"];
        count = [[tag objectForKey:@"ps"] intValue];
    }
    cell.feedFavicon = [appDelegate getFavicon:nil isSocial:NO isSaved:YES];
    cell.feedTitle     = title;
    cell.positiveCount = count;
    cell.neutralCount  = 0;
    cell.negativeCount = 0;
    cell.isSaved       = YES;
    
    [cell setNeedsDisplay];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *tagName = [[self arrayUserTags] objectAtIndex:indexPath.row];

        
    } else if (indexPath.section == 1) {
        NSString *tagName = [[self arrayUserTagsNotInStory] objectAtIndex:indexPath.row];
        NSMutableDictionary *story = [appDelegate.activeStory mutableCopy];

        [story setObject:[[story objectForKey:@"user_tags"] arrayByAddingObject:tagName] forKey:@"user_tags"];
        [appDelegate.storiesCollection markStory:story asSaved:YES];
        [appDelegate.storiesCollection syncStoryAsSaved:story];
    }
}

@end
