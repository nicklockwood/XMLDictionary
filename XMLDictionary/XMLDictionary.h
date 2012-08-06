//
//  XMLDictionary.h
//
//  Version 1.0
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of XMLDictionary from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#xmldictionary
//  https://github.com/demosthenese/xmldictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

//	Updated by Adam Kirk on 8/6/2012
//	Copyright 2012 Mysterious Trousers. All rights reserved.
//	Converted to ARC, Added it to CocoaPods.

#import <Foundation/Foundation.h>


#define COLLAPSE_TEXT_NODES		YES
#define TRIM_WHITE_SPACE		YES

#define XML_ATTRIBUTES_KEY		@"__attributes"
#define XML_COMMENTS_KEY		@"__comments"
#define XML_TEXT_KEY			@"__text"
#define XML_NAME_KEY			@"__name"

#define XML_ATTRIBUTE_PREFIX	@"_"


@interface NSDictionary (XMLDictionary)

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data;
+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string;
+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path;

- (NSString *)attributeForKey:(NSString *)key;
- (NSDictionary *)attributes;
- (NSDictionary *)childNodes;
- (NSArray *)comments;
- (NSString *)nodeName;
- (NSString *)innerText;
- (NSString *)innerXML;
- (NSString *)xmlString;

@end


@interface NSString (XMLDictionary)

- (NSString *)xmlEncodedString;

@end

