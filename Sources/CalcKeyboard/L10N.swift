//
//  L10N.swift
//
//
//  Created by tarunon on 2021/09/23.
//

import Foundation
import SwiftUI

struct L10N: RawRepresentable {
  var rawValue: String

  var localizedStringKey: LocalizedStringKey {
    .init(rawValue)
  }

  var localizedString: String {
    NSLocalizedString(rawValue, comment: "")
  }

  enum ErrorMessage {
    static let parseError = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.error_message.parse_error"
    )
    static let runtimeError = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.error_message.runtime_error"
    )
  }

  enum VoiceOverNavigate {
    static let flickToUp = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_up"
    )
    static let flickToDown = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_down"
    )
    static let flickToLeft = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_left"
    )
    static let flickToRight = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_right"
    )
  }

  enum VoiceOverTitle {
    static let memoryPlus = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.memory_plus"
    )
    static let memoryMinus = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.memory_minus"
    )
    static let memoryRecall = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.memory_recall"
    )
    static let memoryClear = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.memory_clear"
    )
    static let deleteLeft = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.delete_left"
    )
    static let deleteLeftAll = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.delete_left_all"
    )
    static let deleteRight = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.delete_right"
    )
    static let deleteRightAll = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.delete_right_all"
    )
    static let ans = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.ans")
    static let ret = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.ret")
    static let pref = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.pref")
    static let add = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.add")
    static let sub = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.sub")
    static let mul = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.div")
    static let div = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.mul")
    static let mod = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.mod")
    static let pow = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.pow")
    static let root = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.root")
    static let gamma = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.gamma")
    static let sin = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.sin")
    static let asin = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.asin")
    static let sinh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.sinh")
    static let asinh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.asinh")
    static let cos = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.cos")
    static let acos = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.acos")
    static let cosh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.cosh")
    static let acosh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.acosh")
    static let tan = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.tan")
    static let atan = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.atan")
    static let tanh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.tanh")
    static let atanh = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.atanh")
    static let log = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.log")
    static let ln = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.ln")
    static let lg = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.lg")
    static let pi = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.pi")
    static let napier = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.napier")
    static let imaginaly = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.imaginaly"
    )
    static let bracket = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.bracket")
    static let bracketOpen = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.bracket_open"
    )
    static let bracketClose = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.bracket_close"
    )

    static let moveLeft = L10N(rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.move_left")
    static let moveRight = L10N(
      rawValue: "com.tarunon.flickcalckeyboard.voice_over.title.move_right"
    )
  }
}
