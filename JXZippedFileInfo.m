//
//  JXZippedFileInfo.m
//  odt-testbed
//
//  Created by Jan on 10.12.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXZippedFileInfo.h"

#import "JXZip.h"

NSString * const	JXZippedFileInfoErrorDomain			= @"de.geheimwerk.Error.JXZippedFileInfo";

#define kJXCouldNotAccessZippedFileInfo 1101


@implementation JXZippedFileInfo

- (JXZippedFileInfo *)initFileInfoWithArchive:(void *)archive fileName:(NSString *)fileName error:(NSError **)error;
{
	self = [super init];
	
	if (self) {
		if (archive == NULL)  return nil;
		
		struct zip *za = (struct zip *)archive;

		// CHANGEME: Add support for options/flags
		const char *file_name = [fileName UTF8String]; // autoreleased
		if (zip_stat(za, file_name, 0, &file_info) < 0) {
			if (error != NULL) {
				NSDictionary *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Could not access file info for “%@” in zipped file: %s", @"Cannot access file info in zipped file"), 
												  fileName, zip_strerror(za)];
				NSDictionary *errorDetail = [NSDictionary dictionaryWithObjectsAndKeys:
											 errorDescription, NSLocalizedDescriptionKey, 
											 nil];
				*error = [NSError errorWithDomain:JXZippedFileInfoErrorDomain code:kJXCouldNotAccessZippedFileInfo userInfo:errorDetail];
			}
			
			return nil;
		}
	}
	
	return self;
}

+ (JXZippedFileInfo *)zippedFileInfoWithArchive:(void *)archive fileName:(NSString *)fileName error:(NSError **)error;
{
	return [[[JXZippedFileInfo alloc] initFileInfoWithArchive:archive fileName:fileName error:error] autorelease];
}

- (void)dealloc
{
	
	[super dealloc];
}


- (NSString *)name;
{
	if (file_info.valid & ZIP_STAT_NAME) {
		// CHANGEME: We assume the file names are UTF-8.
		return [NSString stringWithCString:file_info.name encoding:NSUTF8StringEncoding];
	}
	else {
		return nil;
	}
}

- (NSUInteger)index;
{
	if (file_info.valid & ZIP_STAT_INDEX)  return (NSUInteger)file_info.index;
	else  return NSNotFound;
}

- (NSUInteger)size;
{
	if (file_info.valid & ZIP_STAT_SIZE)  return (NSUInteger)file_info.size;
	else  return NSNotFound;
}

- (NSUInteger)compressedSize;
{
	if (file_info.valid & ZIP_STAT_COMP_SIZE)  return (NSUInteger)file_info.comp_size;
	else  return NSNotFound;
}

- (NSDate *)modificationDate;
{
	if (file_info.valid & ZIP_STAT_MTIME) {
		return [NSDate dateWithTimeIntervalSince1970:file_info.mtime];
	}
	else {
		return nil;
	}
}

- (uint32_t)crc;
{
	if (file_info.valid & ZIP_STAT_CRC)  return (uint32_t)file_info.crc;
	else  return NSNotFound;
}

#if 0
- (uint16_t)compressionMethod;
- (uint16_t)encryptionMethod;
#endif


@end
