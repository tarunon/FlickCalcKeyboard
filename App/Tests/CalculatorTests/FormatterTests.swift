//
//  FormatterTests.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import ComplexModule
import XCTest

@testable import Calculator

final class FormatterTests: XCTestCase {
  func testTokenParameters() throws {
    XCTAssertEqual(CalcFormatter.format(0), "0")
    XCTAssertEqual(CalcFormatter.format(1), "1")
    XCTAssertEqual(CalcFormatter.format(-1), "-1")
    XCTAssertEqual(CalcFormatter.format(1234), "1,234")
    XCTAssertEqual(CalcFormatter.format(-1234), "-1,234")
    XCTAssertEqual(CalcFormatter.format(.i), "i")
    XCTAssertEqual(CalcFormatter.format(-1 * .i), "-i")
    XCTAssertEqual(CalcFormatter.format(2 * .i), "2i")
    XCTAssertEqual(CalcFormatter.format(1234 * .i), "1,234i")
    XCTAssertEqual(CalcFormatter.format(1 + .i), "1+i")
    XCTAssertEqual(CalcFormatter.format(1 + -1 * .i), "1-i")
    XCTAssertEqual(CalcFormatter.format(2 + 2 * .i), "2+2i")
    XCTAssertEqual(CalcFormatter.format(2 + -2 * .i), "2-2i")
    XCTAssertEqual(CalcFormatter.format(-2 + 2 * .i), "-2+2i")
    XCTAssertEqual(CalcFormatter.format(-2 + -2 * .i), "-2-2i")
    XCTAssertEqual(CalcFormatter.format(.pow(.exp(1), .init(.pi) * .i)), "-1")
    XCTAssertEqual(CalcFormatter.format(.pow(10, 20)), "1E20")
    XCTAssertEqual(CalcFormatter.format(-1 * .pow(10, 20)), "-1E20")
    XCTAssertEqual(CalcFormatter.format(.i * .pow(10, 20)), "1E20i")
    XCTAssertEqual(CalcFormatter.format(-1 * .i * .pow(10, 20)), "-1E20i")
  }
}
