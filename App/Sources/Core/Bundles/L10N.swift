//
//  L10N.swift
//
//
//  Created by tarunon on 2021/09/23.
//

import Foundation
import SwiftUI

public struct L10N {
  var key: String
  var defaultValue = ""

  public var text: Text {
    Bundles.module.map { Text(.init(key), bundle: $0) } ?? Text(defaultValue)
  }

  public var localizedString: String {
    NSLocalizedString(
      key,
      tableName: nil,
      bundle: Bundles.module ?? .main,
      value: defaultValue,
      comment: ""
    )
  }

  public enum ErrorMessage {
    public static let parseError = L10N(
      key: "com.tarunon.flickcalckeyboard.error_message.parse_error",
      defaultValue: "Parse error occured"
    )
    public static let runtimeError = L10N(
      key: "com.tarunon.flickcalckeyboard.error_message.runtime_error",
      defaultValue: "Failure by unsupported operation"
    )
  }

  public enum Placeholder {
    public static let memoryAdd = L10N(
      key: "com.tarunon.flickcalckeyboard.placeholder.memory_add",
      defaultValue: "Added to memory"
    )
    public static let memorySub = L10N(
      key: "com.tarunon.flickcalckeyboard.placeholder.memory_sub",
      defaultValue: "Subtracted from memory"
    )
    public static let memoryClear = L10N(
      key: "com.tarunon.flickcalckeyboard.placeholder.memory_clear",
      defaultValue: "Removed memory"
    )
  }

  public enum VoiceOverNavigate {
    public static let flickToUp = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_up"
    )
    public static let flickToDown = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_down"
    )
    public static let flickToLeft = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_left"
    )
    public static let flickToRight = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_right"
    )
  }

  public enum VoiceOverTitle {
    public static let memoryPlus = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.memory_plus"
    )
    public static let memoryMinus = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.memory_minus"
    )
    public static let memoryRecall = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.memory_recall"
    )
    public static let memoryClear = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.memory_clear"
    )
    public static let deleteLeft = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.delete_left"
    )
    public static let deleteLeftAll = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.delete_left_all"
    )
    public static let deleteRight = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.delete_right"
    )
    public static let deleteRightAll = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.delete_right_all"
    )
    public static let ans = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.ans")
    public static let ret = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.ret")
    public static let pref = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.pref")
    public static let add = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.add")
    public static let sub = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.sub")
    public static let mul = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.div")
    public static let div = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.mul")
    public static let mod = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.mod")
    public static let pow = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.pow")
    public static let root = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.root")
    public static let gamma = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.gamma")
    public static let sin = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.sin")
    public static let asin = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.asin")
    public static let sinh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.sinh")
    public static let asinh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.asinh")
    public static let cos = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.cos")
    public static let acos = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.acos")
    public static let cosh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.cosh")
    public static let acosh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.acosh")
    public static let tan = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.tan")
    public static let atan = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.atan")
    public static let tanh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.tanh")
    public static let atanh = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.atanh")
    public static let log = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.log")
    public static let ln = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.ln")
    public static let lg = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.lg")
    public static let pi = L10N(key: "com.tarunon.flickcalckeyboard.voice_over.title.pi")
    public static let napier = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.napier"
    )
    public static let imaginaly = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.imaginaly"
    )
    public static let bracket = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.bracket"
    )
    public static let bracketOpen = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.bracket_open"
    )
    public static let bracketClose = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.bracket_close"
    )

    public static let moveLeft = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.move_left"
    )
    public static let moveRight = L10N(
      key: "com.tarunon.flickcalckeyboard.voice_over.title.move_right"
    )
  }
}
