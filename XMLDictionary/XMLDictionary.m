//
//  XMLDictionary.m
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

#import "XMLDictionary.h"


@interface XMLDictionaryParser : NSObject<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary *root;
@property (nonatomic, strong) NSMutableArray *stack;
@property (nonatomic, readonly) NSMutableDictionary *top;
@property (nonatomic, strong) NSMutableString *text;

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data;
+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path;
+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName;

@end


@implementation XMLDictionaryParser

@synthesize text;
@synthesize root;
@synthesize stack;

- (XMLDictionaryParser *)initWithXMLData:(NSData *)data
{
	if ((self = [super init]))
	{
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		[parser parse];
	}
	return self;
}

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data
{	
	return [[[XMLDictionaryParser alloc] initWithXMLData:data] root];
}

+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path
{	
	NSData *data = [NSData dataWithContentsOfFile:path];
	return [self dictionaryWithXMLData:data];
}

+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName
{	
    if ([node isKindOfClass:[NSArray class]])
    {
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[node count]];
        for (id individualNode in node)
        {
            [nodes addObject:[self xmlStringForNode:individualNode withNodeName:nodeName]];
        }
        return [nodes componentsJoinedByString:@"\n"];
    }
    else if ([node isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *attributes = [(NSDictionary *)node attributes];
        NSMutableString *attributeString = [NSMutableString string];
        for (NSString *key in [attributes allKeys])
        {
            [attributeString appendFormat:@" %@=\"%@\"", [key xmlEncodedString], [[attributes objectForKey:key] xmlEncodedString]];
        }
        
        NSString *innerXML = [node innerXML];
        if ([innerXML length])
        {
            return [NSString stringWithFormat:@"<%1$@%2$@>%3$@</%1$@>", nodeName, attributeString, innerXML];
        }
        else
        {
            return [NSString stringWithFormat:@"<%@%@/>", nodeName, attributeString];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"<%1$@>%2$@</%1$@>", nodeName, [[node description] xmlEncodedString]];
    }
}

- (NSMutableDictionary *)top
{
	return [stack lastObject];
}

- (void)endText
{
	if (TRIM_WHITE_SPACE)
	{
		self.text = (NSMutableString *)[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	if (text && ![text isEqualToString:@""] && [XML_TEXT_KEY length])
	{
		id existing = [self.top objectForKey:XML_TEXT_KEY];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:text];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, text, nil] forKey:XML_TEXT_KEY];
			}
		}
		else
		{
			[self.top setObject:text forKey:XML_TEXT_KEY];
		}
	}
	self.text = nil;
}

- (void)addText:(NSString *)_text
{	
	if (!text)
	{
		self.text = [NSMutableString stringWithString:_text];
	}
	else
	{
		[text appendString:_text];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	[self endText];
	
	NSMutableDictionary *node = [NSMutableDictionary dictionary];
	if ([XML_NAME_KEY length])
	{
		[node setObject:elementName forKey:XML_NAME_KEY];
	}
	if ([attributeDict count])
	{
		if ([XML_ATTRIBUTE_PREFIX length])
		{
			for (NSString *key in [attributeDict allKeys])
			{
				[node setObject:[attributeDict objectForKey:key]
						  forKey:[XML_ATTRIBUTE_PREFIX stringByAppendingString:key]];
			}
		}
		else if ([XML_ATTRIBUTES_KEY length])
		{
			[node setObject:attributeDict forKey:XML_ATTRIBUTES_KEY];
		}
		else
		{
			[node addEntriesFromDictionary:attributeDict];
		}
	}
	
	if (!self.top)
	{
		self.root = node;
		self.stack = [NSMutableArray arrayWithObject:node];
	}
	else
	{
		id existing = [self.top objectForKey:elementName];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:node];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, node, nil]
							  forKey:elementName];
			}
		}
		else
		{
			[self.top setObject:node forKey:elementName];
		}
		[stack addObject:node];
	}
}

- (NSString *)nameForNode:(NSDictionary *)node inDictionary:(NSDictionary *)dict
{
	if (node.nodeName)
	{
		return node.nodeName;
	}
	else
	{
		for (NSString *name in dict)
		{
			id object = [dict objectForKey:name];
			if (object == node)
			{
				return name;
			}
			else if ([object isKindOfClass:[NSArray class]])
			{
				if ([(NSArray *)object containsObject:node])
				{
					return name;
				}
			}
		}
	}
	return nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{	
	[self endText];
	if (COLLAPSE_TEXT_NODES &&
		!self.top.attributes &&
		!self.top.childNodes &&
        !self.top.comments &&
		self.top.innerText)
	{
		NSDictionary *node = self.top;
		[stack removeLastObject];
		NSString *nodeName = [self nameForNode:node inDictionary:self.top];
		if (nodeName)
		{
			id parentNode = [self.top objectForKey:nodeName];
			if ([parentNode isKindOfClass:[NSMutableArray class]])
			{
				[parentNode replaceObjectAtIndex:[parentNode count] - 1 withObject:node.innerText];
			}
			else
			{
				[self.top setObject:node.innerText forKey:nodeName];
			}
		}
	}
	else
	{
		[stack removeLastObject];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self addText:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	[self addText:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	if ([XML_COMMENTS_KEY length])
	{
		NSMutableArray *comments = [self.top objectForKey:XML_COMMENTS_KEY];
		if (!comments)
		{
			comments = [NSMutableArray arrayWithObject:comment];
			[self.top setObject:comments forKey:XML_COMMENTS_KEY];
		}
		else
		{
			[comments addObject:comment];
		}
	}
}

@end


@implementation NSDictionary(XMLDictionary)

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data
{
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path
{
	return [XMLDictionaryParser dictionaryWithXMLFile:path];
}

- (id)attributeForKey:(NSString *)key
{
	return [[self attributes] objectForKey:key];
}

- (NSDictionary *)attributes
{
	NSDictionary *attributes = [self objectForKey:XML_ATTRIBUTES_KEY];
	if (attributes)
	{
		return [attributes count]? attributes: nil;
	}
	else if ([XML_ATTRIBUTE_PREFIX length])
	{
		NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
        [filteredDict removeObjectsForKeys:@[XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY]];
        for (NSString *key in [filteredDict allKeys])
        {
            [filteredDict removeObjectForKey:key];
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict setObject:[self objectForKey:key] forKey:[key substringFromIndex:[XML_ATTRIBUTE_PREFIX length]]];
            }
        }
        return [filteredDict count]? filteredDict: nil;
	}
	return nil;
}

- (NSDictionary *)childNodes
{	
	NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
	[filteredDict removeObjectsForKeys:@[XML_ATTRIBUTES_KEY, XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY]];
	if ([XML_ATTRIBUTE_PREFIX length])
    {
        for (NSString *key in [filteredDict allKeys])
        {
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict removeObjectForKey:key];
            }
        }
    }
    return [filteredDict count]? filteredDict: nil;
}

- (NSArray *)comments
{
	return [self objectForKey:XML_COMMENTS_KEY];
}

- (NSString *)nodeName
{
	return [self objectForKey:XML_NAME_KEY];
}

- (id)innerText
{	
	id text = [self objectForKey:XML_TEXT_KEY];
	if ([text isKindOfClass:[NSArray class]])
	{
		return [text componentsJoinedByString:@"\n"];
	}
	else
	{
		return text;
	}
}

- (NSString *)innerXML
{	
	NSMutableArray *nodes = [NSMutableArray array];
	
	for (NSString *comment in [self comments])
	{
        [nodes addObject:[NSString stringWithFormat:@"<!--%@-->", [comment xmlEncodedString]]];
	}
    
    NSDictionary *childNodes = [self childNodes];
	for (NSString *key in childNodes)
	{
		[nodes addObject:[XMLDictionaryParser xmlStringForNode:[childNodes objectForKey:key] withNodeName:key]];
	}
	
    NSString *text = [self innerText];
    if (text)
    {
        [nodes addObject:[text xmlEncodedString]];
    }
	
	return [nodes componentsJoinedByString:@"\n"];
}

- (NSString *)xmlString
{	
	return [XMLDictionaryParser xmlStringForNode:self withNodeName:[self nodeName] ?: @"root"];
}

@end


@implementation NSString (XMLDictionary)

- (NSString *)xmlEncodedString
{	
	return [[[[self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
			  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
			 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
			stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
}

@end
