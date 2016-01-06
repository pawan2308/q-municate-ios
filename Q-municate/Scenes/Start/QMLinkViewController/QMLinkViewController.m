//
//  QMLinkViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 25.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMLinkViewController.h"

@implementation QMLinkViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // logic for tab bar controllers
    if (self.tabBarController) {
        
        NSUInteger index = [self.tabBarController.viewControllers indexOfObject:self];
        
        if (index == NSNotFound) NSAssert(nil, @"Must be QMLinkViewController class");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.storyboardName bundle:nil];
        id scene = [storyboard instantiateViewControllerWithIdentifier:self.sceneIdentifier];
        [scene setTabBarItem:self.tabBarItem];
        
        NSMutableArray *viewControllers = self.tabBarController.viewControllers.mutableCopy;
        [viewControllers replaceObjectAtIndex:index withObject:scene];
        
        [self.tabBarController setViewControllers:viewControllers.copy];
    }
}

@end
