//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

struct Colors {
  var key: String
  var defaultValue: Color? = nil

  var color: Color {
    Bundles.module.map { Color(key, bundle: $0) } ?? defaultValue ?? .white
  }

  static var lightButtonColor = Colors(key: "LightButtonColor", defaultValue: .white)
  static var darkButtonColor = Colors(
    key: "DarkButtonColor",
    defaultValue: .init(red: 0.710, green: 0.722, blue: 0.761)
  )
  static var backgroundColor = Colors(
    key: "BackgroundColor",
    defaultValue: .init(red: 0.839, green: 0.847, blue: 0.871)
  )
}

// swift-format-ignore
extension Color {
  public static let lightButtonColor = Colors.lightButtonColor.color
  public static let darkButtonColor = Colors.darkButtonColor.color
  public static let backgroundColor = Colors.backgroundColor.color
}
