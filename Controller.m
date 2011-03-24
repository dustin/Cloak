//
//  Controller.m
//  AppHider
//
//  Created by Dustin Sallings on 2007/2/16.
//  Copyright 2007 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "Controller.h"

@implementation Controller

-(void)toggleItem:(id)sender {
	NSDictionary *p=[tracker objectAtIndex:[sender tag]];
	NSLog(@"Changing ignore state of %@", [p valueForKey:@"NSApplicationName"]);
	if([sender state] == NSOffState) {
		[tracker ignoreApp:p];
		[sender setState: NSOnState];
	} else {
		[tracker dontIgnoreApp:p];
		[sender setState: NSOffState];
	}
}

- (NSImage*)iconForApplication: (NSDictionary *)application
{
	// get the icon
	NSImage *applicationIcon = [[NSWorkspace sharedWorkspace]
		iconForFile: [application objectForKey:@"NSApplicationPath"]];

	NSSize size={20, 20};
    if(!NSEqualSizes([applicationIcon size], size)) {
		[applicationIcon setSize: size];
	}
    // done, return it 
    return applicationIcon;
}

-(void)showPrefs:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [prefs makeKeyAndOrderFront:sender];
}

-(void)showAbout:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

-(void)rebuildMenu {
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	// Remove existing items -- except quit at the bottom.
	while([appMenu numberOfItems] > 0) {
		[appMenu removeItemAtIndex: 0];
	}

	// About
	NSMenuItem *aboutItem=[[NSMenuItem alloc]
		initWithTitle: @"About App Hider"
		action:@selector(showAbout:) keyEquivalent:@""];
	[aboutItem setTarget: self];
	[aboutItem setEnabled:YES];
	[appMenu addItem: aboutItem];
	[aboutItem release];

	[appMenu addItem: [NSMenuItem separatorItem]];

	// Exclude header
	NSMenuItem *excludeItem=[[NSMenuItem alloc]
		initWithTitle: @"Exclude Apps:"
		action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""];
	[appMenu addItem: excludeItem];
	[excludeItem release];

	// Add an item for each application
	NSEnumerator *e = [[tracker currentApps] objectEnumerator];
    id anAppDict;
	int i=0;
	while((anAppDict = [e nextObject]) != nil) {
		NSMenuItem *item=[[NSMenuItem alloc]
			initWithTitle: [anAppDict valueForKey:@"NSApplicationName"]
			action:@selector(toggleItem:) keyEquivalent:@""];
		[item setEnabled:YES];
		[item setState: [tracker isIgnored:anAppDict] ? NSOnState : NSOffState];
		[item setTarget:self];
		[item setImage:[self iconForApplication:anAppDict]];
		[item setIndentationLevel:1];
		[item setTag:i++];
		[appMenu addItem:item];
		[item release];
	}

	// Add some common items
	[appMenu addItem: [NSMenuItem separatorItem]];

	// Prefs
	NSMenuItem *prefsItem=[[NSMenuItem alloc]
		initWithTitle: @"Preferences"
		action:@selector(showPrefs:) keyEquivalent:@""];
	[prefsItem setTarget: self];
	[prefsItem setEnabled:YES];
	[appMenu addItem: prefsItem];
	[prefsItem release];

	// Check for updates
	NSMenuItem *checkForUpdatesItem=[[NSMenuItem alloc]
		initWithTitle: @"Check for Updates"
		action:@selector(checkForUpdates:) keyEquivalent:@""];
	[checkForUpdatesItem setTarget: sparkleUpdater];
	[checkForUpdatesItem setEnabled:YES];
	[appMenu addItem: checkForUpdatesItem];
	[checkForUpdatesItem release];

	// Quit 
	NSMenuItem *quitItem=[[NSMenuItem alloc]
		initWithTitle: @"Quit App Hider"
		action:@selector(terminate:) keyEquivalent:@""];
	[quitItem setTarget: NSApp];
	[quitItem setEnabled:YES];
	[appMenu addItem: quitItem];
	[quitItem release];

	[pool release];
}

-(void)observeValueForKeyPath:(NSString *)path ofObject:(id)object
	change:(NSDictionary*)change context:(void *)context {

	[self rebuildMenu];
}

-(BOOL) inLoginItems {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
    BOOL rv = NO;
    
    [defaults addSuiteNamed:@"loginwindow"];
    
    NSMutableArray *loginItems=[[[defaults
                                  persistentDomainForName:@"loginwindow"]
                                 objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy];
    
    // Remove anything that looks like the current login item.
    NSString *myName=[[[NSBundle mainBundle] bundlePath] lastPathComponent];
    NSEnumerator *e=[loginItems objectEnumerator];
    id current=nil;
    while( (current=[e nextObject]) != nil) {
        if([[current valueForKey:@"Path"] hasSuffix:myName]) {
            rv = YES;
        }
    }
    
    [defaults release];
    return rv;
}

-(void) removeLoginItem:(id)sender {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
    
    [defaults addSuiteNamed:@"loginwindow"];
    
    NSMutableArray *loginItems=[[[defaults
                                  persistentDomainForName:@"loginwindow"]
                                 objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy];
    
    // Remove anything that looks like the current login item.
    NSString *myName=[[[NSBundle mainBundle] bundlePath] lastPathComponent];
    NSEnumerator *e=[loginItems objectEnumerator];
    id current=nil;
    while( (current=[e nextObject]) != nil) {
        if([[current valueForKey:@"Path"] hasSuffix:myName]) {
            NSLog(@"Removing login item: %@", [current valueForKey:@"Path"]);
            [loginItems removeObject:current];
            break;
        }
    }
    
    [defaults removeObjectForKey:@"AutoLaunchedApplicationDictionary"];
    [defaults setObject:loginItems forKey:
     @"AutoLaunchedApplicationDictionary"];
    
    // Use the corefoundation API since I can't figure out the other one.
    CFPreferencesSetValue((CFStringRef)@"AutoLaunchedApplicationDictionary",
                          loginItems, (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    [defaults release];
}

// XXX:  I need to make this be able to add or remove, and validate the current user wishes.
-(void)addToLoginItems:(id)sender {
    
    [self removeLoginItem: self];
    
    NSMutableDictionary * myDict=[[NSMutableDictionary alloc] init];
    NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
    
    [defaults addSuiteNamed:@"loginwindow"];
    
    NSLog(@"Adding login item: %@", [[NSBundle mainBundle] bundlePath]);
    [myDict setObject:[NSNumber numberWithBool:NO] forKey:@"Hide"];
    [myDict setObject:[[NSBundle mainBundle] bundlePath]
               forKey:@"Path"];
    
    NSMutableArray *loginItems=[[[defaults
                                  persistentDomainForName:@"loginwindow"]
                                 objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy];
    
    [loginItems addObject:myDict];
    [defaults removeObjectForKey:@"AutoLaunchedApplicationDictionary"];
    [defaults setObject:loginItems forKey:
     @"AutoLaunchedApplicationDictionary"];
    
    // Use the corefoundation API since I can't figure out the other one.
    CFPreferencesSetValue((CFStringRef)@"AutoLaunchedApplicationDictionary",
                          loginItems, (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    [defaults release];
    [myDict release];
    [loginItems release];
}

-(void)setInLoginItems:(BOOL)to {
    if (to) {
        [self addToLoginItems:self];
    } else {
        [self removeLoginItem:self];
    }
}

-(void)initStatusBar {
	statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength: 40.0];
	[statusItem setTitle: @"hide"];
	[statusItem setMenu: appMenu];
	[statusItem setEnabled:YES];
	[statusItem setHighlightMode:YES];
	[statusItem retain];
}

-(void)setDefaultDefaults {
	[[NSUserDefaults standardUserDefaults]
		registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:180.0], @"freq",
			[NSArray array], @"ignored", nil, nil]];
	// This looks dumb, but preferences doesn't work correctly without it
	[[NSUserDefaults standardUserDefaults]
		setFloat:[[NSUserDefaults standardUserDefaults] floatForKey:@"freq"]
		forKey:@"freq"];
}

-(void)awakeFromNib {
	[self setDefaultDefaults];

	[tracker addObserver:self forKeyPath:@"currentApps"
		options:NSKeyValueObservingOptionNew context:nil];

	[self initStatusBar];

	// Register to hear about new apps being launched
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:tracker selector:@selector(appLaunched:)
		name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:tracker selector:@selector(appQuit:)
		name:NSWorkspaceDidTerminateApplicationNotification object:nil];

	// Ask the menu to be built out a second after we start.  I don't think
	// I can control load order coming out of the NIB, and the notifications
	// might not come through at the right time, so just blast one through
	// after we've had time to load.
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self
		selector:@selector(rebuildMenu) userInfo:nil repeats:NO];
}

@end
