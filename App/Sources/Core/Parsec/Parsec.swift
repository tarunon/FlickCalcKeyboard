//
//  File.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import Builder

public enum ParseError: Error {
  case isEmpty
  case typeMissmatch(expect: Any.Type, actual: Any)
  case conditionFailure(value: Any)
}

public struct Parser<Input: RangeReplaceableCollection, Output> {
  var _parse: (Input) throws -> (Output, Input)

  public init(parse: @escaping @Sendable (Input) throws -> (Output, Input)) {
    self._parse = parse
  }

  public func parse(_ input: Input) throws -> (Output, Input) {
    try _parse(input)
  }
}

extension Parser {
  public static func pure(_ value: Output) -> Parser {
    return .init(parse: { (value, $0) })
  }

  public static func empty() -> Parser {
    return .init(parse: { _ in throw ParseError.isEmpty })
  }

  public func map<T>(_ f: @escaping (Output) throws -> T) -> Parser<Input, T> {
    flatMap { try Parser<Input, T>.pure(f($0)) }
  }

  public func flatMap<T>(_ f: @escaping (Output) throws -> Parser<Input, T>) -> Parser<Input, T> {
    return Parser<Input, T> { input throws in
      let (result, input2) = try self.parse(input)
      return try f(result).parse(input2)
    }
  }

  public func mapError(_ f: @escaping (Error) -> Error) -> Parser {
    flatMapError { throw f($0) }
  }

  public func flatMapError(_ f: @escaping (Error) throws -> Parser) -> Parser {
    .init(parse: { input throws in
      do {
        return try self.parse(input)
      } catch (let error) {
        return try f(error).parse(input)
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

  public static func ?? (lhs: Parser, rhs: @autoclosure @escaping () -> Parser) -> Parser {
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
      return (head, tail)
    }
  }

  public func many(allowEmpty: Bool) -> Parser<Input, [Output]> {
    build {
      if allowEmpty {
        many(allowEmpty: false) ?? .pure([])
      } else {
        flatMap { output in
          return many(allowEmpty: true).map { [output] + $0 }
        }
      }
    }
  }
}
