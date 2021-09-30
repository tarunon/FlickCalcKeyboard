//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

extension Color {
  public static let lightButtonColor: Color = .init(
    uiColor: .init(named: "LightButtonColor", in: .moduleOrMain, compatibleWith: .current)
      ?? .systemBackground
  )
  public static let darkButtonColor: Color = .init(
    uiColor: .init(named: "DarkButtonColor", in: .moduleOrMain, compatibleWith: .current)
      ?? .systemGroupedBackground
  )
  public static let backgroundColor: Color = .init(
    uiColor: .init(named: "BackgroundColor", in: .moduleOrMain, compatibleWith: .current)
      ?? .systemBackground
  )
}
