//
//  Token.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Numerics

public protocol CalcToken {
  var rawValue: String { get }
}

public protocol NumberToken: CalcToken {
  var number: Complex<Double> { get throws }
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
  
  public var number: Complex<Double> {
    get throws {
      if self == .dot {
        throw CalcError.runtimeError(reason: "Token `.` cannot be evaluated.")
      } else {
        return .init(Double(rawValue)!)
      }
    }
  }
}

public enum ConstToken: String, NumberToken {
  case pi = "π"
  case napier = "e"
  case complex = "i"
  
  public var number: Complex<Double> {
    switch self {
    case .pi:
      return .init(.pi)
    case .napier:
      return .init(.exp(1))
    case .complex:
      return .init(imaginary: 1.0)
    }
  }
}

public protocol InfixOperatorToken: CalcToken {
  var precedence: Int { get }

  func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double>
}

public protocol PrefixOperatorToken: CalcToken {
  var precedence: Int { get }

  func operation(rhs: Complex<Double>) throws -> Complex<Double>
}

public protocol PostfixOperatorToken: CalcToken {
  var precedence: Int { get }

  func operation(lhs: Complex<Double>) throws -> Complex<Double>
}

public struct AddToken: InfixOperatorToken {
  public let precedence = 10
  public let rawValue: String = "+"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs + rhs
  }
}

public struct SubToken: InfixOperatorToken, PrefixOperatorToken {
  public let precedence = 10
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
  public let precedence = 20
  public let rawValue: String = "×"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    lhs * rhs
  }
}

public struct DivToken: InfixOperatorToken {
  public let precedence = 20
  public let rawValue: String = "÷"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    if rhs == 0 {
      throw CalcError.runtimeError(reason: "0 division error.")
    }
    return lhs / rhs
  }
}

public struct ModToken: InfixOperatorToken {
  public let precedence = 50
  public let rawValue: String = "%"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    if rhs == 0 {
      throw CalcError.runtimeError(reason: "0 division error.")
    }
    guard lhs.imaginary.isSubnormal && rhs.imaginary.isSubnormal else {
      throw CalcError.runtimeError(reason: "Modulo of complex numbers is not supported.")
    }
    return .init(lhs.real.truncatingRemainder(dividingBy: rhs.real))
  }
}

public struct PowToken: InfixOperatorToken {
  public let precedence = 50
  public let rawValue: String = "^"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    .pow(lhs, rhs)
  }
}

public struct RootToken: InfixOperatorToken, PrefixOperatorToken {
  public let precedence = 30
  public let rawValue: String = "√"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>, rhs: Complex<Double>) throws -> Complex<Double> {
    guard lhs.imaginary.isSubnormal && lhs.real.truncatingRemainder(dividingBy: 1).isSubnormal else {
      throw CalcError.runtimeError(reason: "Root operator require index as integer.")
    }
    return .root(rhs, Int(lhs.real))
  }

  public func operation(rhs: Complex<Double>) throws -> Complex<Double> {
    try operation(lhs: 2, rhs: rhs)
  }
}

public struct GammaToken: PostfixOperatorToken {
  public let precedence = 70
  public let rawValue: String = "!"

  public static let instance = Self()

  public func operation(lhs: Complex<Double>) throws -> Complex<Double> {
    let xr = lhs.real
    let xi = lhs.imaginary
    var wr: Double
    var wi : Double
    if xr < 0 {
        wr = 1 - xr
        wi = -xi
    } else {
        wr = xr
        wi = xi
    }
    var ur = wr + 6.00009857740312429
    var vr = ur * (wr + 4.99999857982434025) - wi * wi
    var vi = wi * (wr + 4.99999857982434025) + ur * wi
    var yr = ur * 13.2280130755055088 + vr * 66.2756400966213521 + 0.293729529320536228
    var yi = wi * 13.2280130755055088 + vi * 66.2756400966213521
    ur = vr * (wr + 4.00000003016801681) - vi * wi
    var ui = vi * (wr + 4.00000003016801681) + vr * wi
    vr = ur * (wr + 2.99999999944915534) - ui * wi
    vi = ui * (wr + 2.99999999944915534) + ur * wi
    yr += ur * 91.1395751189899762 + vr * 47.3821439163096063
    yi += ui * 91.1395751189899762 + vi * 47.3821439163096063
    ur = vr * (wr + 2.00000000000603851) - vi * wi
    ui = vi * (wr + 2.00000000000603851) + vr * wi
    vr = ur * (wr + 0.999999999999975753) - ui * wi
    vi = ui * (wr + 0.999999999999975753) + ur * wi
    yr += ur * 10.5400280458730808 + vr
    yi += ui * 10.5400280458730808 + vi
    ur = vr * wr - vi * wi
    ui = vi * wr + vr * wi
    let t = ur * ur + ui * ui
    vr = yr * ur + yi * ui + t * 0.0327673720261526849
    vi = yi * ur - yr * ui
    yr = wr + 7.31790632447016203
    ur = Double.log(yr * yr + wi * wi) * 0.5 - 1
    ui = Double.atan2(y: wi, x: yr)
    yr = Double.exp(ur * (wr - 0.5) - ui * wi - 3.48064577727581257) / t
    yi = ui * (wr - 0.5) + ur * wi
    ur = yr * Double.cos(yi)
    ui = yr * Double.sin(yi)
    yr = ur * vr - ui * vi
    yi = ui * vr + ur * vi
    if xr < 0 {
      wr = xr * 3.14159265358979324
      wi = Double.exp(xi * 3.14159265358979324)
      vi = 1 / wi
      ur = (vi + wi) * Double.sin(wr)
      ui = (vi - wi) * Double.cos(wr)
      vr = ur * yr + ui * yi
      vi = ui * yr - ur * yi
      ur = 6.2831853071795862 / (vr * vr + vi * vi)
      yr = ur * vr
      yi = ur * vi
    }
    return Complex<Double>.init(yr, yi)
  }
}

public enum BracketToken: String, Equatable, CalcToken {
  case open = "("
  case close = ")"
}

public struct FunctionToken: CalcToken {
  public static let sin = Self(rawValue: "sin", operation: Complex<Double>.sin)
  public static let sinh = Self(rawValue: "sinh", operation: Complex<Double>.sinh)
  public static let asin = Self(rawValue: "asin", operation: Complex<Double>.asin)
  public static let asinh = Self(rawValue: "asinh", operation: Complex<Double>.asinh)
  public static let cos = Self(rawValue: "cos", operation: Complex<Double>.cos)
  public static let cosh = Self(rawValue: "cosh", operation: Complex<Double>.cosh)
  public static let acos = Self(rawValue: "acos", operation: Complex<Double>.acos)
  public static let acosh = Self(rawValue: "acosh", operation: Complex<Double>.acosh)
  public static let tan = Self(rawValue: "tan", operation: Complex<Double>.tan)
  public static let tanh = Self(rawValue: "tanh", operation: Complex<Double>.tanh)
  public static let atan = Self(rawValue: "atan", operation: Complex<Double>.atan)
  public static let atanh = Self(rawValue: "atanh", operation: Complex<Double>.atanh)
  public static let log = Self(rawValue: "log", operation: { Complex<Double>.log($0) / Complex.log(10) })
  public static let lg = Self(rawValue: "lg", operation: { Complex<Double>.log($0) / Complex.log(2) })
  public static let ln = Self(rawValue: "ln", operation: Complex<Double>.log(_:))

  public let rawValue: String
  var operation: (Complex<Double>) -> Complex<Double>
}
