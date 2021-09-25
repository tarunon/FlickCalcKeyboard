//
//  File.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import Builder
import Numerics
import Parsec

public enum Calculator {
  public static func calc(tokens: [CalcToken]) throws -> Complex<Double> {
    do {
      let (head, tail) = try CalcParsers.calc(tokens.reversed())
      guard tail.isEmpty else {
        throw CalcError.parseError(tail.prefix(3).reversed())
      }
      return try head.result()
    } catch (let error) {
      throw build {
        switch error {
        case ParseError.isEmpty:
          CalcError.tokensEmpty
        case ParseError.typeMissmatch(_, let actual as CalcToken):
          CalcError.parseError([actual])
        case ParseError.conditionFailure(let value as CalcToken):
          CalcError.parseError([value])
        default:
          error
        }
      }
    }
  }
}
