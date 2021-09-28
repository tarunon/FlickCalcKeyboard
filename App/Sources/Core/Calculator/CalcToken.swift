//
//  Token.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Core
import Numerics

public protocol CalcToken {
  var rawValue: String { get }
}

public protocol NumberToken: CalcToken {
  func number() throws -> Complex<Double>
}

public enum Precedence: Int {
  case low
  case middle
  case high
}

public enum DigitToken: String, NumberToken {
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
  case dot = "."

  public func number() throws -> Complex<Double> {
    if self == .dot {
      throw CalcError.runtimeError(self)
    } else {
      return .init(Double(rawValue)!)
    }
  }
}

public enum ConstToken: NumberToken {
  case pi
  case napier
  case imaginaly
  case answer(answer: Complex<Double>)

  public var rawValue: String {
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

  public func number() throws -> Complex<Double> {
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

public protocol InfixOperatorToken: CalcToken {
  var precedence: Precedence { get }

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double>
}

public protocol PrefixOperatorToken: CalcToken {
  var precedence: Precedence { get }

  func operation(rhs: Complex<Double>) throws -> Complex<Double>
}

public protocol PostfixOperatorToken: CalcToken {
  var precedence: Precedence { get }

  func operation(lhs: Complex<Double>) throws -> Complex<Double>
}

public struct AddToken: InfixOperatorToken {
  public let precedence = Precedence.low
  public let rawValue: String = "+"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs + rhs
  }
}

public struct SubToken: InfixOperatorToken, PrefixOperatorToken {
  public let precedence = Precedence.low
  public let rawValue: String = "-"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs - rhs
  }

  public func operation(rhs: Complex<Double>) throws -> Complex<Double> {
    try operation(lhs: 0, rhs: rhs)
  }
}

public struct MulToken: InfixOperatorToken {
  public let precedence = Precedence.middle
  public let rawValue: String = "×"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs * rhs
  }
}

public struct DivToken: InfixOperatorToken {
  public let precedence = Precedence.middle
  public let rawValue: String = "÷"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    return lhs / rhs
  }
}

public struct ModToken: InfixOperatorToken {
  public let precedence = Precedence.high
  public let rawValue: String = "%"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    guard
      (lhs.imaginary.isZero || lhs.imaginary.isSubnormal)
        && (rhs.imaginary.isZero || rhs.imaginary.isSubnormal)
    else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))%(\(CalcFormatter.format(rhs)))")
    }
    return .init(lhs.real.truncatingRemainder(dividingBy: rhs.real))
  }
}

public struct PowToken: InfixOperatorToken {
  public let precedence = Precedence.high
  public let rawValue: String = "^"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    .pow(lhs, rhs)
  }
}

public struct RootToken: InfixOperatorToken, PrefixOperatorToken {
  public let precedence = Precedence.high
  public let rawValue: String = "√"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    guard
      (lhs.imaginary.isZero || lhs.imaginary.isSubnormal)
        && (lhs.real.truncatingRemainder(dividingBy: 1).isZero
          || lhs.real.truncatingRemainder(dividingBy: 1).isSubnormal)
    else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))√(\(CalcFormatter.format(rhs)))")
    }
    return .root(rhs, Int(lhs.real))
  }

  public func operation(rhs: Complex<Double>) throws -> Complex<Double> {
    try operation(lhs: 2, rhs: rhs)
  }
}

public struct GammaToken: PostfixOperatorToken {
  public let precedence = Precedence.high
  public let rawValue: String = "!"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>) throws -> Complex<Double> {
    guard lhs.imaginary.isZero || lhs.imaginary.isSubnormal else {
      throw CalcError.runtimeError("(\(CalcFormatter.format(lhs)))!")
    }
    return Complex(.gamma(lhs.real + 1.0))
  }
}

public enum BracketToken: String, Equatable, CalcToken {
  case open = "("
  case close = ")"
}

public struct FunctionToken: CalcToken {
  public static let sin = Self(rawValue: "sin", operation: Complex.sin)
  public static let sinh = Self(rawValue: "sinh", operation: Complex.sinh)
  public static let asin = Self(rawValue: "asin", operation: Complex.asin)
  public static let asinh = Self(rawValue: "asinh", operation: Complex.asinh)
  public static let cos = Self(rawValue: "cos", operation: Complex.cos)
  public static let cosh = Self(rawValue: "cosh", operation: Complex.cosh)
  public static let acos = Self(rawValue: "acos", operation: Complex.acos)
  public static let acosh = Self(rawValue: "acosh", operation: Complex.acosh)
  public static let tan = Self(rawValue: "tan", operation: Complex.tan)
  public static let tanh = Self(rawValue: "tanh", operation: Complex.tanh)
  public static let atan = Self(rawValue: "atan", operation: Complex.atan)
  public static let atanh = Self(rawValue: "atanh", operation: Complex.atanh)
  public static let log = Self(
    rawValue: "log",
    operation: { Complex.log($0) / Complex.log(10) }
  )
  public static let lg = Self(
    rawValue: "lg",
    operation: { Complex.log($0) / Complex.log(2) }
  )
  public static let ln = Self(rawValue: "ln", operation: Complex.log(_:))

  public let rawValue: String
  var operation: (Complex<Double>) -> Complex<Double>
}
