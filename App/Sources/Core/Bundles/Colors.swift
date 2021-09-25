//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

extension Color {
  public static var lightButtonColor = Color(
    uiColor: .init(named: "LightButtonColor", in: .main, compatibleWith: .current)!
  )
  public static var darkButtonColor = Color(
    uiColor: .init(named: "DarkButtonColor", in: .main, compatibleWith: .current)!
  )
  public static var backgroundColor = Color(
    uiColor: .init(named: "BackgroundColor", in: .main, compatibleWith: .current)!
  )
}
