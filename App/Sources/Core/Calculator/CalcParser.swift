//
//  CalcParser.swift
//
//
//  Created by tarunon on 2021/09/21.
//

import Foundation
import Numerics
import Parsec

enum CalcParsers {
  typealias CalcParser<Output> = Parser<[CalcToken], Output>

  static func digit() -> CalcParser<DigitToken> {
    .satisfy()
  }

  static func const() -> CalcParser<ConstToken> {
    .satisfy()
  }

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

  static func function() -> CalcParser<FunctionToken> {
    .satisfy()
  }

  static func digits() -> CalcParser<DigitsNode> {
    digit().many(allowEmpty: false).map { DigitsNode(digits: $0.reversed()) }
  }

  static func number() -> CalcParser<CalcNode> {
    digits().map { $0 as CalcNode } ?? const().map { $0 as CalcNode }
  }

  static func expr(precedence: Precedence) -> CalcParser<CalcNode> {
    (precedence.next().map(expr(precedence:)) ?? factor()).flatMap { rhs in
      infixOperator(precedence: precedence).flatMap { token in
        expr(precedence: precedence).map { lhs in
          OperationNode.infix(lhs: lhs, rhs: rhs, token: token)
        }
      } ?? prefixOperator(precedence: precedence).map { token in
        OperationNode.prefix(rhs: rhs, token: token)
      }
        ?? .pure(rhs)
    }
      ?? postfixOperator(precedence: precedence).flatMap { token in
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
      function().map { token in
        FunctionNode(node: node, token: token)
      }.flatMapError { _ in .pure(node) }
    } ?? number()).many(allowEmpty: false).map { GroupNode(nodes: $0.reversed()) }
  }
}
