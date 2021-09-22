//
//  File.swift
//  
//
//  Created by tarunon on 2021/09/22.
//

import Numerics

public enum Calculator {
  public static func calc(tokens: [CalcToken]) throws -> Complex<Double> {
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
}
