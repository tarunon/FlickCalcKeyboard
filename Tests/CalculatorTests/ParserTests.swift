import XCTest

@testable import Calculator

final class ParserTests: XCTestCase {
  func testParse() {
    func parse(tokens: [CalcToken]) throws -> String {
      try CalcParsers.expr(precedence: .low).parse(tokens.reversed()).0.description
    }
    XCTAssertEqual(
      try parse(tokens: [DigitToken._1, SubToken.instance, DigitToken._2, SubToken.instance, DigitToken._3, SubToken.instance, DigitToken._4]),
      "((((1)-(2))-(3))-(4))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._1, AddToken.instance, DigitToken._2, MulToken.instance, DigitToken._3, PowToken.instance, DigitToken._4]),
      "((1)+((2)×((3)^(4))))"
    )
    XCTAssertEqual(
      try parse(tokens: [BracketToken.open, BracketToken.open, DigitToken._1, AddToken.instance, DigitToken._2, BracketToken.close, MulToken.instance, DigitToken._3, BracketToken.close, PowToken.instance, DigitToken._4]),
      "((((((1)+(2)))×(3)))^(4))"
    )
    XCTAssertEqual(
      try parse(tokens: [DigitToken._5, RootToken.instance, DigitToken._6, FunctionToken.sin, BracketToken.open, DigitToken._7, ConstToken.pi, BracketToken.close]),
      "((5)√(6*sin(7*π)))"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._8, GammaToken.instance]),
      "(-((8)!))"
    )
    XCTAssertEqual(
      try parse(tokens: [SubToken.instance, DigitToken._9, PowToken.instance, DigitToken._0]),
      "(-((9)^(0)))"
    )
  }
}
