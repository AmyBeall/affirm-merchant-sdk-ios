//
//  AffirmUtils.m
//  AffirmSDK
//
//  Created by Victor Zhu on 2019/3/4.
//  Copyright © 2019 Affirm, Inc. All rights reserved.
//

#import "AffirmUtils.h"
#import "AffirmConfiguration.h"
#import "AffirmLogger.h"

@implementation NSDictionary (Utils)

- (NSString *)queryURLEncoding
{
    NSMutableArray<NSString *> *parametersArray = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *queryString = [[NSString stringWithFormat:@"%@", obj] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, queryString]];
    }];
    return [parametersArray componentsJoinedByString:@"&"];
}

- (NSError *)convertToNSErrorWithCode:(NSNumber *)code
{
    return [NSError errorWithDomain:AffirmSDKErrorDomain
                               code:[code integerValue]
                           userInfo:self.appendErrorDescription];
}

- (NSError *)convertToNSError
{
    return [self convertToNSErrorWithCode:@(-1)];
}

- (NSDictionary *)appendErrorDescription
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:self];
    if (self[@"message"]) {
        [userInfo addEntriesFromDictionary: @{NSLocalizedDescriptionKey: self[@"message"]}];
    }
    return userInfo;
}

@end

@implementation NSBundle (Utils)

+ (NSBundle *)sdkBundle
{
    return [NSBundle bundleForClass:[AffirmConfiguration class]];
}

+ (NSBundle *)resourceBundle
{
    return [NSBundle bundleWithPath:[self.sdkBundle pathForResource:@"AffirmSDK" ofType:@"bundle"]];
}

@end

@implementation NSString (Utils)

- (NSDictionary *)convertToDictionary
{
    if (self == nil) {
        return nil;
    }
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
    if (error) {
        return nil;
    }
    return dict;
}

@end

@implementation NSDecimalNumber (Utils)

- (NSDecimalNumber *)toIntegerCents
{
    if (self == [NSDecimalNumber notANumber]) {
        [[AffirmLogger sharedInstance] logException:@"NaN can't be convert to cents"];
    }
    
    NSDecimalNumberHandler *round = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                           scale:0
                                                                                raiseOnExactness:YES
                                                                                 raiseOnOverflow:YES
                                                                                raiseOnUnderflow:YES
                                                                             raiseOnDivideByZero:YES];
    return [self decimalNumberByMultiplyingByPowerOf10:2 withBehavior:round];
}

@end

@implementation AffirmValidationUtils

+ (void)checkNotNil:(id)value
               name:(NSString *)name
{
    if (value == nil) {
        [[AffirmLogger sharedInstance] logException:[NSString stringWithFormat:@"%@ must not be nil", name]];
    }
}

+ (void)checkNotNegative:(NSDecimalNumber *)value
                    name:(NSString *)name
{
    if ([value compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        [[AffirmLogger sharedInstance] logException:[NSString stringWithFormat:@"%@ must not be negative", name]];
    }
}

@end
