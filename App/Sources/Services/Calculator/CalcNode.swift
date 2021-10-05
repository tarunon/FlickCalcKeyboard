//
//  File.swift
//
//
//  Created by tarunon on 2021/09/21.
//

import Core
import Numerics

protocol CalcNode: CustomStringConvertible {
  func result() throws -> Complex<Double>
}

extension NumberToken where Self: CalcNode {
  func result() throws -> Complex<Double> {
    try number()
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
  var digits: [DigitToken?]

  func result() throws -> Complex<Double> {
    let segments = digits.split(separator: nil)
    if segments.count > 2 {
      throw CalcError.runtimeError(description)
    }
    let result = try segments[0]
      .compactMap { try $0?.number() }.reduce(0) { $0 * 10 + $1 }
    if segments.count == 2 {
      return result
        + (try segments[1].compactMap { try $0?.number() }.reversed().reduce(0) { $0 / 10 + $1 })
        / 10
    }
    return result
  }

  var description: String {
    digits.split(separator: nil).map { part in
      part.compactMap { $0 }.text
    }.joined(separator: ".")
  }
}

struct GroupNode: CalcNode {
  var nodes: [CalcNode]

  func result() throws -> Complex<Double> {
    try nodes.map { try $0.result() }.reduce(1, *)
  }

  var description: String {
    "(" + nodes.map { "\($0)" }.joined(separator: "*") + ")"
  }
}

enum OperationNode: CalcNode {
  case infix(lhs: CalcNode, rhs: CalcNode, token: InfixOperatorToken)
  case prefix(rhs: CalcNode, token: PrefixOperatorToken)
  case postfix(lhs: CalcNode, token: PostfixOperatorToken)

  func result() throws -> Complex<Double> {
    try build {
      switch self {
      case .infix(let lhs, let rhs, let token):
        try token.operation(lhs: lhs.result(), rhs: rhs.result())
      case .prefix(let rhs, let token):
        try token.operation(rhs: rhs.result())
      case .postfix(let lhs, let token):
        try token.operation(lhs: lhs.result())
      }
    }
  }

  var description: String {
    build {
      switch self {
      case .infix(let lhs, let rhs, let token):
        "(\(lhs)\(token.rawValue)\(rhs))"
      case .prefix(let rhs, let token):
        "(\(token.rawValue)\(rhs))"
      case .postfix(let lhs, let token):
        "(\(lhs)\(token.rawValue))"
      }
    }
  }
}

struct FunctionNode: CalcNode {
  var node: CalcNode
  var token: FunctionToken

  func result() throws -> Complex<Double> {
    try token.operation(node.result())
  }

  var description: String {
    return "\(token.rawValue)\(node)"
  }
}
