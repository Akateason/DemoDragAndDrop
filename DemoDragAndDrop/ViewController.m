//
//  ViewController.m
//  DemoDragAndDrop
//
//  Created by teason23 on 2020/3/11.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIDragInteractionDelegate,UIDropInteractionDelegate>
@property (strong, nonatomic) UIDragInteraction *dragInteraction;
@property (strong, nonatomic) UIDropInteraction *dropInteraction;
@end

@implementation ViewController

- (UIDragInteraction *)dragInteraction {
    if (!_dragInteraction) {
        _dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
        _dragInteraction.allowsSimultaneousRecognitionDuringLift = YES;
        _dragInteraction.enabled = YES;
    }
    return _dragInteraction;
}

- (UIDropInteraction *)dropInteraction {
    if (!_dropInteraction) {
        _dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
        _dropInteraction.allowsSimultaneousDropSessions = YES;
    }
    return _dropInteraction;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addInteraction:self.dropInteraction];
    
    self.lb.userInteractionEnabled = self.img.userInteractionEnabled = YES;
    
    [self.lb addInteraction:self.dragInteraction];
    [self.img addInteraction:self.dragInteraction];
}



#pragma mark - UIDragInteractionDelegate

- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session {
    
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.lb.text];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
    
    NSItemProvider *provider1 = [[NSItemProvider alloc] initWithObject:self.img.image];
    UIDragItem *dragItem1 = [[UIDragItem alloc] initWithItemProvider:provider1];
    
    return @[dragItem,dragItem1];
}

//- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session{
//}

- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    NSLog(@"willAnimateLiftWithAnimator:session:");
}

/* Called when the drag has moved (because the user's touch moved).
 * Use -[UIDragSession locationInView:] to get its new location.
 */
- (void)dragInteraction:(UIDragInteraction *)interaction sessionDidMove:(id<UIDragSession>)session {
    CGPoint pt = [session locationInView:self.view];
    self.lbPt.text = NSStringFromCGPoint(pt);
}

- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator {
    NSLog(@"item:willAnimateCancelWithAnimator:");
}

- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation {
    NSLog(@"session:didEndWithOperation:");
}

//- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
//}


#pragma mark - UIDropInteractionDelegate

- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    return  [session canLoadObjectsOfClass:[UIImage class]] ||
            [session canLoadObjectsOfClass:[NSString class]] ;
}

- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session {
    NSLog(@"sessionDidEnter");
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    CGPoint pt = [session locationInView:self.view];
    self.lbPt.text = NSStringFromCGPoint(pt);
    
    // 应用内UIDropOperationMove, 应用外UIDropOperationCopy
    // TODO: 应用内要看编辑器什么情况, 这里可能要调整
    UIDropOperation dropOperation = session.localDragSession ? UIDropOperationMove : UIDropOperationCopy;
    UIDropProposal *dropProposal = [[UIDropProposal alloc] initWithDropOperation:dropOperation];
    return dropProposal;
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    NSLog(@"performDrop : %@",session.localDragSession ? @"应用内":@"应用外");
    
    if ([session canLoadObjectsOfClass:[NSString class]]) {
        [session loadObjectsOfClass:[NSString class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
            if (session.localDragSession) {
                self.lbInner.text = objects.firstObject;
            } else {
                self.lb.text = objects.firstObject;
            }
        }];
    }
    
    if ([session canLoadObjectsOfClass:[UIImage class]]){
        [session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
            if (session.localDragSession) {
                self.imgInner.image = objects.lastObject;
            } else {
                self.img.image = objects.lastObject;
            }
        }];
    }
}

//- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
//
//}

//- (void)dropInteraction:(UIDropInteraction *)interaction item:(UIDragItem *)item willAnimateDropWithAnimator:(id<UIDragAnimating>)animator {
//}

@end
