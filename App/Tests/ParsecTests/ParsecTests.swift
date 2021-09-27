//
//  ParsecTests.swift
//
//
//  Created by tarunon on 2021/09/27.
//

import Core
import XCTest

@testable import Parsec

public func XCTAssertEqual<T0, T1>(
  _ expression1: @autoclosure () throws -> (T0, T1),
  _ expression2: @autoclosure () throws -> (T0, T1),
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) where T0: Equatable, T1: Equatable {
  do {
    let value1 = try expression1()
    let value2 = try expression2()
    let message = message()
    XCTAssertEqual(value1.0, value2.0, message, file: file, line: line)
    XCTAssertEqual(value1.1, value2.1, message, file: file, line: line)
  } catch (let error) {
    XCTFail("XCTAssertEqual failed: threw error \"\(error)\"")
  }
}

class ParsecTests: XCTestCase {
  typealias TestParser = Parser<String, Character>
  typealias TestCastParser<T> = Parser<[Any], T>
  struct TestError: Error {}

  func testOperatorValues() throws {
    XCTAssertEqual(try TestParser.pure("a")("123"), ("a", "123"))
    XCTAssertThrowsError(try TestParser.empty()("123"))
  }

  func testOperatorSatisfy() throws {

    XCTAssertEqual(try TestParser.satisfy(to: "a")("abc"), ("a", "bc"))

    XCTAssertThrowsError(
      try TestParser.satisfy(to: "b")("abc"),
      "",
      { error in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Character, "a")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertEqual(try TestCastParser.satisfy(to: String.self)(["a", 1, 0.5]).0, "a")
    XCTAssertThrowsError(
      try TestCastParser.satisfy(to: Int.self)(["a", 1, 0.5]),
      "",
      { error in
        if case ParseError.typeMissmatch(let expect, let actual) = error {
          XCTAssertEqual(actual as! String, "a")
          XCTAssertTrue(expect is Int.Type)
        } else {
          XCTFail()
        }
      }
    )

    XCTAssertEqual(try TestParser.satisfy { ("0"..."9").contains($0) }("123"), ("1", "23"))
  }

  func testOperatorMap() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").map { try Int("\($0)").tryUnwrapped }("123"),
      (1, "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").map { try Int("\($0)").tryUnwrapped }("abc"),
      "",
      { error in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Character, "a")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "a").map { try Int("\($0)").tryUnwrapped }("abc"),
      "",
      { error in
        guard error is NilError else {
          XCTFail()
          return
        }
      }
    )

    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }(
        "123"
      ),
      (1, "23")
    )
  }

  func testOperatorFlatMap() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMap { a in
        TestParser.satisfy(to: "2").map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }("123"),
      (12, "3")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").flatMap { a in
        TestParser.satisfy(to: "a").map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }("123"),
      "",
      { error in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Character, "2")
        } else {
          XCTFail()
        }
      }
    )

    XCTAssertThrowsError(
      try TestParser.satisfy(to: "a").flatMap { a in
        TestParser.satisfy(to: "b").map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }("abc"),
      "",
      { error in
        guard error is NilError else {
          XCTFail()
          return
        }
      }
    )

    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.flatMap { a in
        TestParser.satisfy { ("0"..."9").contains($0) }.map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }(
        "123"
      ),
      (12, "3")
    )
  }

  func testOperatorAssert() throws {
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }
        .assert { $0 % 2 == 0 }("246"),
      (2, "46")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }
        .assert { $0 % 2 == 0 }("123"),
      "",
      { (error) in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Int, 1)
        } else {
          XCTFail()
        }
      }
    )
  }

  func testOperatorMapError() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").mapError { _ in return TestError() }("123"),
      ("1", "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").mapError { _ in TestError() }("abc"),
      "",
      { error in
        guard error is TestError else {
          XCTFail()
          return
        }
      }
    )
  }

  func testOperatorFlatMapError() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.empty()
      }("123"),
      ("1", "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.empty()
      }("abc"),
      "",
      { error in
        guard case ParseError.isEmpty = error else {
          XCTFail()
          return
        }
      }
    )
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.satisfy(to: "a")
      }("abc"),
      ("a", "bc")
    )
  }

  func testOperatorMany() throws {
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: true)("abc123"),
      ([], "abc123")
    )
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)("123abc"),
      (["1", "2", "3"], "abc")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)("abc123"),
      "",
      { error in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Character, "a")
        } else {
          XCTFail()
        }
      }
    )
  }

  func testOperatorOr() throws {
    XCTAssertEqual(
      try
        (TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)
        || TestParser.satisfy { ("a"..."z").contains($0) }.many(allowEmpty: false))("abc123"),
      (["a", "b", "c"], "123")
    )
    XCTAssertEqual(
      try
        (TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)
        || TestParser.satisfy { ("a"..."z").contains($0) }.many(allowEmpty: false))("123abc"),
      (["1", "2", "3"], "abc")
    )
    XCTAssertThrowsError(
      try
        (TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)
        || TestParser.satisfy { ("a"..."z").contains($0) }.many(allowEmpty: false))("ABC"),
      "",
      { error in
        if case ParseError.conditionFailure(let value) = error {
          XCTAssertEqual(value as! Character, "A")
        } else {
          XCTFail()
        }
      }
    )
  }
}
