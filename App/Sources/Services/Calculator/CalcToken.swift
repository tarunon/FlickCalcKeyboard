//
//  Token.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Core
import Foundation
import Numerics

public struct CalcToken: Equatable {
  var value: CalcTokenProtocol
  public var rawValue: String { value.rawValue }

  public static func == (lhs: CalcToken, rhs: CalcToken) -> Bool {
    lhs.value.isEqual(to: rhs.value)
  }
}

extension CalcToken {
  public enum Digit {
    public static let _0 = CalcToken(value: DigitToken._0)
    public static let _1 = CalcToken(value: DigitToken._1)
    public static let _2 = CalcToken(value: DigitToken._2)
    public static let _3 = CalcToken(value: DigitToken._3)
    public static let _4 = CalcToken(value: DigitToken._4)
    public static let _5 = CalcToken(value: DigitToken._5)
    public static let _6 = CalcToken(value: DigitToken._6)
    public static let _7 = CalcToken(value: DigitToken._7)
    public static let _8 = CalcToken(value: DigitToken._8)
    public static let _9 = CalcToken(value: DigitToken._9)
    public static let dot = CalcToken(value: DotToken.instance)
  }

  public enum Const {
    public static let pi = CalcToken(value: ConstToken.pi)
    public static let napier = CalcToken(value: ConstToken.napier)
    public static let imaginaly = CalcToken(value: ConstToken.imaginaly)
    public static func answer(_ answer: Complex<Double>) -> CalcToken {
      .init(value: ConstToken.answer(answer: answer))
    }
  }

  public enum Bracket {
    public static let open = CalcToken(value: BracketToken.open)
    public static let close = CalcToken(value: BracketToken.close)
  }

  public enum Operator {
    public static let add = CalcToken(value: AddToken.instance)
    public static let sub = CalcToken(value: SubToken.instance)
    public static let mul = CalcToken(value: MulToken.instance)
    public static let div = CalcToken(value: DivToken.instance)
    public static let mod = CalcToken(value: ModToken.instance)
    public static let pow = CalcToken(value: PowToken.instance)
    public static let root = CalcToken(value: RootToken.instance)
    public static let gamma = CalcToken(value: GammaToken.instance)
  }

  public enum Function {
    public static let sin = CalcToken(value: FunctionToken.sin)
    public static let asin = CalcToken(value: FunctionToken.asin)
    public static let sinh = CalcToken(value: FunctionToken.sinh)
    public static let asinh = CalcToken(value: FunctionToken.asinh)
    public static let cos = CalcToken(value: FunctionToken.cos)
    public static let acos = CalcToken(value: FunctionToken.acos)
    public static let cosh = CalcToken(value: FunctionToken.cosh)
    public static let acosh = CalcToken(value: FunctionToken.acosh)
    public static let tan = CalcToken(value: FunctionToken.tan)
    public static let atan = CalcToken(value: FunctionToken.atan)
    public static let tanh = CalcToken(value: FunctionToken.tanh)
    public static let atanh = CalcToken(value: FunctionToken.atanh)
    public static let log = CalcToken(value: FunctionToken.log)
    public static let ln = CalcToken(value: FunctionToken.ln)
    public static let lg = CalcToken(value: FunctionToken.lg)
  }

  public var isDigit: Bool {
    value is DigitToken
  }

  public var isNumber: Bool {
    value is NumberToken
  }

  public var isBracket: Bool {
    value is BracketToken
  }

  public var isAnswer: Bool {
    if let const = value as? ConstToken,
      case .answer = const
    {
      return true
    } else {
      return false
    }
  }
}

protocol CalcTokenProtocol {
  var rawValue: String { get }
  func isEqual(to: CalcTokenProtocol) -> Bool
}

extension CalcTokenProtocol where Self: Equatable {
  func isEqual(to other: CalcTokenProtocol) -> Bool {
    self == other as? Self
  }
}

extension CalcTokenProtocol {
  func isEqual(to other: CalcTokenProtocol) -> Bool {
    false
  }
}

extension Sequence where Element == CalcTokenProtocol {
  var text: String {
    map { $0.rawValue }.joined()
  }
}

protocol NumberToken: CalcTokenProtocol {
  func number() throws -> Complex<Double>
}

enum Precedence: Int, Equatable {
  case low
  case middle
  case high
}

enum DigitToken: String, NumberToken {
  case _0 = "0"
  case _1 = "1"
  case _2 = "2"
  case _3 = "3"
  case _4 = "4"
  case _5 = "5"
  case _6 = "6"
  case _7 = "7"
  case _8 = "8"
  case _9 = "9"

  func number() throws -> Complex<Double> {
    return .init(Double(rawValue)!)
  }
}

struct DotToken: CalcTokenProtocol, Equatable {
  let rawValue: String = "."
  static let instance = DotToken()
}

enum ConstToken: NumberToken {
  case pi
  case napier
  case imaginaly
  case answer(answer: Complex<Double>)

  var rawValue: String {
    build {
      switch self {
      case .pi: "π"
      case .napier: "e"
      case .imaginaly: "i"
      case .answer(let answer):
        "(\(CalcFormatter.format(answer)))"
      }
    }
  }

  func number() throws -> Complex<Double> {
    build {
      switch self {
      case .pi:
        Complex<Double>.init(.pi)
      case .napier:
        Complex<Double>.init(.exp(1))
      case .imaginaly:
        Complex<Double>.init(imaginary: 1.0)
      case .answer(let answer):
        answer
      }
    }
  }
}

protocol InfixOperatorToken: CalcTokenProtocol {
  var precedence: Precedence { get }

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double>
}

protocol PrefixOperatorToken: CalcTokenProtocol {
  var precedence: Precedence { get }

  func operation(rhs: Complex<Double>) throws -> Complex<Double>
}

protocol PostfixOperatorToken: CalcTokenProtocol {
  var precedence: Precedence { get }

  func operation(lhs: Complex<Double>) throws -> Complex<Double>
}

struct AddToken: InfixOperatorToken, Equatable {
  let precedence = Precedence.low
  let rawValue: String = "+"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs + rhs
  }
}

struct SubToken: InfixOperatorToken, PrefixOperatorToken, Equatable {
  let precedence = Precedence.low
  let rawValue: String = "-"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs - rhs
  }

  func operation(rhs: Complex<Double>) throws -> Complex<Double> {
    try operation(lhs: 0, rhs: rhs)
  }
}

struct MulToken: InfixOperatorToken, Equatable {
  let precedence = Precedence.middle
  let rawValue: String = "×"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs * rhs
  }
}

struct DivToken: InfixOperatorToken, Equatable {
  let precedence = Precedence.middle
  let rawValue: String = "÷"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    return lhs / rhs
  }
}

struct ModToken: InfixOperatorToken, Equatable {
  let precedence = Precedence.high
  let rawValue: String = "%"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    guard
      (lhs.imaginary.isZero || lhs.imaginary.isSubnormal)
        && (rhs.imaginary.isZero || rhs.imaginary.isSubnormal)
    else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))%(\(CalcFormatter.format(rhs)))")
    }
    return .init(lhs.real.truncatingRemainder(dividingBy: rhs.real))
  }
}

struct PowToken: InfixOperatorToken, Equatable {
  let precedence = Precedence.high
  let rawValue: String = "^"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    .pow(lhs, rhs)
  }
}

struct RootToken: InfixOperatorToken, PrefixOperatorToken, Equatable {
  let precedence = Precedence.high
  let rawValue: String = "√"

  static let instance = Self()

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    guard
      (lhs.imaginary.isZero || lhs.imaginary.isSubnormal)
        && (lhs.real.truncatingRemainder(dividingBy: 1).isZero
          || lhs.real.truncatingRemainder(dividingBy: 1).isSubnormal)
    else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))√(\(CalcFormatter.format(rhs)))")
    }
    return .root(rhs, Int(lhs.real))
  }

  func operation(rhs: Complex<Double>) throws -> Complex<Double> {
    try operation(lhs: 2, rhs: rhs)
  }
}

struct GammaToken: PostfixOperatorToken, Equatable {
  let precedence = Precedence.high
  let rawValue: String = "!"

  static let instance = Self()

  func operation(lhs: Complex<Double>) throws -> Complex<Double> {
    guard lhs.imaginary.isZero || lhs.imaginary.isSubnormal else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))!")
    }
    return Complex(.gamma(lhs.real + 1.0))
  }
}

enum BracketToken: String, Equatable, CalcTokenProtocol {
  case open = "("
  case close = ")"
}

struct FunctionToken: CalcTokenProtocol {
  static let sin = Self(rawValue: "sin", operation: Complex.sin)
  static let sinh = Self(rawValue: "sinh", operation: Complex.sinh)
  static let asin = Self(rawValue: "asin", operation: Complex.asin)
  static let asinh = Self(rawValue: "asinh", operation: Complex.asinh)
  static let cos = Self(rawValue: "cos", operation: Complex.cos)
  static let cosh = Self(rawValue: "cosh", operation: Complex.cosh)
  static let acos = Self(rawValue: "acos", operation: Complex.acos)
  static let acosh = Self(rawValue: "acosh", operation: Complex.acosh)
  static let tan = Self(rawValue: "tan", operation: Complex.tan)
  static let tanh = Self(rawValue: "tanh", operation: Complex.tanh)
  static let atan = Self(rawValue: "atan", operation: Complex.atan)
  static let atanh = Self(rawValue: "atanh", operation: Complex.atanh)
  static let log = Self(
    rawValue: "log",
    operation: { Complex.log($0) / Complex.log(10) }
  )
  static let lg = Self(
    rawValue: "lg",
    operation: { Complex.log($0) / Complex.log(2) }
  )
  static let ln = Self(rawValue: "ln", operation: Complex.log(_:))

  let rawValue: String
  let operation: (Complex<Double>) -> Complex<Double>
}
