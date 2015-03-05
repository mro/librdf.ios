//
// librdf_iosTests.m
// librdf.iosTests
//
// Created by Marcus Rohrmoser on 06.06.14.
// Copyright (c) 2014-2015 Marcus Rohrmoser mobile Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <redland.h>

@interface librdf_iosTests : XCTestCase
@end

@implementation librdf_iosTests


-(void)testSqlitePresence
{
    librdf_world *world = librdf_new_world();
    librdf_world_open(world);
    // List available storage factories.
    for( int counter = 0;; counter++ ) {
        const char *name = NULL;
        const char *label = NULL;
        if( 0 != librdf_storage_enumerate(world, counter, &name, &label) )
            break;
        if( 0 == strcmp("sqlite", name) ) {
            // how nice - found it.
            librdf_free_world(world);
            return;
        }
    }
    librdf_free_world(world);
    XCTFail(@ "storage factory 'sqlite' not present.");
}

@end
