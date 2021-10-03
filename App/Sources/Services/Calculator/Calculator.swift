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
        if let error = error as? ParseError<[CalcToken]> {
          CalcError.parseError(Array(error.unprocessedInput.reversed().suffix(2)))
        } else {
          error
        }
      }
    }
  }
}
