import XCTest

@testable import Calculator

final class ParserTests: XCTestCase {
  func parse(tokens: [CalcToken]) throws -> String {
    try CalcParsers.calc(tokens.reversed()).0.description
  }

  func testParseTokens() throws {
    try XCTAssertEqual(CalcParsers.digit([DigitToken._0]).0.rawValue, "0")
    try XCTAssertEqual(CalcParsers.const([ConstToken.pi]).0.rawValue, "π")
    try XCTAssertEqual(
      CalcParsers.digits([DigitToken._6, DigitToken._4].reversed()).0.description,
      "64"
    )
    try XCTAssertEqual(CalcParsers.function([FunctionToken.log]).0.rawValue, "log")
    try XCTAssertEqual(CalcParsers.bracket(open: true)([BracketToken.open]).0.rawValue, "(")
    try XCTAssertEqual(CalcParsers.bracket(open: false)([BracketToken.close]).0.rawValue, ")")
    try XCTAssertEqual(
      CalcParsers.prefixOperator(precedence: .low)([SubToken.instance]).0.rawValue,
      "-"
    )
    try XCTAssertEqual(
      CalcParsers.infixOperator(precedence: .middle)([DivToken.instance]).0.rawValue,
      "÷"
    )
    try XCTAssertEqual(
      CalcParsers.postfixOperator(precedence: .high)([GammaToken.instance]).0.rawValue,
      "!"
    )
  }

  func testParseNumbers() throws {
    try XCTAssertEqual(parse(tokens: [DigitToken._0]), "(0)")
    try XCTAssertEqual(parse(tokens: [DigitToken._3, DigitToken._2]), "(32)")
    try XCTAssertEqual(
      parse(tokens: [DigitToken._1, DigitToken.dot, DigitToken._4, DigitToken._1]),
      "(1.41)"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._0, DigitToken.dot, DigitToken._1, DigitToken.dot, DigitToken._0]),
      "(0.1.0)"
    )
    try XCTAssertEqual(parse(tokens: [DigitToken.dot, DigitToken.dot]), "(..)")
    try XCTAssertEqual(parse(tokens: [DigitToken._8, ConstToken.pi]), "(8*π)")
    try XCTAssertEqual(parse(tokens: [ConstToken.pi, ConstToken.napier]), "(π*e)")
  }

  func testParseOperators() throws {
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, AddToken.instance, DigitToken._7]),
      "((6)+(7))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, SubToken.instance, DigitToken._7]),
      "((6)-(7))"
    )
    try XCTAssertEqual(parse(tokens: [SubToken.instance, DigitToken._7]), "(-(7))")
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, MulToken.instance, DigitToken._7]),
      "((6)×(7))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, DivToken.instance, DigitToken._7]),
      "((6)÷(7))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, ModToken.instance, DigitToken._7]),
      "((6)%(7))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, PowToken.instance, DigitToken._7]),
      "((6)^(7))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._6, RootToken.instance, DigitToken._7]),
      "((6)√(7))"
    )
    try XCTAssertEqual(parse(tokens: [RootToken.instance, DigitToken._7]), "(√(7))")
    try XCTAssertEqual(parse(tokens: [DigitToken._6, GammaToken.instance]), "((6)!)")

    try XCTAssertEqual(
      parse(tokens: [
        DigitToken._1, AddToken.instance, DigitToken._2, AddToken.instance, DigitToken._3,
        AddToken.instance, DigitToken._4,
      ]),
      "((((1)+(2))+(3))+(4))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        DigitToken._1, AddToken.instance, DigitToken._2, MulToken.instance, DigitToken._3,
        PowToken.instance, DigitToken._4,
      ]),
      "((1)+((2)×((3)^(4))))"
    )
    try XCTAssertEqual(
      parse(tokens: [SubToken.instance, DigitToken._9, AddToken.instance, DigitToken._5]),
      "((-(9))+(5))"
    )
    try XCTAssertEqual(
      parse(tokens: [SubToken.instance, DigitToken._9, MulToken.instance, DigitToken._5]),
      "(-((9)×(5)))"
    )
    try XCTAssertEqual(
      parse(tokens: [RootToken.instance, DigitToken._9, MulToken.instance, DigitToken._5]),
      "((√(9))×(5))"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._9, PowToken.instance, DigitToken._5, GammaToken.instance]),
      "(((9)^(5))!)"
    )
    try XCTAssertEqual(
      parse(tokens: [DigitToken._9, MulToken.instance, DigitToken._5, GammaToken.instance]),
      "((9)×((5)!))"
    )
    try XCTAssertEqual(
      parse(tokens: [SubToken.instance, DigitToken._5, GammaToken.instance]),
      "(-((5)!))"
    )
    try XCTAssertEqual(
      parse(tokens: [RootToken.instance, DigitToken._5, GammaToken.instance]),
      "((√(5))!)"
    )

    try XCTAssertEqual(
      parse(tokens: [DigitToken._3, ConstToken.pi, GammaToken.instance]),
      "((3*π)!)"
    )
    try XCTAssertEqual(
      parse(tokens: [SubToken.instance, DigitToken._3, ConstToken.pi, GammaToken.instance]),
      "(-((3*π)!))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        DigitToken._9, DivToken.instance, DigitToken._3, ConstToken.imaginaly, GammaToken.instance,
      ]),
      "((9)÷((3*i)!))"
    )
  }

  func testBrackets() {
    try XCTAssertEqual(
      parse(tokens: [
        BracketToken.open, BracketToken.open, DigitToken._1, AddToken.instance, DigitToken._2,
        BracketToken.close, MulToken.instance, DigitToken._3, BracketToken.close, PowToken.instance,
        DigitToken._4,
      ]),
      "((((((1)+(2)))×(3)))^(4))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        SubToken.instance, BracketToken.open, DigitToken._9, AddToken.instance, DigitToken._5,
        BracketToken.close,
      ]),
      "(-(((9)+(5))))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        BracketToken.open, SubToken.instance, DigitToken._9, BracketToken.close, MulToken.instance,
        DigitToken._5,
      ]),
      "(((-(9)))×(5))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        RootToken.instance, BracketToken.open, DigitToken._9, MulToken.instance, DigitToken._5,
        BracketToken.close,
      ]),
      "(√(((9)×(5))))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        DigitToken._9, PowToken.instance, BracketToken.open, DigitToken._5, GammaToken.instance,
        BracketToken.close,
      ]),
      "((9)^(((5)!)))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        BracketToken.open, DigitToken._9, MulToken.instance, DigitToken._5, BracketToken.close,
        GammaToken.instance,
      ]),
      "((((9)×(5)))!)"
    )
    try XCTAssertEqual(
      parse(tokens: [
        BracketToken.open, SubToken.instance, DigitToken._5, BracketToken.close,
        GammaToken.instance,
      ]),
      "(((-(5)))!)"
    )
    try XCTAssertEqual(
      parse(tokens: [
        RootToken.instance, BracketToken.open, DigitToken._5, GammaToken.instance,
        BracketToken.close,
      ]),
      "(√(((5)!)))"
    )
  }

  func testFunctions() throws {
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.sin, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(sin(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.asin, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(asin(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.sinh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(sinh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.asinh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(asinh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(cos(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.acos, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(acos(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.cosh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(cosh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.acosh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(acosh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.tan, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(tan(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.atan, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(atan(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.tanh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(tanh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.atanh, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(atanh(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.log, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(log(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.lg, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(lg(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [FunctionToken.ln, BracketToken.open, DigitToken._0, BracketToken.close]),
      "(ln(0))"
    )

    try XCTAssertEqual(
      parse(tokens: [
        ConstToken.napier, FunctionToken.log, BracketToken.open, DigitToken._0, BracketToken.close,
      ]),
      "(e*log(0))"
    )
    try XCTAssertEqual(
      parse(tokens: [
        DigitToken._1, DivToken.instance, FunctionToken.sin, BracketToken.open, DigitToken._0,
        BracketToken.close, FunctionToken.cos, BracketToken.open, DigitToken._0, BracketToken.close,
      ]),
      "((1)÷(sin(0)*cos(0)))"
    )
  }
}
