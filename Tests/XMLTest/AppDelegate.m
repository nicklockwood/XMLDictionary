//
//  AppDelegate.m
//  XMLTest
//
//  Created by Nick Lockwood on 28/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "XMLDictionary.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *URL = [[NSURL alloc] initWithString:@"http://www.ibiblio.org/xml/examples/shakespeare/all_well.xml"];
    NSString *string = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"string: %@", string);
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:string];
    NSLog(@"dictionary: %@", xmlDoc);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
