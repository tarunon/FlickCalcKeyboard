//
//  InuptControlTests.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import Calculator
import XCTest

@testable import InputControl

enum TestToken: String, TokenProtocol {
  case a
  case br
  case cad
}

final class InuptControlTests: XCTestCase {
  func testInsert() {
    var inputControl = InputControl<TestToken>()

    inputControl.insert(tokens: [.a, .a, .a])
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "aaa")

    inputControl.startPosition = 1
    inputControl.endPosition = 2
    inputControl.insert(tokens: [.br, .cad])
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "abrcada")
  }

  func testDelete() throws {
    var inputControl = InputControl<TestToken>()

    inputControl.insert(tokens: [
      .a, .br, .a, .cad, .a, .br, .a,
    ])
    inputControl.startPosition = 3
    inputControl.endPosition = 4

    XCTAssertEqual(inputControl.text, "abracadabra")
    try inputControl.delete(direction: .left, line: true)
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "abraabra")

    try inputControl.delete(direction: .right, line: false)
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 3)
    XCTAssertEqual(inputControl.text, "abrabra")

    try inputControl.delete(direction: .left, line: false)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "abrbra")

    try inputControl.delete(direction: .left, line: true)
    XCTAssertEqual(inputControl.startPosition, 0)
    XCTAssertEqual(inputControl.endPosition, 0)
    XCTAssertEqual(inputControl.text, "bra")

    inputControl.insert(tokens: [.a, .br])
    try inputControl.delete(direction: .right, line: true)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "abr")

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
    var inputControl = InputControl<TestToken>()

    inputControl.insert(tokens: [
      .a, .br, .a, .cad, .a, .br, .a,
    ])
    inputControl.startPosition = 3
    inputControl.endPosition = 4

    try inputControl.moveCursor(direction: .left)
    XCTAssertEqual(inputControl.startPosition, 2)
    XCTAssertEqual(inputControl.endPosition, 2)
    XCTAssertEqual(inputControl.text, "abracadabra")

    try inputControl.moveCursor(direction: .left)
    XCTAssertEqual(inputControl.startPosition, 1)
    XCTAssertEqual(inputControl.endPosition, 1)
    XCTAssertEqual(inputControl.text, "abracadabra")

    inputControl.startPosition = 3
    inputControl.endPosition = 4
    try inputControl.moveCursor(direction: .right)
    XCTAssertEqual(inputControl.startPosition, 5)
    XCTAssertEqual(inputControl.endPosition, 5)
    XCTAssertEqual(inputControl.text, "abracadabra")

    try inputControl.moveCursor(direction: .right)
    XCTAssertEqual(inputControl.startPosition, 6)
    XCTAssertEqual(inputControl.endPosition, 6)
    XCTAssertEqual(inputControl.text, "abracadabra")

    inputControl.moveCusorToEnd()
    XCTAssertEqual(inputControl.startPosition, 7)
    XCTAssertEqual(inputControl.endPosition, 7)
    XCTAssertEqual(inputControl.text, "abracadabra")

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
    var inputControl = InputControl<TestToken>()

    inputControl.insert(tokens: [
      .a, .br, .a, .cad, .a, .br, .a,
    ])

    XCTAssertEqual(inputControl.startPosition, 7)
    XCTAssertEqual(inputControl.endPosition, 7)
    XCTAssertEqual(inputControl.text, "abracadabra")
    XCTAssertEqual(inputControl.cursor, NSRange(location: 11, length: 0))

    inputControl.startPosition = 5
    XCTAssertEqual(inputControl.cursor, NSRange(location: 8, length: 3))

    inputControl.cursor = NSRange(location: 0, length: 6)
    XCTAssertEqual(inputControl.startPosition, 0)
    XCTAssertEqual(inputControl.endPosition, 4)

    inputControl.cursor = NSRange(location: 4, length: 2)
    XCTAssertEqual(inputControl.startPosition, 3)
    XCTAssertEqual(inputControl.endPosition, 4)
    XCTAssertEqual(inputControl.cursor, NSRange(location: 4, length: 3))
  }
}
