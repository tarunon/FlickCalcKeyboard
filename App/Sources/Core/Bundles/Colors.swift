//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

extension Color {
  public static let lightButtonColor: Color = .init(
    uiColor: .init(named: "LightButtonColor", in: .main, compatibleWith: .current)
      ?? .systemBackground
  )
  public static let darkButtonColor: Color = .init(
    uiColor: .init(named: "DarkButtonColor", in: .main, compatibleWith: .current)
      ?? .systemGroupedBackground
  )
  public static let backgroundColor: Color = .init(
    uiColor: .init(named: "BackgroundColor", in: .main, compatibleWith: .current)
      ?? .systemBackground
  )
}
