//
//  File.swift
//  
//
//  Created by tarunon on 2021/09/21.
//

import Numerics

protocol CalcNode {
  var result: Complex<Double> { get throws }
}

extension NumberToken where Self: CalcNode {
  var result: Complex<Double> {
    get throws {
      try number
    }
  }
}

extension DigitToken: CalcNode {
}

extension ConstToken: CalcNode {
}

struct Digits: CalcNode {
  var digits: [DigitToken]

  var result: Complex<Double> {
    get throws {
      let segments = digits.split(separator: .dot)
      if segments.count > 2 {
        throw CalcError.runtimeError(
          reason:
            "Too much token `.` contains a number segment in `\(digits.map { $0.rawValue }.joined())`"
        )
      }
      let result = try segments[0].map { try $0.number }.reduce(0) { $0 * 10 + $1 }
      if segments.count == 2 {
        return result + (try segments[1].map { try $0.number }.reversed().reduce(0) { $0 / 10 + $1 })
          / 10
      }
      return result
    }
  }
}

enum OperationNode: CalcNode {
  case infx(lhs: CalcNode, rhs: CalcNode, token: InfixOperatorToken)
  case prefix(rhs: CalcNode, token: PrefixOperatorToken)
  case postfix(lhs: CalcNode, token: PostfixOperatorToken)

  var result: Complex<Double> {
    get throws {
      switch self {
      case .infx(let lhs, let rhs, let token):
        return try token.operation(lhs: lhs.result, rhs: rhs.result)
      case .prefix(let rhs, let token):
        return try token.operation(rhs: rhs.result)
      case .postfix(let lhs, let token):
        return try token.operation(lhs: lhs.result)
      }
    }
  }
}

struct FunctionNode: CalcNode {
  var node: CalcNode
  var token: FunctionToken

  var result: Complex<Double> {
    get throws {
      try token.operation(node.result)
    }
  }
}
