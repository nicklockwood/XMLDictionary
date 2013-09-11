//
//  XMLDictionaryTests.m
//  XMLDictionaryTests
//
//  Created by Adam Kirk on 8/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "XMLDictionaryTests.h"
#import "XMLDictionary.h"

@implementation XMLDictionaryTests

- (void)setUp
{
    [super setUp];
    
    _XMLString = \
	@"<?xml version=\"1.0\" encoding=\"UTF-8\"?> \
	<stitches type=\"array\"> \
		<stitch> \
			<id type=\"integer\">14</id> \
			<thread-color>blue</thread-color> \
			<length>2</length> \
			<created-at type=\"datetime\">2011-11-26T17:37:51Z</created-at> \
			<updated-at type=\"datetime\">2011-11-26T17:37:52Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">15</id> \
			<thread-color>blue</thread-color>  \
			<length>3</length> \
			<created-at type=\"datetime\">2011-11-26T17:38:20Z</created-at> \
			<updated-at type=\"datetime\">2011-11-26T17:38:20Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">26</id> \
			<thread-color>blue</thread-color> \
			<length>2</length> \
			<created-at type=\"datetime\">2012-01-17T19:51:12Z</created-at> \
			<updated-at type=\"datetime\">2012-01-17T19:51:12Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">27</id> \
			<thread-color>blue</thread-color> \
			<length>2</length> \
			<created-at type=\"datetime\">2012-01-17T19:56:30Z</created-at> \
			<updated-at type=\"datetime\">2012-01-17T19:56:30Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">32</id> \
			<thread-color>blue</thread-color> \
			<length>3</length> \
			<created-at type=\"datetime\">2012-01-17T20:02:35Z</created-at> \
			<updated-at type=\"datetime\">2012-01-17T20:02:36Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">35</id> \
			<thread-color>blue</thread-color> \
			<length>3</length> \
			<created-at type=\"datetime\">2012-01-17T20:04:02Z</created-at> \
			<updated-at type=\"datetime\">2012-01-17T20:04:03Z</updated-at> \
		</stitch> \
		<stitch> \
			<id type=\"integer\">38</id> \
			<thread-color>blue</thread-color> \
			<length>3</length> \
			<created-at type=\"datetime\">2012-01-17T20:06:06Z</created-at> \
			<updated-at type=\"datetime\">2012-01-17T20:06:06Z</updated-at> \
		</stitch> \
	</stitches>";
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testFromXML
{
	NSDictionary *dictFromXML = [NSDictionary dictionaryWithXMLString:_XMLString];
	STAssertNotNil(dictFromXML, @"The dictionary was nil after loading XML");
	NSArray *stitches = [dictFromXML valueForKeyPath:@"stitch"];
	STAssertTrue(stitches.count > 0, @"No stitches were in the object");
}

- (void)testToXML
{
	NSDictionary *dict = @{ @"dogs" :  @{ @"dog" : @[ @{ @"name" : @"snoopy", @"breed" : @"golden retriever" }, @{ @"name" : @"fuzzball", @"breed" : @"german shepard" } ] } };
	NSString *xmlString = [dict xmlString];
	STAssertNotNil(xmlString, @"xml string was nil");
	STAssertTrue(xmlString.length > 0, @"The string was empty");
}


@end
