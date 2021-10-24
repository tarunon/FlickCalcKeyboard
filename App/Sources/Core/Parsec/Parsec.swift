//
//  File.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import Core

public struct ParseError<Input: RangeReplaceableCollection & Sendable>: Error
where Input.Element: Sendable {
  public enum Detail: Error {
    case isEmpty
    case typeMissmatch(expect: Sendable.Type, actual: Sendable)
    case conditionFailure(value: Sendable)
    case notComplete
    case userDefinedError(error: Error)
  }
  public var detail: Detail
  public var unprocessedInput: Input
}

extension ParseError {
  init(error: Error, unprocessedInput: Input) {
    switch error {
    case let error as ParseError<Input>:
      self = error
    case let error as ParseError<Input>.Detail:
      self = .init(detail: error, unprocessedInput: unprocessedInput)
    default:
      self = .init(detail: .userDefinedError(error: error), unprocessedInput: unprocessedInput)
    }
  }
}

public struct ParseResult<Input: RangeReplaceableCollection & Sendable, Output: Sendable>
where Input.Element: Sendable {
  var output: Output
  var input: Input

  // swift-format-ignore
  public var value: Output {
    get throws {
      guard input.isEmpty else {
        throw ParseError(detail: .notComplete, unprocessedInput: input)
      }
      return output
    }
  }
}

public struct Parser<Input: RangeReplaceableCollection & Sendable, Output: Sendable>: Sendable
where Input.Element: Sendable {
  public typealias Result = ParseResult<Input, Output>
  var parse: @Sendable (Input) throws -> Result

  public init(parse: @escaping @Sendable (Input) throws -> Result) {
    self.parse = parse
  }

  public func callAsFunction(_ input: Input) throws -> Result {
    do {
      return try parse(input)
    } catch (let error) {
      throw ParseError<Input>(error: error, unprocessedInput: input)
    }
  }
}

extension ParseResult: Equatable where Input: Equatable, Output: Equatable {

}

extension Parser {
  public static func pure(_ value: Output) -> Parser {
    return .init(parse: { .init(output: value, input: $0) })
  }

  public static func empty() -> Parser {
    return .init(parse: { _ in throw ParseError<Input>(detail: .isEmpty, unprocessedInput: .init())
    })
  }

  public func map<T>(_ f: @Sendable @escaping (Output) throws -> T) -> Parser<Input, T> {
    flatMap { try Parser<Input, T>.pure(f($0)) }
  }

  public func flatMap<T>(_ f: @Sendable @escaping (Output) throws -> Parser<Input, T>) -> Parser<
    Input, T
  > {
    return Parser<Input, T> { input throws in
      do {
        let result = try self.parse(input)
        return try f(result.output).parse(result.input)
      } catch (let error) {
        throw ParseError<Input>(error: error, unprocessedInput: input)
      }
    }
  }

  public func mapError(_ f: @Sendable @escaping (Error) -> Error) -> Parser {
    flatMapError { throw f($0) }
  }

  public func flatMapError(_ f: @Sendable @escaping (Error) throws -> Parser) -> Parser {
    .init(parse: { input throws in
      do {
        return try self.parse(input)
      } catch (let lError) {
        do {
          return try f(lError).parse(input)
        } catch (let rError) {
          let lError = ParseError<Input>(error: lError, unprocessedInput: input)
          let rError = ParseError<Input>(error: rError, unprocessedInput: input)
          if lError.unprocessedInput.count < rError.unprocessedInput.count {
            throw lError
          } else {
            throw rError
          }
        }
      }
    })
  }

  public func assert(_ condition: @Sendable @escaping (Output) -> Bool) -> Parser {
    self.map {
      guard condition($0) else {
        throw ParseError<Input>.Detail.conditionFailure(value: $0)
      }
      return $0
    }
  }

  public static func || (lhs: Parser, rhs: @Sendable @autoclosure @escaping () -> Parser) -> Parser
  {
    return lhs.flatMapError { _ in rhs() }
  }

  public static func satisfy(to type: Output.Type = Output.self) -> Parser {
    return Parser { input throws in
      if input.isEmpty {
        throw ParseError<Input>(detail: .isEmpty, unprocessedInput: .init())
      }
      var tail = input
      let head = tail.removeFirst()
      guard let head = head as? Output else {
        throw ParseError<Input>.Detail.typeMissmatch(expect: Output.self, actual: head)
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
  public static func satisfy(_ isSatisfy: @Sendable @escaping (Input.Element) -> Bool) -> Parser {
    return Parser { input throws in
      if input.isEmpty {
        throw ParseError<Input>(detail: .isEmpty, unprocessedInput: .init())
      }
      var tail = input
      let head = tail.removeFirst()
      guard isSatisfy(head) else {
        throw ParseError<Input>.Detail.conditionFailure(value: head)
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
