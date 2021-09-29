//
//  File.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import Core

public enum ParseError: Error {
  case isEmpty
  case typeMissmatch(expect: Any.Type, actual: Any)
  case conditionFailure(value: Any)
  case notComplete(tokens: [Any])
}

public struct ParseResult<Input: RangeReplaceableCollection, Output> {
  var output: Output
  var input: Input

  // swift-format-ignore
  public var value: Output {
    get throws {
      guard input.isEmpty else {
        throw ParseError.notComplete(tokens: input.map { $0 })
      }
      return output
    }
  }
}

public struct Parser<Input: RangeReplaceableCollection, Output> {
  public typealias Result = ParseResult<Input, Output>
  var parse: (Input) throws -> Result

  public init(parse: @escaping @Sendable (Input) throws -> Result) {
    self.parse = parse
  }

  public func callAsFunction(_ input: Input) throws -> Result {
    try parse(input)
  }
}

extension ParseResult: Equatable where Input: Equatable, Output: Equatable {

}

extension Parser {
  public static func pure(_ value: Output) -> Parser {
    return .init(parse: { .init(output: value, input: $0) })
  }

  public static func empty() -> Parser {
    return .init(parse: { _ in throw ParseError.isEmpty })
  }

  public func map<T>(_ f: @escaping (Output) throws -> T) -> Parser<Input, T> {
    flatMap { try Parser<Input, T>.pure(f($0)) }
  }

  public func flatMap<T>(_ f: @escaping (Output) throws -> Parser<Input, T>) -> Parser<Input, T> {
    return Parser<Input, T> { input throws in
      let result = try self(input)
      return try f(result.output)(result.input)
    }
  }

  public func mapError(_ f: @escaping (Error) -> Error) -> Parser {
    flatMapError { throw f($0) }
  }

  public func flatMapError(_ f: @escaping (Error) throws -> Parser) -> Parser {
    .init(parse: { input throws in
      do {
        return try self(input)
      } catch (let error) {
        return try f(error)(input)
      }
    })
  }

  public func assert(_ condition: @escaping (Output) -> Bool) -> Parser {
    self.map {
      guard condition($0) else {
        throw ParseError.conditionFailure(value: $0)
      }
      return $0
    }
  }

  public static func || (lhs: Parser, rhs: @autoclosure @escaping () -> Parser) -> Parser {
    return lhs.flatMapError { _ in rhs() }
  }

  public static func satisfy(to type: Output.Type = Output.self) -> Parser {
    return Parser { input throws in
      if input.isEmpty {
        throw ParseError.isEmpty
      }
      var tail = input
      let head = tail.removeFirst()
      guard let head = head as? Output else {
        throw ParseError.typeMissmatch(expect: Output.self, actual: head)
      }
      return .init(output: head, input: tail)
    }
  }

  public func many(allowEmpty: Bool) -> Parser<Input, [Output]> {
    build {
      if allowEmpty {
        many(allowEmpty: false) || .pure([])
      } else {
        flatMap { output in
          return many(allowEmpty: true).map { [output] + $0 }
        }
      }
    }
  }
}

extension Parser where Input.Element == Output {

  public static func satisfy(_ isSatisfy: @escaping (Input.Element) -> Bool) -> Parser {
    return Parser { input throws in
      if input.isEmpty {
        throw ParseError.isEmpty
      }
      var tail = input
      let head = tail.removeFirst()
      guard isSatisfy(head) else {
        throw ParseError.conditionFailure(value: head)
      }
      return .init(output: head, input: tail)
    }
  }
}

extension Parser where Input.Element == Output, Input.Element: Equatable {
  public static func satisfy(to value: Input.Element) -> Parser {
    .satisfy { $0 == value }
  }
}
