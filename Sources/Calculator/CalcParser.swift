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
}

struct Parser<Input: RangeReplaceableCollection, Output> {
  var parse: (Input) throws -> (Output, Input)
}

extension Parser {
  static func pure(_ value: Output) -> Parser {
    return .init(parse: { (value, $0) })
  }

  static func empty() -> Parser {
    return .init(parse: { _ in throw ParseError.isEmpty })
  }

  func map<T>(_ f: @escaping (Output) throws -> T) -> Parser<Input, T> {
    flatMap { try Parser<Input, T>.pure(f($0)) }
  }
  
  func flatMap<T>(_ f: @escaping (Output) throws -> Parser<Input, T>) -> Parser<Input, T> {
    return Parser<Input, T> { input throws in
      let (result, input2) = try self.parse(input)
      return try f(result).parse(input2)
    }
  }

  func mapError(_ f: @escaping (Error) -> Error) -> Parser {
    flatMapError { throw f($0) }
  }
  
  func flatMapError(_ f: @escaping (Error) throws -> Parser) -> Parser {
    .init(parse: { input throws in
      do {
        return try self.parse(input)
      } catch (let error) {
        return try f(error).parse(input)
      }
    })
  }
  
  func assert(_ condition: @escaping (Output) -> Bool) -> Parser {
    self.map {
      guard condition($0) else {
        throw ParseError.conditionFailure
      }
      return $0
    }
  }

  static func ?? (lhs: Parser, rhs: @autoclosure @escaping () -> Parser) -> Parser {
    return lhs.flatMapError { _ in rhs() }
  }

  static func satisfy(to type: Output.Type = Output.self) -> Parser {
    return Parser { input throws in
      if input.isEmpty {
        throw ParseError.isEmpty
      }
      var tail = input
      guard let head = tail.removeFirst() as? Output else {
        throw ParseError.typeMissmatch
      }
      return (head, tail)
    }
  }
  
  func many(allowEmpty: Bool) -> Parser<Input, [Output]> {
    if allowEmpty {
      return many(allowEmpty: false) ?? .pure([])
    } else {
      return flatMap { output in
        return many(allowEmpty: true).map { [output] + $0 }
      }
    }
  }
}



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
      } ??
      prefixOperator(precedence: precedence).map { token in
        OperationNode.prefix(rhs: rhs, token: token)
      }
      ?? .pure(rhs)
    } ?? postfixOperator(precedence: precedence).flatMap { token in
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
    } ??
     number()).many(allowEmpty: false).map { GroupNode(nodes: $0.reversed()) }
  }
}

public func calc(tokens: [CalcToken]) throws -> Complex<Double> {
  do {
    let (head, tail) = try CalcParsers.expr(precedence: .low).parse(tokens.reversed())
    guard tail.isEmpty else {
      throw CalcError.parseError(reason: "Invalid tokens contained `\(tail.map { $0.rawValue }.joined())`")
    }
    return try head.result
  } catch (let error) {
    switch error {
    case ParseError.isEmpty:
      throw CalcError.tokensEmpty
    case ParseError.typeMissmatch:
      throw CalcError.parseError(reason: "")
    case ParseError.conditionFailure:
      throw CalcError.parseError(reason: "")
    default:
      throw error
    }
  }
}
