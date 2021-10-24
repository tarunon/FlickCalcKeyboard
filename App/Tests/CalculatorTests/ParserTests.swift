import Parsec
import XCTest

@testable import Calculator

final class ParserTests: XCTestCase {
  func parse(tokens: [CalcTokenProtocol]) throws -> String {
    try CalcParsers.calc(tokens.reversed()).value.description
  }

  func testParseTokens() {
    XCTAssertEqual(try CalcParsers.digit([DigitToken._0]).value.rawValue, "0")
    XCTAssertEqual(try CalcParsers.const([ConstToken.pi]).value.rawValue, "π")
    XCTAssertEqual(
      try CalcParsers.digits([DigitToken._6, DigitToken._4].reversed()).value.description,
      "64"
    )
    XCTAssertEqual(try CalcParsers.function([FunctionToken.log]).value.rawValue, "log")
    XCTAssertEqual(try CalcParsers.bracket(open: true)([BracketToken.open]).value.rawValue, "(")
    XCTAssertEqual(try CalcParsers.bracket(open: false)([BracketToken.close]).value.rawValue, ")")
    XCTAssertEqual(
      try CalcParsers.prefixOperator(precedence: .low)([SubToken.instance]).value.rawValue,
      "-"
    )
    XCTAssertEqual(
      try CalcParsers.infixOperator(precedence: .middle)([DivToken.instance]).value.rawValue,
      "÷"
    )
    XCTAssertEqual(
      try CalcParsers.postfixOperator(precedence: .high)([GammaToken.instance]).value.rawValue,
      "!"
    )
  }

  func testParseNumbers() {
    XCTAssertEqual(try parse(tokens: [DigitToken._0]), "(0)")
    XCTAssertEqual(try parse(tokens: [DigitToken._3, DigitToken._2]), "(32)")
    XCTAssertEqual(
      try parse(tokens: [DigitToken._1, DotToken.instance, DigitToken._4, DigitToken._1]),
      "(1.41)"
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        DigitToken._0, DotToken.instance, DigitToken._1, DotToken.instance, DigitToken._0,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]>,
          case .notComplete = error.detail
        {
          XCTAssertEqual(error.unprocessedInput[0] as? DotToken, .instance)
          XCTAssertEqual(error.unprocessedInput[1] as? DigitToken, ._0)
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [DotToken.instance, DotToken.instance]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]>,
          case .typeMissmatch = error.detail
        {
          //          XCTAssertEqual(actual as! DotToken, .instance)
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertEqual(try parse(tokens: [DigitToken._8, ConstToken.pi]), "(8*π)")
    XCTAssertEqual(try parse(tokens: [ConstToken.pi, ConstToken.napier]), "(π*e)")
  }

  func testParseOperators() {
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, AddToken.instance, DigitToken._7]),
      "((6)+(7))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, SubToken.instance, DigitToken._7]),
      "((6)-(7))"
    )
    XCTAssertEqual(try parse(tokens: [SubToken.instance, DigitToken._7]), "(-(7))")
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, MulToken.instance, DigitToken._7]),
      "((6)×(7))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, DivToken.instance, DigitToken._7]),
      "((6)÷(7))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, ModToken.instance, DigitToken._7]),
      "((6)%(7))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, PowToken.instance, DigitToken._7]),
      "((6)^(7))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._6, RootToken.instance, DigitToken._7]),
      "((6)√(7))"
    )
    XCTAssertEqual(try parse(tokens: [RootToken.instance, DigitToken._7]), "(√(7))")
    XCTAssertEqual(try parse(tokens: [DigitToken._6, GammaToken.instance]), "((6)!)")

    XCTAssertEqual(
      try parse(tokens: [
        DigitToken._1, AddToken.instance, DigitToken._2, AddToken.instance, DigitToken._3,
        AddToken.instance, DigitToken._4,
      ]),
      "((((1)+(2))+(3))+(4))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        DigitToken._1, AddToken.instance, DigitToken._2, MulToken.instance, DigitToken._3,
        PowToken.instance, DigitToken._4,
      ]),
      "((1)+((2)×((3)^(4))))"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._9, AddToken.instance, DigitToken._5]),
      "((-(9))+(5))"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._9, MulToken.instance, DigitToken._5]),
      "(-((9)×(5)))"
    )
    XCTAssertEqual(
      try parse(tokens: [RootToken.instance, DigitToken._9, MulToken.instance, DigitToken._5]),
      "((√(9))×(5))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._9, PowToken.instance, DigitToken._5, GammaToken.instance]),
      "(((9)^(5))!)"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._9, MulToken.instance, DigitToken._5, GammaToken.instance]),
      "((9)×((5)!))"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._5, GammaToken.instance]),
      "(-((5)!))"
    )
    XCTAssertEqual(
      try parse(tokens: [RootToken.instance, DigitToken._5, GammaToken.instance]),
      "((√(5))!)"
    )

    XCTAssertEqual(
      try parse(tokens: [DigitToken._3, ConstToken.pi, GammaToken.instance]),
      "((3*π)!)"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._3, ConstToken.pi, GammaToken.instance]),
      "(-((3*π)!))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        DigitToken._9, DivToken.instance, DigitToken._3, ConstToken.imaginaly, GammaToken.instance,
      ]),
      "((9)÷((3*i)!))"
    )
  }

  func testParseOperatorsError() {
    XCTAssertThrowsError(
      try parse(tokens: [
        DigitToken._1, AddToken.instance, AddToken.instance, DigitToken._2,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "1++")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        AddToken.instance, DigitToken._1,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "+")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        DigitToken._1, AddToken.instance,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "1+")
        } else {
          XCTFail()
        }
      }
    )
  }

  func testBrackets() {
    XCTAssertEqual(
      try parse(tokens: [
        BracketToken.open, BracketToken.open, DigitToken._1, AddToken.instance, DigitToken._2,
        BracketToken.close, MulToken.instance, DigitToken._3, BracketToken.close, PowToken.instance,
        DigitToken._4,
      ]),
      "((((((1)+(2)))×(3)))^(4))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        SubToken.instance, BracketToken.open, DigitToken._9, AddToken.instance, DigitToken._5,
        BracketToken.close,
      ]),
      "(-(((9)+(5))))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        BracketToken.open, SubToken.instance, DigitToken._9, BracketToken.close, MulToken.instance,
        DigitToken._5,
      ]),
      "(((-(9)))×(5))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        RootToken.instance, BracketToken.open, DigitToken._9, MulToken.instance, DigitToken._5,
        BracketToken.close,
      ]),
      "(√(((9)×(5))))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        DigitToken._9, PowToken.instance, BracketToken.open, DigitToken._5, GammaToken.instance,
        BracketToken.close,
      ]),
      "((9)^(((5)!)))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        BracketToken.open, DigitToken._9, MulToken.instance, DigitToken._5, BracketToken.close,
        GammaToken.instance,
      ]),
      "((((9)×(5)))!)"
    )
    XCTAssertEqual(
      try parse(tokens: [
        BracketToken.open, SubToken.instance, DigitToken._5, BracketToken.close,
        GammaToken.instance,
      ]),
      "(((-(5)))!)"
    )
    XCTAssertEqual(
      try parse(tokens: [
        RootToken.instance, BracketToken.open, DigitToken._5, GammaToken.instance,
        BracketToken.close,
      ]),
      "(√(((5)!)))"
    )
  }

  func testBracketsError() {
    XCTAssertThrowsError(
      try parse(tokens: [
        DigitToken._1, BracketToken.open, AddToken.instance, DigitToken._2, BracketToken.close,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "1(+")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        DigitToken._1, BracketToken.open, AddToken.instance, BracketToken.close, DigitToken._2,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "1(+)")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        BracketToken.open, DigitToken._1, AddToken.instance, BracketToken.close, DigitToken._2,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "(1+)")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        BracketToken.open, BracketToken.close,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "(")
        } else {
          XCTFail()
        }
      }
    )
  }

  func testFunctions() {
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.sin, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(sin(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.asin, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(asin(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.sinh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(sinh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.asinh, BracketToken.open, DigitToken._0, BracketToken.close]
      ),
      "(asinh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(cos(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.acos, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(acos(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.cosh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(cosh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.acosh, BracketToken.open, DigitToken._0, BracketToken.close]
      ),
      "(acosh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.tan, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(tan(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.atan, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(atan(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.tanh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(tanh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.atanh, BracketToken.open, DigitToken._0, BracketToken.close]
      ),
      "(atanh(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.log, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(log(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.lg, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(lg(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [FunctionToken.ln, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(ln(0))"
    )

    XCTAssertEqual(
      try parse(tokens: [
        ConstToken.napier, FunctionToken.log, BracketToken.open, DigitToken._0, BracketToken.close,
      ]),
      "(e*log(0))"
    )
    XCTAssertEqual(
      try parse(tokens: [
        DigitToken._1, DivToken.instance, FunctionToken.sin, BracketToken.open, DigitToken._0,
        BracketToken.close, FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close,
      ]),
      "((1)÷(sin(0)*cos(0)))"
    )
  }

  func testFunctionsError() {
    XCTAssertThrowsError(
      try parse(tokens: [
        FunctionToken.sin, DigitToken._0,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "sin")
        } else {
          XCTFail()
        }
      }
    )
    XCTAssertThrowsError(
      try parse(tokens: [
        FunctionToken.sin, FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close,
      ]),
      "",
      { error in
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          XCTAssertEqual(error.unprocessedInput.reversed().text, "sin")
        } else {
          XCTFail()
        }
      }
    )
  }
}
