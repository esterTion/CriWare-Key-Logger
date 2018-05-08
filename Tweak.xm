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
            NSLog(@"[CriWare Key Logger]Key: %@ hex: %0*llX", key, 16, [keyNumber longLongValue]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CriWare Key Logger" 
                message:[NSString stringWithFormat:@"Intercepted key: %@\nHex: %0*llX", key, 16, [keyNumber longLongValue]]
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
            NSNumber *offset = (NSNumber*)dict[@"InjectFunctionOffset"];
            unsigned long CriWareDecrypterConfig_ctor = _dyld_get_image_vmaddr_slide(0) + [offset longValue];

            // check instruction F44FBEA9
            unsigned char *chk = (unsigned char*)CriWareDecrypterConfig_ctor;
            if (*chk == 0xF4 && *(chk + 1) == 0x4F && *(chk + 2) == 0xBE && *(chk + 3) == 0xA9)
                MSHookFunction((void *)CriWareDecrypterConfig_ctor, (void *)hacked_CriWareDecrypterConfig_ctor, (void **)&orig_CriWareDecrypterConfig_ctor);
            else {
                NSLog(@"[CriWare Key Logger]Specified address 0x%08lx seems not a function, quit injecting", [offset longValue]);
            }
        }
    }
}



