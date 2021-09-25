//
//  TokenTests.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import XCTest

@testable import Calculator

final class TokenTests: XCTestCase {
  func testTokenParameters() throws {
    try XCTAssertEqual(DigitToken._0.result(), 0)
    try XCTAssertEqual(DigitToken._1.result(), 1)
    try XCTAssertEqual(DigitToken._2.result(), 2)
    try XCTAssertEqual(DigitToken._3.result(), 3)
    try XCTAssertEqual(DigitToken._4.result(), 4)
    try XCTAssertEqual(DigitToken._5.result(), 5)
    try XCTAssertEqual(DigitToken._6.result(), 6)
    try XCTAssertEqual(DigitToken._7.result(), 7)
    try XCTAssertEqual(DigitToken._8.result(), 8)
    try XCTAssertEqual(DigitToken._9.result(), 9)
    try XCTAssertEqual(ConstToken.pi.result(), .init(.pi))
    try XCTAssertEqual(ConstToken.napier.result(), .init(.exp(1.0)))
    try XCTAssertEqual(ConstToken.complex.result(), .init(imaginary: 1.0))
  }
}
