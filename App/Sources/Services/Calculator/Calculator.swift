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
      return try CalcParsers.calc(tokens.reversed().map { $0.value }).value.result()
    } catch (let error) {
      throw build {
        if let error = error as? ParseError<[CalcTokenProtocol]> {
          CalcError.parseError(error.unprocessedInput.prefix(2).reversed().map(CalcToken.init))
        } else {
          error
        }
      }
    }
  }
}
