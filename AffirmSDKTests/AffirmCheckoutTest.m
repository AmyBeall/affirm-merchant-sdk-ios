//
//  AffirmCheckoutTest.m
//  AffirmSDKTests
//
//  Created by Paul on 3/21/19.
//  Copyright © 2019 Affirm, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AffirmConfiguration.h"
#import "AffirmCheckout.h"
#import "AffirmItem.h"
#import "AffirmShippingDetail.h"
#import "AffirmDiscount.h"
#import "AffirmUtils.h"
#import "AffirmRequest.h"
#import "AffirmClient.h"

@interface AffirmCheckoutTest : XCTestCase

@property (nonatomic, strong) AffirmItem *item;
@property (nonatomic, strong) AffirmShippingDetail *shipping;
@property (nonatomic, strong) AffirmDiscount *discount;
@property (nonatomic, strong) AffirmCheckout *checkout;

@end

@implementation AffirmCheckoutTest

- (void)setUp
{
    self.continueAfterFailure = NO;
    _item = [AffirmItem itemWithName:@"Affirm Test Item" SKU:@"test_item" unitPrice:[NSDecimalNumber decimalNumberWithString:@"15.00"] quantity:1 URL:[NSURL URLWithString:@"http://sandbox.affirm.com/item"]];
    _shipping = [AffirmShippingDetail shippingDetailWithName:@"Test Tester" addressWithLine1:@"325 Pacific Ave." line2:@"" city:@"San Francisco" state:@"CA" zipCode:@"94111" countryCode:@"USA"];
    _discount = [AffirmDiscount discountWithName:@"Affirm Test Discount" amount:[NSDecimalNumber decimalNumberWithString:@"3.00"]];
    _checkout = [AffirmCheckout checkoutWithItems:@[_item] shipping:_shipping taxAmount:[NSDecimalNumber decimalNumberWithString:@"1.00"] shippingAmount:[NSDecimalNumber decimalNumberWithString:@"5.00"]];
}

- (void)testAffirmItem {
    NSDictionary *item = @{
                           @"display_name": @"Affirm Test Item",
                           @"sku": @"test_item",
                           @"unit_price": @1500,
                           @"qty": @1,
                           @"item_url": @"http://sandbox.affirm.com/item"
                           };
    XCTAssertEqualObjects([_item toJSONDictionary], item);
}

- (void)testAffirmShippingDetail
{
    NSDictionary *addressDetails = @{
                                     @"line1": @"325 Pacific Ave.",
                                     @"line2": @"",
                                     @"city": @"San Francisco",
                                     @"state": @"CA",
                                     @"zipcode": @"94111",
                                     @"country": @"USA"
                                     };
    NSDictionary *shippingDetail = @{
                                     @"billing": @{@"address": addressDetails, @"name": @{@"full": @"Test Tester"}},
                                     @"shipping": @{@"address": addressDetails, @"name": @{@"full": @"Test Tester"}}
                                     };
    XCTAssertEqualObjects([_shipping toJSONDictionary], shippingDetail);
}

- (void)testAffirmDiscount
{
    NSDictionary *discount = @{
                               @"discount_display_name": @"Affirm Test Discount",
                               @"discount_amount": @300
                               };
    XCTAssertEqualObjects([_discount toJSONDictionary], discount);
}

- (void)testAffirmCheckout
{
    NSDictionary *checkout = @{
                               @"items": @{
                                       @"test_item": @{
                                               @"display_name": @"Affirm Test Item",
                                               @"sku": @"test_item",
                                               @"unit_price": @1500,
                                               @"qty": @1,
                                               @"item_url": @"http://sandbox.affirm.com/item",
                                               }
                                       },
                               @"billing": @{
                                       @"name": @{@"full": @"Test Tester"},
                                       @"address":
                                           @{
                                               @"line1": @"325 Pacific Ave.",
                                               @"line2": @"",
                                               @"city": @"San Francisco",
                                               @"state": @"CA",
                                               @"zipcode": @"94111",
                                               @"country": @"USA"
                                               }
                                       },
                               @"shipping": @{
                                       @"name": @{@"full": @"Test Tester"},
                                       @"address":
                                           @{
                                               @"line1": @"325 Pacific Ave.",
                                               @"line2": @"",
                                               @"city": @"San Francisco",
                                               @"state": @"CA",
                                               @"zipcode": @"94111",
                                               @"country": @"USA"
                                               }
                                       },
                               @"shipping_amount": @500,
                               @"tax_amount": @100,
                               @"total": @2100,
                               @"api_version": @"v2"
                               };
    XCTAssertEqualObjects([_checkout toJSONDictionary], checkout);
}

- (void)testCheckoutSuccessCase
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"checkout response error format"];
    [[AffirmConfiguration sharedInstance] configureWithPublicKey:@"2G9MNM7462PB1TAV"
                                                     environment:AffirmEnvironmentSandbox
                                                    merchantName:@"Affirm Example"];
    AffirmCheckoutRequest *request = [[AffirmCheckoutRequest alloc] initWithPublicKey:[AffirmConfiguration sharedInstance].publicKey
                                                                             checkout:self.checkout
                                                                               useVCN:NO];
    [AffirmCheckoutClient send:request handler:^(id<AffirmResponseProtocol>  _Nullable response, NSError * _Nonnull error) {
        XCTAssertTrue([response isKindOfClass:[AffirmCheckoutResponse class]]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCheckoutWithVCNSuccessCase
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"checkout response error format"];
    [[AffirmConfiguration sharedInstance] configureWithPublicKey:@"2G9MNM7462PB1TAV"
                                                     environment:AffirmEnvironmentSandbox
                                                    merchantName:@"Affirm Example"];
    AffirmCheckoutRequest *request = [[AffirmCheckoutRequest alloc] initWithPublicKey:[AffirmConfiguration sharedInstance].publicKey
                                                                             checkout:self.checkout
                                                                               useVCN:YES];
    [AffirmCheckoutClient send:request handler:^(id<AffirmResponseProtocol>  _Nullable response, NSError * _Nonnull error) {
        XCTAssertTrue([response isKindOfClass:[AffirmCheckoutResponse class]]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCheckoutFailedCase
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"checkout response error format"];
    NSDecimalNumber *dollarPrice = [NSDecimalNumber decimalNumberWithString:@"500"];
    AffirmItem *item = [AffirmItem itemWithName:@"Affirm Test Item" SKU:@"test_item" unitPrice:dollarPrice quantity:1 URL:[NSURL URLWithString:@"http://sandbox.affirm.com/item"]];
    AffirmShippingDetail *shipping = [AffirmShippingDetail shippingDetailWithName:@"Test Tester" email:@"testtester@test.com" phoneNumber:@"1111111111" addressWithLine1:@"633 Folsom Street" line2:@"" city:@"San Francisco" state:@"CA" zipCode:@"94107" countryCode:@"USA"];
    AffirmCheckout *checkout = [AffirmCheckout checkoutWithItems:@[item] shipping:shipping payoutAmount:[dollarPrice toIntegerCents]];
    [[AffirmConfiguration sharedInstance] configureWithPublicKey:@"2G9MNM7462PB1TAV"
                                                     environment:AffirmEnvironmentSandbox
                                                    merchantName:@"Affirm Example"];
    AffirmCheckoutRequest *request = [[AffirmCheckoutRequest alloc] initWithPublicKey:[AffirmConfiguration sharedInstance].publicKey
                                                                             checkout:checkout
                                                                               useVCN:NO];
    [AffirmCheckoutClient send:request handler:^(id<AffirmResponseProtocol>  _Nullable response, NSError * _Nonnull error) {
        XCTAssertTrue([response isKindOfClass:[AffirmErrorResponse class]]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end