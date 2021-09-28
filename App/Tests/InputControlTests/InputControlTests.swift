//
//  InuptControlTests.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import Calculator
import XCTest

@testable import InputControl

final class InuptControlTests: XCTestCase {
  func testInsert() {
    var inputControl = InputControl()

    inputControl.insert(tokens: [DigitToken._0, DigitToken._1, DigitToken._2])
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "012")

    inputControl.startPosition = 1
    inputControl.endPosition = 2
    inputControl.insert(tokens: [DigitToken._3, DigitToken._4])
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "0342")
  }

  func testDelete() throws {
    var inputControl = InputControl()

    inputControl.insert(tokens: [
      DigitToken._0, DigitToken._1, DigitToken._2, DigitToken._3, DigitToken._4, DigitToken._5,
      DigitToken._6, DigitToken._7,
    ])
    inputControl.startPosition = 3
    inputControl.endPosition = 5

    XCTAssertEqual(inputControl.text, "01234567")
    try inputControl.delete(direction: .left, line: true)
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "012567")

    try inputControl.delete(direction: .right, line: false)
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "01267")

    try inputControl.delete(direction: .left, line: false)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "0167")

    try inputControl.delete(direction: .left, line: true)
    XCTAssertEqual(inputControl.startPosition, 0)
    XCTAssertEqual(inputControl.endPosition, 0)
    XCTAssertEqual(inputControl.text, "67")

    inputControl.insert(tokens: [DigitToken._0, DigitToken._1])
    try inputControl.delete(direction: .right, line: true)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "01")

    inputControl.clearAll()
    XCTAssertEqual(inputControl.startPosition, 0)
    XCTAssertEqual(inputControl.endPosition, 0)
    XCTAssertEqual(inputControl.text, "")

    XCTAssertThrowsError(
      try inputControl.delete(direction: .right, line: false),
      ""
    ) { error in
      guard case InputControlError.isEmpty = error else {
        XCTFail()
        return
      }
    }
  }

  func testMoveCursor() throws {
    var inputControl = InputControl()

    inputControl.insert(tokens: [
      DigitToken._0, DigitToken._1, DigitToken._2, DigitToken._3, DigitToken._4, DigitToken._5,
      DigitToken._6, DigitToken._7,
    ])
    inputControl.startPosition = 3
    inputControl.endPosition = 5

    try inputControl.moveCursor(direction: .left)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "01234567")

    inputControl.startPosition = 3
    inputControl.endPosition = 5
    try inputControl.moveCursor(direction: .right)
    XCTAssertEqual(inputControl.startPosition, 6)
    XCTAssertEqual(inputControl.endPosition, 6)
    XCTAssertEqual(inputControl.text, "01234567")

    inputControl.moveCusorToEnd()
    XCTAssertEqual(inputControl.startPosition, 8)
    XCTAssertEqual(inputControl.endPosition, 8)
    XCTAssertEqual(inputControl.text, "01234567")

    inputControl.clearAll()
    XCTAssertThrowsError(
      try inputControl.moveCursor(direction: .left),
      ""
    ) { error in
      guard case InputControlError.isEmpty = error else {
        XCTFail()
        return
      }
    }
  }

  func testConvertRange() throws {
    var inputControl = InputControl()

    inputControl.insert(tokens: [
      FunctionToken.sin, BracketToken.open, DigitToken._0, BracketToken.close, AddToken.instance,
      FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close,
    ])

    XCTAssertEqual(inputControl.startPosition, 9)
    XCTAssertEqual(inputControl.endPosition, 9)
    XCTAssertEqual(inputControl.text, "sin(0)+cos(0)")
    XCTAssertEqual(inputControl.cursor, NSRange(location: 13, length: 0))

    inputControl.startPosition = 5
    XCTAssertEqual(inputControl.cursor, NSRange(location: 7, length: 6))

    inputControl.cursor = NSRange(location: 0, length: 6)
    XCTAssertEqual(inputControl.startPosition, 0)
    XCTAssertEqual(inputControl.endPosition, 4)

    inputControl.cursor = NSRange(location: 7, length: 1)
    XCTAssertEqual(inputControl.startPosition, 5)
    XCTAssertEqual(inputControl.endPosition, 6)
    XCTAssertEqual(inputControl.cursor, NSRange(location: 7, length: 3))
  }
}
