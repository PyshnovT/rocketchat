//
//  RTCCollectionViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 27/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Parse/Parse.h>

#import "RTCCollectionViewController.h"
#import "RTCMainViewController.h"

#import "RTCMessageStore.h"
#import "RTCMessage.h"

#import "RTCMessageCollectionViewCell.h"
#import "RTCMessageCollectionViewLayout.h"

#import "RTCMediaStore.h"
#import "RTCMessageMedia.h"

#import "UIImage+Scale.h"

#import "RTCMapViewController.h"

#import <Parse/Parse.h>
#import <AdSupport/ASIdentifierManager.h>

#import "DAKeyboardControl.h"

@interface RTCCollectionViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSString *copiedText;

@end

@implementation RTCCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"RTCMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
    /*
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr]; <-- тут как бы удаление */ 
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForRotationNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self deregisterForRotationNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void)registerForRotationNotifications {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRotationNotification:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

- (void)deregisterForRotationNotifications {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
    }
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleRotationNotification:nil forSize:size];
}

- (void)handleRotationNotification:(NSNotification *)note {
    [self handleRotationNotification:note forSize:CGSizeZero];
}

- (void)handleRotationNotification:(NSNotification *)note forSize:(CGSize)size {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Adding messages

- (RTCMessage *)addMessageWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media withParseId:(NSString *)parseId {
    if ((text && media) || [text isEqualToString:@""]) return nil;
    

    
    RTCMessage *newMessage;
    
    if (text) {
        newMessage = [[RTCMessageStore sharedStore] createMessageWithDate:date text:text];
    } else if (media) {
        newMessage = [[RTCMessageStore sharedStore] createMessageWithDate:date media:media];
    } else if (parseId && !text) {
        newMessage = [[RTCMessageStore sharedStore] createMessageWithDate:date media:nil];
    }
    
    newMessage.parseId = parseId;
    
    if (!parseId) {
        [self addMessageToParse:newMessage];
    } else {
        newMessage.isSent = YES;
    }
  
    [self.collectionView reloadData];
    
    [self scrollToNewestMessage];
    
    return newMessage;
    
}

- (RTCMessage *)addMessageWithDate:(NSDate *)date text:(NSString *)text withParseId:(NSString *)parseId {
    return [self addMessageWithDate:date text:text media:nil withParseId:parseId];
}

- (RTCMessage *)addMessageWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media withParseId:(NSString *)parseId {
    return [self addMessageWithDate:date text:nil media:media withParseId:parseId];
}

- (void)addMessageToParse:(RTCMessage *)message {
    NSLog(@"Add Message to Parse");
    
    PFObject *messageObject = [PFObject objectWithClassName:@"Message"];
    
    if (message.media) {
        if ([message.media respondsToSelector:@selector(location)]) {
            if (message.media.location) {
               
                CLLocationCoordinate2D coordinate = message.media.location.coordinate;
                
                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];

                messageObject[@"location"] = point;
                
            }
        } else {

        }
        
        NSData *imageData = UIImagePNGRepresentation(message.media.image);
        PFFile *imageFile;
        
        if (imageData) {
            imageFile = [PFFile fileWithName:@"image.png" data:imageData];
            NSLog(@"%@", imageFile);
            
            messageObject[@"image"] = imageFile;
        }
        


    } else {
        messageObject[@"text"] = message.text;
    }
    
    NSLog(@"На отправку! %@", messageObject);
    
    
    
    if (!messageObject[@"text"] && !messageObject[@"image"]) return;
    
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    messageObject[@"deviceId"] = adId;//@"B1E33427-C0D9-4340-B390-3CEBB6596D18";//adId;
    
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            NSLog(@"Саксидед");
            
            NSUInteger messageIndex = [[[RTCMessageStore sharedStore] allMessages] indexOfObject:message];
            
            RTCMessageCollectionViewCell *cell = (RTCMessageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:messageIndex inSection:0]];

            message.isSent = YES;
            cell.ticketView.hidden = NO;
            
        } else {
            // There was a problem, check error.description
            NSLog(@"Не саксидед");
            NSLog(@"%@", error.description);
        }
    }];

}

#pragma mark - Scrolling

- (void)scrollToNewestMessage {
    [self.collectionView.collectionViewLayout prepareLayout];

    if (self.collectionViewLayout.collectionViewContentSize.height > self.collectionView.bounds.size.height) {
        
        CGFloat yOffset = MAX(0, self.collectionViewLayout.collectionViewContentSize.height - self.collectionView.bounds.size.height);
        
        [self.collectionView setContentOffset:CGPointMake(0, yOffset) animated:YES];
        
    }
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[RTCMessageStore sharedStore] allMessages].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RTCMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    RTCMessage *message = [[[RTCMessageStore sharedStore] allMessages] objectAtIndex:indexPath.row];
    
    cell.isMediaCell = message.media ? YES : NO;
    
    if (message.text) {
        
        cell.bubbleView.backgroundColor = [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1];
        cell.textLabel.text = message.text;
        
    } else if (message.media) {
     
        cell.bubbleView.backgroundColor = [UIColor clearColor];
        cell.ticketView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        cell.imageView.image = message.media.thumbnailImage;
        
        if ([message.media respondsToSelector:@selector(location)]) {
            if (message.media.location) {
                cell.location = message.media.location;
            }
        }
    } else { // при получении из интернета
        cell.bubbleView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        cell.bubbleHeightConstraint.constant = ((RTCMessageCollectionViewLayout *)self.collectionViewLayout).messageSize.height;
    }
    
    if (message.isSent) {
        cell.ticketView.hidden = NO;
    } else {
        cell.ticketView.hidden = YES;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RTCMessageCollectionViewCell *cell = (RTCMessageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isMediaCell) {
        
        if (cell.location) { // локация
            RTCMapViewController *mapViewController = [[RTCMapViewController alloc] initForSendingLocation:NO];
            mapViewController.sentLocation = cell.location;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
            
            [self presentViewController:navController animated:YES completion:nil];
        } else { // просто картиночка
            [self.mvc presentImageLookerControllerForCellAtIndexPath:indexPath];
        }
    } else {
        NSLog(@"select");
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        
        if (!menuController.isMenuVisible) {
            [self becomeFirstResponder];

            RTCMessage *message = [[[RTCMessageStore sharedStore] allMessages] objectAtIndex:indexPath.row];
            self.copiedText = message.text;
            
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyTextMessage:)];
            
            CGRect rectInCollectionView = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
            [menuController setTargetRect:rectInCollectionView inView:self.collectionView];
            menuController.menuItems = @[copyItem];
            
            [menuController setMenuVisible:YES animated:YES];
        } else {
            self.copiedText = nil;
            [menuController setMenuVisible:NO animated:YES];
        }
    }
}

#pragma mark - Copy

- (void)copyTextMessage:(id)sender {
    NSLog(@"copy %@", sender);
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.copiedText];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

/*
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        UICollectionViewCell* cell =
        [self.collectionView cellForItemAtIndexPath:indexPath];
        
        PFObject *object = [PFObject objectWithoutDataWithClassName:@"Message" objectId:<#(nullable NSString *)#>]
        // do stuff with the cell
    }
}
 */

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
