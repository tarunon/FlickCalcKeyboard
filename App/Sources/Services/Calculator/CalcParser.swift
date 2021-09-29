//
//  CalcParser.swift
//
//
//  Created by tarunon on 2021/09/21.
//

import Core
import Numerics
import Parsec

enum CalcParsers {
  typealias CalcParser<Output> = Parser<[CalcToken], Output>

  static let digit = CalcParser<DigitToken>.satisfy()
  static let dot = CalcParser<DotToken>.satisfy()
  static let const = CalcParser<ConstToken>.satisfy()
  static let function = CalcParser<FunctionToken>.satisfy()
  static let digits = digit.many(allowEmpty: false).flatMap { minor in
    dot.flatMap { _ in
      digit.many(allowEmpty: false).map { integer in
        return minor + [nil] + integer
      }
    } || .pure(minor)
  }.map { DigitsNode(digits: $0.reversed()) }
  static let number = digits.map { $0 as CalcNode } || const.map { $0 as CalcNode }

  static func bracket(open: Bool) -> CalcParser<BracketToken> {
    .satisfy().assert { $0 == (open ? .open : .close) }
  }

  static func infixOperator(precedence: Precedence) -> CalcParser<InfixOperatorToken> {
    .satisfy().assert { $0.precedence == precedence }
  }

  static func prefixOperator(precedence: Precedence) -> CalcParser<PrefixOperatorToken> {
    .satisfy().assert { $0.precedence == precedence }
  }

  static func postfixOperator(precedence: Precedence) -> CalcParser<PostfixOperatorToken> {
    .satisfy().assert { $0.precedence == precedence }
  }

  static func expr(precedence: Precedence) -> CalcParser<CalcNode> {
    highExpr(precendence: precedence).flatMap { rhs in
      infixOperator(precedence: precedence).flatMap { token in
        expr(precedence: precedence).map { lhs in
          OperationNode.infix(lhs: lhs, rhs: rhs, token: token)
        }
      }
        || prefixOperator(precedence: precedence).map { token in
          OperationNode.prefix(rhs: rhs, token: token)
        } || .pure(rhs)
    }
      || postfixOperator(precedence: precedence).flatMap { token in
        expr(precedence: precedence).map { lhs in
          OperationNode.postfix(lhs: lhs, token: token)
        }
      }
  }

  static func factor() -> CalcParser<CalcNode> {
    (bracket(open: false).flatMap { _ in
      expr(precedence: .low).flatMap { node in
        bracket(open: true).map { _ in node }
      }
    }.flatMap { node in
      function.map { token in
        FunctionNode(node: node, token: token)
      } || .pure(node)
    } || number)
    .many(allowEmpty: false)
    .map { GroupNode(nodes: $0.reversed()) }
  }

  static func highExpr(precendence: Precedence) -> CalcParser<CalcNode> {
    build {
      switch precendence {
      case .low: expr(precedence: .middle)
      case .middle: expr(precedence: .high)
      case .high: factor()
      }
    }
  }

  static let calc = expr(precedence: .low)
}
