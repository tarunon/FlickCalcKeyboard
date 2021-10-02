//
//  File.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import Core
import Foundation
import Numerics

public enum CalcFormatter {
  public static func format(_ complex: Complex<Double>) -> String {
    let zeroRange = -Double.pow(10, -12)...Double.pow(10, -12)
    let notRoundRange = -Double.pow(10, 12)...Double.pow(10, 12)
    let notRoundFormatter = Decimal.FormatStyle.number
      .precision(
        .significantDigits(0...10)
      )
      .precision(
        .fractionLength(0...10)
      )
      .sign(strategy: .never)
    let roundFormatter = Decimal.FormatStyle.number
      .notation(.scientific)
      .sign(strategy: .never)

    let realPart = build {
      switch complex.real {
      case Double.nan:
        "NaN"
      case zeroRange:
        "0"
      case notRoundRange:
        notRoundFormatter.format(Decimal(complex.real))
      default:
        roundFormatter.format(Decimal(complex.real))
      }
    }

    let imaginalyPart = build {
      switch complex.imaginary {
      case Double.nan:
        "NaN"
      case zeroRange:
        "0"
      case notRoundRange:
        notRoundFormatter.format(Decimal(complex.imaginary))
      default:
        roundFormatter.format(Decimal(complex.imaginary))
      }
    }

    return build {
      switch (realPart, imaginalyPart) {
      case ("NaN", _), (_, "NaN"):
        "NaN"
      case ("0", "0"):
        "0"
      case (_, "0"):
        (complex.real < 0 ? "-" : "") + realPart
      case ("0", "1"):
        (complex.imaginary < 0 ? "-" : "") + "i"
      case ("0", _):
        (complex.imaginary < 0 ? "-" : "") + imaginalyPart + "i"
      case (_, "1"):
        (complex.real < 0 ? "-" : "") + realPart + (complex.imaginary < 0 ? "-" : "+") + "i"
      default:
        (complex.real < 0 ? "-" : "") + realPart + (complex.imaginary < 0 ? "-" : "+")
          + imaginalyPart + "i"
      }
    }
  }

  public static func format<C: Collection>(_ tokens: C) -> String where C.Element == CalcToken {
    tokens.map { $0.rawValue }.joined()
  }
}
