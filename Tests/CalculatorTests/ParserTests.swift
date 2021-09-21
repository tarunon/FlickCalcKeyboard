import XCTest

@testable import Calculator

final class ParserTests: XCTestCase {
  func testParseDigitsSuccses() throws {
    let tokens: [CalcToken] = [DigitToken._3, DigitToken.dot, DigitToken._1, DigitToken._4, ConstToken.pi]
    let result = try CalcParsers.digits().parse(tokens)
    print(result)
    XCTAssertEqual(result.0.digits.count, 4)
    XCTAssertEqual(result.1.count, 1)
  }

  func testMonomial() throws {
    let tokens: [CalcToken] = [DigitToken._3, DigitToken.dot, DigitToken._1, DigitToken._4, ConstToken.pi]
    let result = try CalcParsers.monomial().parse(tokens)
    print(result)
    XCTAssertEqual(result.0 is OperationNode, true)
    XCTAssertEqual(result.1.count, 0)
  }

  func testExprLow() throws {
    let tokens: [CalcToken] = [DigitToken._3, DigitToken.dot, DigitToken._1, DigitToken._4, AddToken.instance, ConstToken.pi]
    let result = try CalcParsers.expr(precedence: .low).parse(tokens)
    print(result)
    XCTAssertEqual(result.0 is OperationNode, true)
    XCTAssertEqual(result.1.count, 0)
  }

  func testExprMid() throws {
    let tokens: [CalcToken] = [DigitToken._3, MulToken.instance, DigitToken._1, DigitToken._4, AddToken.instance, ConstToken.pi]
    let result = try CalcParsers.expr(precedence: .low).parse(tokens)
    print(result)
    XCTAssertEqual(result.0 is OperationNode, true)
    XCTAssertEqual(result.1.count, 0)
  }

  func testExprMid2() throws {
    let tokens: [CalcToken] = [DigitToken._3, AddToken.instance, DigitToken._1, DigitToken._4, MulToken.instance, ConstToken.pi]
    let result = try CalcParsers.expr(precedence: .low).parse(tokens)
    print(result)
    XCTAssertEqual(result.0 is OperationNode, true)
    XCTAssertEqual(result.1.count, 0)
  }
}
