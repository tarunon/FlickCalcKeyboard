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
    XCTAssertEqual(try DigitToken._0.result(), 0)
    XCTAssertEqual(try DigitToken._1.result(), 1)
    XCTAssertEqual(try DigitToken._2.result(), 2)
    XCTAssertEqual(try DigitToken._3.result(), 3)
    XCTAssertEqual(try DigitToken._4.result(), 4)
    XCTAssertEqual(try DigitToken._5.result(), 5)
    XCTAssertEqual(try DigitToken._6.result(), 6)
    XCTAssertEqual(try DigitToken._7.result(), 7)
    XCTAssertEqual(try DigitToken._8.result(), 8)
    XCTAssertEqual(try DigitToken._9.result(), 9)
    XCTAssertEqual(try ConstToken.pi.result(), .init(.pi))
    XCTAssertEqual(try ConstToken.napier.result(), .init(.exp(1.0)))
    XCTAssertEqual(try ConstToken.imaginaly.result(), .init(imaginary: 1.0))
  }
}
