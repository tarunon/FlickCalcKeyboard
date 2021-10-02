//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

enum Colors: String {
  case lightButtonColor = "LightButtonColor"
  case darkButtonColor = "DarkButtonColor"
  case backgroundColor = "BackgroundColor"

  var color: Color {
    .init(rawValue, bundle: Bundles.module)
  }
}

extension Color {
  public static let lightButtonColor = Colors.lightButtonColor.color
  public static let darkButtonColor = Colors.darkButtonColor.color
  public static let backgroundColor = Colors.backgroundColor.color
}
