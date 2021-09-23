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
        throw CalcError.parseError(tail.prefix(3).reversed())
      }
      return try head.result()
    } catch (let error) {
      switch error {
      case ParseError.isEmpty:
        throw CalcError.tokensEmpty
      case ParseError.typeMissmatch(_, let actual as CalcToken):
        throw CalcError.parseError([actual])
      case ParseError.conditionFailure(let value as CalcToken):
        throw CalcError.parseError([value])
      default:
        throw error
      }
    }
  }
}
