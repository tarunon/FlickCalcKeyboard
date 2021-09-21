//
//  CalcParser.swift
//  
//
//  Created by tarunon on 2021/09/21.
//

import Foundation
import Numerics

enum ParseError: Error {
  case isEmpty
  case typeMissmatch
  case conditionFailure
  case cantUseAllTokens
}

struct Parser<Input, Output> {
  var parse: (Input) throws -> (Output, Input)
}


extension Parser {
  static func pure(_ value: Output) -> Parser {
    return .init(parse: { (value, $0) })
  }

  static func empty() -> Parser {
    return .init(parse: { _ in throw ParseError.isEmpty })
  }

  func flatMap<T>(_ f: @escaping (Output) throws -> Parser<Input, T>) -> Parser<Input, T> {
    return Parser<Input, T> { input throws in
      let (result, input2) = try self.parse(input)
      return try f(result).parse(input2)
    }
  }

  func map<T>(_ f: @escaping (Output) throws -> T) -> Parser<Input, T> {
    flatMap { try Parser<Input, T>.pure(f($0)) }
  }

  static func ?? (lhs: Parser, rhs: Parser) -> Parser {
    return Parser { input in
      do {
        return try lhs.parse(input)
      } catch {
        return try rhs.parse(input)
      }
    }
  }
}



enum CalcParsers {
  typealias CalcParser<Output> = Parser<[CalcToken], Output>
  static func uncons<T>(_ list: [CalcToken], headType: T.Type = T.self) throws -> (head: T, tail: [CalcToken]) {
    if list.isEmpty {
      throw ParseError.isEmpty
    }
    var tail = list
    if let head = tail.removeFirst() as? T {
      return (head: head, tail: tail)
    }
    throw ParseError.typeMissmatch
  }

  static func satisfy<T>(to type: T.Type, condition: @escaping (T) -> Bool = { _ in true }) -> CalcParser<T> {
    return CalcParser<T> { input throws in
      let result = try uncons(input, headType: T.self)
      if condition(result.head) {
        return result
      } else {
        throw ParseError.conditionFailure
      }
    }
  }

  static func many<A>(_ p: CalcParser<A>) -> CalcParser<[A]> {
    many1(p) ?? CalcParser.pure([])
  }

  static func many1<A>(_ p: CalcParser<A>) -> CalcParser<[A]> {
    return p.map { a in return { (list: [A]) in [a] + list } }.flatMap { f in
      many(p).map { f($0) }
    }
  }

  static func digit() -> CalcParser<DigitToken> {
    satisfy(to: DigitToken.self)
  }

  static func digits() -> CalcParser<DigitsNode> {
    many1(digit()).map(DigitsNode.init)
  }

  static func const() -> CalcParser<ConstToken> {
    satisfy(to: ConstToken.self)
  }

  static func number() -> CalcParser<CalcNode> {
    digits().map { $0 as CalcNode } ?? const().map { $0 as CalcNode }
  }

  static func monomial() -> CalcParser<CalcNode> {
    number().flatMap { x in
      monomial().map { y in OperationNode.infix(lhs: x, rhs: y, token: MulToken.instance) }
    } ?? number()
  }

  static func bracket(open: Bool) -> CalcParser<BracketToken> {
    satisfy(to: BracketToken.self, condition: { $0 == (open ? .open : .close) })
  }

  static func infixOperator(precedence: Precedence) -> CalcParser<InfixOperatorToken> {
    satisfy(to: InfixOperatorToken.self, condition: { $0.precedence == precedence })
  }

  static func prefixOperator(precedence: Precedence) -> CalcParser<PrefixOperatorToken> {
    satisfy(to: PrefixOperatorToken.self, condition: { $0.precedence == precedence })
  }

  static func postfixOperator(precedence: Precedence) -> CalcParser<PostfixOperatorToken> {
    satisfy(to: PostfixOperatorToken.self, condition: { $0.precedence == precedence })
  }

  static func expr(precedence: Precedence) -> CalcParser<CalcNode> {
    (precedence.next().map(expr(precedence:)) ?? factor()).flatMap { lhs in
      infixOperator(precedence: precedence).flatMap { token in
        expr(precedence: precedence).map { rhs in
          OperationNode.infix(lhs: lhs, rhs: rhs, token: token)
        }
      } ??
      postfixOperator(precedence: precedence).map { token in
        OperationNode.postfix(lhs: lhs, token: token)
      }
      ?? .pure(lhs)
    } ?? prefixOperator(precedence: precedence).flatMap { token in
      expr(precedence: precedence).map { rhs in
        OperationNode.prefix(rhs: rhs, token: token)
      }
    }
  }

  static func factor() -> CalcParser<CalcNode> {
    bracket(open: true).flatMap { _ in
      expr(precedence: .low).flatMap { node in
        bracket(open: false).map { _ in node }
      }
    } ?? monomial()
  }
}

public func calc(tokens: [CalcToken]) throws -> Complex<Double> {
  let (head, tail) = try CalcParsers.expr(precedence: .low).parse(tokens)
  guard tail.isEmpty else {
    throw ParseError.cantUseAllTokens
  }
  return try head.result
}
