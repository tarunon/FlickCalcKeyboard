//
//  ParsecTests.swift
//
//
//  Created by tarunon on 2021/09/27.
//

import Core
import XCTest

@testable import Parsec

class ParsecTests: XCTestCase {
  typealias TestParser = Parser<String, Character>
  typealias TestCastParser<T: Sendable> = Parser<[Sendable], T>
  struct TestError: Error {}

  func testOperatorValues() throws {
    XCTAssertEqual(try TestParser.pure("a")("123"), .init(output: "a", input: "123"))
    XCTAssertThrowsError(try TestParser.empty()("123"))
  }

  func testOperatorSatisfy() throws {

    XCTAssertEqual(try TestParser.satisfy(to: "a")("abc"), .init(output: "a", input: "bc"))

    XCTAssertThrowsError(
      try TestParser.satisfy(to: "b")("abc"),
      "",
      { error in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Character, "a")
          XCTAssertEqual(error.unprocessedInput, "abc")
        } else {
          XCTFail()
        }
      }
    )
    //    XCTAssertEqual(try TestCastParser.satisfy(to: String.self)(["a", 1, 0.5]).output, "a")
    //    XCTAssertThrowsError(
    //      try TestCastParser.satisfy(to: Int.self)(["a", 1, 0.5]),
    //      "",
    //      { error in
    //        if let error = error as? ParseError<[Sendable]>,
    //          case .typeMissmatch(let expect, let actual) = error.detail
    //        {
    //          XCTAssertEqual(actual as! String, "a")
    //          XCTAssertTrue(expect is Int.Type)
    //          XCTAssertEqual(error.unprocessedInput.count, 3)
    //        } else {
    //          XCTFail()
    //        }
    //      }
    //    )

    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }("123"),
      .init(output: "1", input: "23")
    )
  }

  func testOperatorMap() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").map { try Int("\($0)").tryUnwrapped }("123"),
      .init(output: 1, input: "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").map { try Int("\($0)").tryUnwrapped }("abc"),
      "",
      { error in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Character, "a")
          XCTAssertEqual(error.unprocessedInput, "abc")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "a").map { try Int("\($0)").tryUnwrapped }("abc"),
      "",
      { error in
        guard let error = error as? ParseError<String>,
          case .userDefinedError(_ as NilError) = error.detail
        else {
          XCTFail()
          return
        }
        XCTAssertEqual(error.unprocessedInput, "abc")
      }
    )

    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }(
        "123"
      ),
      .init(output: 1, input: "23")
    )
  }

  func testOperatorFlatMap() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMap { a in
        TestParser.satisfy(to: "2").map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }("123"),
      .init(output: 12, input: "3")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").flatMap { a in
        TestParser.satisfy(to: "a").map { b in
          try Int("\(a)\(b)").tryUnwrapped
        }
      }("123"),
      "",
      { error in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Character, "2")
          XCTAssertEqual(error.unprocessedInput, "23")
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
        guard let error = error as? ParseError<String>,
          case .userDefinedError(_ as NilError) = error.detail
        else {
          XCTFail()
          return
        }
        XCTAssertEqual(error.unprocessedInput, "bc")
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
      .init(output: 12, input: "3")
    )
  }

  func testOperatorAssert() throws {
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }
        .assert { $0 % 2 == 0 }("246"),
      .init(output: 2, input: "46")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy { ("0"..."9").contains($0) }.map { try Int("\($0)").tryUnwrapped }
        .assert { $0 % 2 == 0 }("123"),
      "",
      { (error) in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Int, 1)
          XCTAssertEqual(error.unprocessedInput, "123")
        } else {
          XCTFail()
        }
      }
    )
  }

  func testOperatorMapError() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").mapError { _ in return TestError() }("123"),
      .init(output: "1", input: "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").mapError { _ in TestError() }("abc"),
      "",
      { error in
        guard let error = error as? ParseError<String>,
          case .userDefinedError(_ as TestError) = error.detail
        else {
          XCTFail()
          return
        }
        XCTAssertEqual(error.unprocessedInput, "abc")
      }
    )
  }

  func testOperatorFlatMapError() throws {
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.empty()
      }("123"),
      .init(output: "1", input: "23")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.empty()
      }("abc"),
      "",
      { error in
        guard let error = error as? ParseError<String>,
          case .isEmpty = error.detail
        else {
          XCTFail()
          return
        }
        XCTAssertEqual(error.unprocessedInput, "")
      }
    )
    XCTAssertEqual(
      try TestParser.satisfy(to: "1").flatMapError { _ in
        TestParser.satisfy(to: "a")
      }("abc"),
      .init(output: "a", input: "bc")
    )
  }

  func testOperatorMany() throws {
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: true)("abc123"),
      .init(output: [], input: "abc123")
    )
    XCTAssertEqual(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)("123abc"),
      .init(output: ["1", "2", "3"], input: "abc")
    )
    XCTAssertThrowsError(
      try TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)("abc123"),
      "",
      { error in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Character, "a")
          XCTAssertEqual(error.unprocessedInput, "abc123")
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
      .init(output: ["a", "b", "c"], input: "123")
    )
    XCTAssertEqual(
      try
        (TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)
        || TestParser.satisfy { ("a"..."z").contains($0) }.many(allowEmpty: false))("123abc"),
      .init(output: ["1", "2", "3"], input: "abc")
    )
    XCTAssertThrowsError(
      try
        (TestParser.satisfy { ("0"..."9").contains($0) }.many(allowEmpty: false)
        || TestParser.satisfy { ("a"..."z").contains($0) }.many(allowEmpty: false))("ABC"),
      "",
      { error in
        if let error = error as? ParseError<String>,
          case .conditionFailure = error.detail
        {
          //          XCTAssertEqual(value as! Character, "A")
          XCTAssertEqual(error.unprocessedInput, "ABC")
        } else {
          XCTFail()
        }
      }
    )
  }
}
