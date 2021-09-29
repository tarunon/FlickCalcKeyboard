//
//  File.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import Core
import Numerics
import Parsec

public enum Calculator {
  public static func calc(tokens: [CalcToken]) throws -> Complex<Double> {
    do {
      return try CalcParsers.calc(tokens.reversed()).value.result()
    } catch (let error) {
      throw build {
        switch error {
        case ParseError.isEmpty:
          CalcError.tokensEmpty
        case ParseError.typeMissmatch(_, let actual as CalcToken):
          CalcError.parseError([actual])
        case ParseError.conditionFailure(let value as CalcToken):
          CalcError.parseError([value])
        case ParseError.notComplete(let tokens) where tokens is [CalcToken]:
          CalcError.parseError(tokens as! [CalcToken])
        default:
          error
        }
      }
    }
  }
}
