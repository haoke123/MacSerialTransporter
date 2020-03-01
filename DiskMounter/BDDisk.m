//
//  BDDisk.m
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import "BDDisk.h"
//#import "FMNSFileManagerAdditions.h"

NSString * const BDDiskErrorDomain = @"BDDiskErrorDomain";

@interface BDDisk () {
	BDDiskDidUnmountBlock _unmountCompletionBlock;
	BDDiskDidMountBlock _mountCompletionBlock;
	BDDiskDidEjectBlock _ejectCompletionBlock;
}

- (void)_mountDidFinishWithError:(NSError *)error;
- (void)_unmountDidFinishWithError:(NSError *)error;
- (void)_ejectDidFinishWithError:(NSError *)error;

@end

// DA callbacks 
void bcDiskDidMount(DADiskRef disk, DADissenterRef dissenter, void *context)
{
	NSError *error = nil;
	if(dissenter != NULL)
	{
		int failureCode = DADissenterGetStatus(dissenter);
		NSString *failureReason = CFBridgingRelease(DADissenterGetStatusString(dissenter));
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
		error = [NSError errorWithDomain:BDDiskErrorDomain code:failureCode userInfo:errorInfo];
	}
	
	[(__bridge BDDisk *)context _mountDidFinishWithError:error];
}

void bcDiskDidUnmount(DADiskRef disk, DADissenterRef dissenter, void *context)
{
	NSError *error = nil;
	if(dissenter != NULL)
	{
		int failureCode = DADissenterGetStatus(dissenter);
		NSString *failureReason = CFBridgingRelease(DADissenterGetStatusString(dissenter));
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
		error = [NSError errorWithDomain:BDDiskErrorDomain code:failureCode userInfo:errorInfo];
	}
	
	[(__bridge BDDisk *)context _unmountDidFinishWithError:error];
}

void bcDiskDidEject(DADiskRef disk, DADissenterRef dissenter, void *context)
{
	NSError *error = nil;
	if(dissenter != NULL)
	{
		int failureCode = DADissenterGetStatus(dissenter);
		NSString *failureReason = CFBridgingRelease(DADissenterGetStatusString(dissenter));
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
		error = [NSError errorWithDomain:BDDiskErrorDomain code:failureCode userInfo:errorInfo];
	}
	
	[(__bridge BDDisk *)context _ejectDidFinishWithError:error];
}

#pragma mark -

@implementation BDDisk

+ (BDDisk *)diskWithRef:(DADiskRef)disk
{
	return [[BDDisk alloc] initWithDiskRef:disk];
}

- (id)initWithDiskRef:(DADiskRef)disk
{
	self = [super init];
	if(self)
	{
		CFRetain(disk);
		diskRef = disk;
	}
	return self;
}

- (void)dealloc
{
	CFRelease(diskRef);
	diskRef = nil;
	info = nil;
	_unmountCompletionBlock = nil;
}

#pragma mark -

- (NSUInteger)hash
{
	if(![[self diskDescription] objectForKey:@"DAVolumeUUID"])
		return [[self devicePath] hash];
	return [[self volumeUUIDString] hash];
}

- (BOOL)isEqual:(id)anObject
{
	return ([anObject hash] == [self hash]);
}

#pragma mark -

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BCDisk %p uuid=%@ device=%@ name=%@ fs=%@ mountPath=%@>", self, [self volumeUUIDString], [self devicePath], [self volumeName], [self filesystem], [self volumePath]];
}

- (NSDictionary *)diskDescription
{
	if(!info)
	{
		info = (NSDictionary *)CFBridgingRelease(DADiskCopyDescription(diskRef));
	}
	return info;
}

- (NSString *)BSDName
{
	return [[self diskDescription] objectForKey:@"DAMediaBSDName"];
}

- (NSString *)devicePath
{
	return [NSString stringWithFormat:@"/dev/%@", [self BSDName]];
}

- (NSString *)volumeName
{
	return [[self diskDescription] objectForKey:@"DAVolumeName"];
}

- (NSURL *)volumeURL
{
	return [[self diskDescription] objectForKey:@"DAVolumePath"];
}

- (NSString *)volumePath
{
	return [[self volumeURL] path];
}

- (NSString *)filesystem
{
	return [[self diskDescription] objectForKey:@"DAVolumeKind"];
}

- (NSString *)volumeUUIDString
{
	CFUUIDRef uuidRef = (__bridge CFUUIDRef)[[self diskDescription] objectForKey:@"DAVolumeUUID"];
	if(!uuidRef)
		return nil;
	NSString *string = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
	return string;
}

- (NSInteger)mediaSize
{
	return [[[self diskDescription] objectForKey:@"DAMediaSize"] integerValue];
}

- (NSImage *)icon
{
	if([self isMounted] && [self volumeURL])
	{
		NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[self volumePath]];
		if(image)
		{
			return image;
		}
	}
	
	return [[NSImage alloc] initByReferencingFile:@"/System/Library/Extensions/IOStorageFamily.kext/Contents/Resources/Internal.icns"];
}

- (BOOL)isRemovable
{
	return [[[self diskDescription] objectForKey:@"DAMediaRemovable"] boolValue];
}

- (BOOL)isDiskImage
{
	return [[[self diskDescription] objectForKey:@"DADeviceModel"] isEqualToString:@"Disk Image"];
}

- (NSString *)mediaName
{
	return [[self diskDescription] objectForKey:@"DAMediaName"];
}

- (NSString *)realDevicePath
{
	return [NSString stringWithFormat:@"/dev/r%@", self.BSDName];
}

#pragma mark -

- (BOOL)_boolForDescriptionKey:(NSString *)key
{
	if(![[self diskDescription] objectForKey:key])
		return NO;
	return [[[self diskDescription] objectForKey:key] boolValue];
}

- (BOOL)isWholeDisk
{
	return [self _boolForDescriptionKey:@"DAMediaWhole"];
}

- (BOOL)isMountable
{
	return [self _boolForDescriptionKey:@"DAVolumeMountable"];
}

- (BOOL)isNetwork
{
	return [self _boolForDescriptionKey:@"DAVolumeNetwork"];
}

- (BOOL)isMounted
{
	return ([self volumePath] != nil ? YES : NO);
}

- (BOOL)isCurrentSystem
{
	return ([[self volumePath] isEqualToString:@"/"]) ? YES : NO;
}

#pragma mark -

- (void)_mountDidFinishWithError:(NSError *)error
{
	if(_mountCompletionBlock)
	{
		info = nil; // make sure to get latest disk info, should have mount path now I hope
		_mountCompletionBlock([self volumeURL], error);
		_mountCompletionBlock = nil;
	}
}

- (void)mountWithCompletionHandler:(BDDiskDidMountBlock)handler
{
	if(!_mountCompletionBlock)
	{
        NSString *output = @"";
        NSString *error= @"";
        runProcessAsAdministrator(@"diskutil", [NSArray arrayWithObjects: @"mount", self.BSDName,nil],YES, &output, &error);
        if(error == nil){
            _mountCompletionBlock = handler;
            bcDiskDidMount(diskRef, NULL, (__bridge void*)self);
        }
 //   NSTask * task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/sudo" arguments: [NSArray arrayWithObjects:@"-S",@"diskutil", @"mount", self.BSDName,nil]];
       
		//_mountCompletionBlock = handler;
		//DADiskMount(diskRef, NULL, self.isWholeDisk ? kDADiskMountOptionWhole : kDADiskMountOptionDefault, bcDiskDidMount, (__bridge void*)self);
	}
}

- (void)_unmountDidFinishWithError:(NSError *)error
{
	if(_unmountCompletionBlock)
	{
		_unmountCompletionBlock(error);
		_unmountCompletionBlock = nil;
	}
}

- (void)unmountWithCompletionHandler:(BDDiskDidUnmountBlock)handler
{
	[self unmountWithCompletionHandler:handler force:NO];
}

- (void)unmountWithCompletionHandler:(BDDiskDidUnmountBlock)handler force:(BOOL)force
{
	if(!_unmountCompletionBlock)
	{
		DADiskUnmountOptions options = (self.isWholeDisk ? kDADiskUnmountOptionWhole : kDADiskUnmountOptionDefault) | (force ? kDADiskUnmountOptionForce : 0);
		_unmountCompletionBlock = handler;
		DADiskUnmount(diskRef, options, bcDiskDidUnmount, (__bridge void *)self);
	}
}

- (void)_ejectDidFinishWithError:(NSError *)error
{
	if(_ejectCompletionBlock)
	{
		_ejectCompletionBlock(error);
		_ejectCompletionBlock = nil;
	}
}

- (BOOL)ejectWithCompletionHandler:(BDDiskDidEjectBlock)handler
{
	BOOL result = NO;
	if(self.isRemovable)
	{
		DADiskEject(diskRef, kDADiskEjectOptionDefault, bcDiskDidEject, (__bridge void *)self);
		result = YES;
	}
	return result;
}
Boolean runProcessAsAdministrator( NSString *scriptPath, NSArray *arguments,BOOL isAdmin, NSString **output,NSString **errorDescription)
{
   NSString * allArgs = [arguments componentsJoinedByString:@" "];
   NSString *isAdminPre = @"";
   if (isAdmin) {
    isAdminPre = @"with administrator privileges";
   }
   NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
   NSDictionary *errorInfo = [NSDictionary new];
   NSString *script = [NSString stringWithFormat:@"do shell script \"%@\" %@", fullScript,      isAdminPre];
   NSLog(@"script = %@",script);
   NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
   NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
   // Check errorInfo/var/tmp
   if (! eventResult)
   {
       // Describe common errors
       *errorDescription = nil;
       if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
       {
           NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
           if ([errorNumber intValue] == -128)
            *errorDescription = @"The administrator password is required to do this.";
       }
       // Set error message from provided message
       if (*errorDescription == nil)
       {
           if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
            *errorDescription = (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
       }
       return NO;
   }
   else
   {
       // Set output to the AppleScript's output
    *output = [eventResult stringValue];
       return YES;
   }
}
@end
