#import <substrate.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>



NSString* CSStringReader(char* stringPtr) {
    int stringLen = *((int*)(*( (long*)stringPtr ) + 0x10));
    char* cStringPtr = (char*)(*( (long*)stringPtr ) + 0x14);

    NSData *data = [[[NSData alloc] initWithBytesNoCopy:cStringPtr length: stringLen * 2 freeWhenDone:NO] autorelease];
    NSString * string = [[[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding] autorelease];
    return string;
}

static char* keyPtr = NULL;
long* (*orig_CriWareDecrypterConfig_ctor)(long* a1);

long* hacked_CriWareDecrypterConfig_ctor(long* a1) {
    long* instance = orig_CriWareDecrypterConfig_ctor(a1);
    if (keyPtr == NULL) {
        keyPtr = ((char*)instance + 0x10);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 10);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            NSString *key = CSStringReader(keyPtr);
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *keyNumber = [f numberFromString:key];
            [f release];
            NSLog(@"[CriWare Key Logger]Key: %@ hex: %0*lX", key, 16, [keyNumber longValue]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CriWare Key Logger" 
                message:[NSString stringWithFormat:@"Intercepted key: %@\nHex: %0*lX", key, 16, [keyNumber longValue]]
                delegate:nil 
                cancelButtonTitle:[[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Dismiss" value:@"" table:nil]
                otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    return (long*)instance;
}

%ctor
{
    @autoreleasepool
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: @"/Library/MobileSubstrate/DynamicLibraries/CRIKeyLogger.plist"];
        if ([[[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"] isEqualToString:dict[@"InjectAppID"]]){
            unsigned long CriWareDecrypterConfig_ctor = _dyld_get_image_vmaddr_slide(0) + [dict[@"InjectFunctionOffset"] longValue];
            MSHookFunction((void *)CriWareDecrypterConfig_ctor, (void *)hacked_CriWareDecrypterConfig_ctor, (void **)&orig_CriWareDecrypterConfig_ctor);
        }
    }
}



