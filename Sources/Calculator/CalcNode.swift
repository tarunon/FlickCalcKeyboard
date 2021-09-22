//
//  File.swift
//  
//
//  Created by tarunon on 2021/09/21.
//

import Numerics

protocol CalcNode: CustomStringConvertible {
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
  public var description: String {
    rawValue
  }
}

extension ConstToken: CalcNode {
  public var description: String {
    rawValue
  }
}

struct DigitsNode: CalcNode {
  var digits: [DigitToken]

  var result: Complex<Double> {
    get throws {
      let segments = digits.split(separator: .dot)
      if segments.count > 2 {
        throw CalcError.runtimeError(
          reason:
            "Too much `.` contains a number segment."
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

  var description: String {
    CalcFormatter.format(digits)
  }
}

struct GroupNode: CalcNode {
  var nodes: [CalcNode]
  
  var result: Complex<Double> {
    get throws {
      try nodes.map { try $0.result }.reduce(1, *)
    }
  }
  
  var description: String {
    "(" + nodes.map { "\($0)" }.joined(separator: "*") + ")"
  }
}

enum OperationNode: CalcNode {
  case infix(lhs: CalcNode, rhs: CalcNode, token: InfixOperatorToken)
  case prefix(rhs: CalcNode, token: PrefixOperatorToken)
  case postfix(lhs: CalcNode, token: PostfixOperatorToken)

  var result: Complex<Double> {
    get throws {
      switch self {
      case .infix(let lhs, let rhs, let token):
        return try token.operation(lhs: lhs.result, rhs: rhs.result)
      case .prefix(let rhs, let token):
        return try token.operation(rhs: rhs.result)
      case .postfix(let lhs, let token):
        return try token.operation(lhs: lhs.result)
      }
    }
  }

  var description: String {
    switch self {
    case .infix(let lhs, let rhs, let token):
      return "(\(lhs)\(token.rawValue)\(rhs))"
    case .prefix(let rhs, let token):
      return "(\(token.rawValue)\(rhs))"
    case .postfix(let lhs, let token):
      return "(\(lhs)\(token.rawValue))"
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

  var description: String {
    return "\(token.rawValue)\(node)"
  }
}
