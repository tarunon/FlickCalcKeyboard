//
//  File.swift
//  
//
//  Created by tarunon on 2021/09/22.
//

import Numerics
import Foundation

public enum CalcFormatter {
  public static func format(_ complex: Complex<Double>) -> String {
    let real = Decimal(complex.real)
      .formatted(
        Decimal.FormatStyle.number
          .precision(
            .significantDigits(0...10)
          )
          .precision(
            .fractionLength(0...10)
          )
      )
    let imaginary = Decimal(complex.imaginary)
      .formatted(
        Decimal.FormatStyle.number
          .precision(
            .significantDigits(0...10)
          )
          .precision(
            .fractionLength(0...10)
          )
          .sign(strategy: .never))
    switch (real, imaginary) {
    case ("NaN", _), (_, "NaN"):
      return "NaN"
    case ("0", "0"), ("-0", "0"):
      return "0"
    case (_, "0"):
      return real
    case ("0", "1"), ("-0", "1"):
      return (complex.imaginary < 0 ? "-" : "") + "i"
    case ("0", _), ("-0", _):
      return (complex.imaginary < 0 ? "-" : "") + imaginary + "i"
    case (_, "1"):
      return real + (complex.imaginary < 0 ? "-" : "+") + "i"
    default:
      return real + (complex.imaginary < 0 ? "-" : "+") + imaginary + "i"
    }
  }

  public static func format<C: Collection>(_ tokens: C) -> String where C.Element == CalcToken {
    tokens.map { $0.rawValue }.joined()
  }
}
