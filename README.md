Purpose
--------------

XMLDictionary is a class designed to simplify parsing and generating of XML on iOS and Mac OS. XMLDictionary is built on top of the NSXMLParser classes, but behaves more like a DOM-style parser rather than SAX parser, in that it creates a tree of objects rather than generating events at the start and end of each node.

Unlike other DOM parsers, XMLDictionary does not attempt to replicate all of the nuances of the XML standard such as the ability to nest tags within text. If you need to represent something like an HTML document then XMLDictionary won't work for you. If you want to use XML as a data interchange format for passing nested data structures then XMLDictionary may well provide a simpler solution than other DOM-based parsers.


Installation
--------------

To install this, use cocoapods and add this to your Podfile: 

	pod 'XMLDictionary', :git => 'https://github.com/mysterioustrousers/XMLDictionary.git'



Configuration
---------------

You can use the following constants to tweak the default behaviour of XMLDictionary:

	COLLAPSE_TEXT_NODES - If YES, tags that contain only text and have no children or attributes will be collapsed into a single string object, simplifying traversal of the object tree.
	
	TRIM_WHITE_SPACE - If YES, leading and trailing white space will be trimmed from text nodes, and text nodes containing only white space will be omitted from the dictionary.

	XML_ATTRIBUTES_KEY - The key name for the dictionary of attributes stored in each node dictionary. If the XML_ATTRIBUTE_PREFIX setting is not nil then attributes will not be grouped in a separate dictionary and this key will not be used. If XML_ATTRIBUTES_KEY is set to nil or @"", node attributes will not be grouped in a separate dictionary object but they will still appear amongst the other dictionary children).
	
	XML_COMMENTS_KEY - The key name for XML comments. Set this to nil or @"" if you are not interested in preserving XML comments.
	
	XML_TEXT_KEY - The key name for text content to be stored in the dictionary. Set this to nil or @"" if you are not interested in preserving text content within nodes (not recommended).
	
	XML_NAME_KEY - The key name for storing the name of each tag within its dictionary. If you do not wish to store the name, set this to nil or @"" (the name will still be used as the key within the parent object).

	XML_ATTRIBUTE_PREFIX - The prefix for attributes stored within the dictionary. This is prepended to the names of all attributes to prevents name collisions with child nodes. If You are not concerned about name collisions, set this to nil or @"", in which case tags with names that collide with children will be omitted from the node dictionary (they will appear in the attributes dictionary, assuming the XML_ATTRIBUTES_KEY is not also nil).


Methods
------------

XMLDictionary extends NSDictionary with the following methods:

	+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data;
	
Create a new NSDictionary object from XML-encoded data.

	+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string;
	
Create a new NSDictionary object from XML-encoded string.
	
	+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path;

Create a new NSDictionary object from and XML-encoded file.

	- (NSString *)attributeForKey:(NSString *)key;
	
Get the XML attribute for a given key (key name should not include prefix).
	
	- (NSDictionary *)attributes;
	
Get a dictionary of all XML attributes for a given node's dictionary. If the node has no attributes then this will return nil.
	
	- (NSDictionary *)childNodes;
	
Get a dictionary of all child nodes for a given node's dictionary. If multiple nodes have the same name they will be grouped into an array. If the node has no children then this will return nil.
	
	- (NSArray *)comments;
	
Get an array of all comments for a given node. Note that the nesting relative to other nodes is not preserved. If the node has no comments then this will return nil.
	
	- (NSString *)nodeName;
	
Get the name of the node. If the name is not known this will return nil.
	
	- (NSString *)innerText;
	
Get the text content of the node. If the node has no text content, this will return nil;
	
	- (NSString *)innerXML;
	
Get the contents of the node as an XML-encoded string. This XML string will not include the container node itself.
	
	- (NSString *)xmlString;

Get the node and its content as an XML-encoded string. If the node name is not known, the top level tag will be called `<root>`.


Usage
--------

To load a XML file, simply write:

	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"someFile" ofType:@"xml"];
	NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
	
You can then iterate over the dictionary as you would with any other object tree, e.g. one loaded from a PLIST.

To access nested nodes and attributes, you can use the valueForKeyPath syntax. For example to get the string value of `<foo>` from the following XML:
	
	<root>
		<bar cliche="true">
			<foo>Hello World</foo>
		</bar>
		<banjo>Was his name-oh</banjo>
	</root>
	
You would write:

	NSString *foo = [xmlDoc valueForKeyPath:@"bar.foo"];
	
To get the cliche attribute of `bar`, you would write:

	NSString *barCliche = [xmlDoc valueForKeyPath:@"bar._cliche"];
	
Or:

	NSString *barCliche = [xmlDoc valueForKeyPath:@"bar.@attributes.cliche"];
	
The above examples assume that you are using the default settings for `COLLAPSE_TEXT_NODES` and `XML_ATTRIBUTE_PREFIX`. If `COLLAPSE_TEXT_NODES` is disabled then you would instead access `<foo>`'s value by writing:

	NSString *foo = [xmlDoc valueForKeyPath:@"bar.foo.@innerText"];