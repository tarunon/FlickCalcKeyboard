//
//  Token.swift
//
//
//  Created by tarunon on 2021/09/20.
//

enum Token: String, Hashable {
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
  case pi = "π"
  case napier = "e"
  case complex = "i"
  case dot = "."
  case add = "+"
  case sub = "-"
  case mul = "×"
  case div = "÷"
  case mod = "%"
  case pow = "^"
  case sqrt = "√"
  case factorial = "!"
  case sin
  case sinh
  case asin
  case asinh
  case cos
  case cosh
  case acos
  case acosh
  case tan
  case tanh
  case atan
  case atanh
  case lg
  case ln
  case bracketOpen = "("
  case bracketClose = ")"

  var isNumeric: Bool {
    switch self {
    case ._0, ._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, .dot:
      return true
    default:
      return false
    }
  }

  var isConstant: Bool {
    switch self {
    case .pi, .napier, .complex:
      return true
    default:
      return false
    }
  }
}
