//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

extension Color {
  public static let lightButtonColor: Color = .init(
    uiColor: .init(named: "LightButtonColor", in: Bundles.module, compatibleWith: .current)
      ?? .systemBackground
  )
  public static let darkButtonColor: Color = .init(
    uiColor: .init(named: "DarkButtonColor", in: Bundles.module, compatibleWith: .current)
      ?? .systemGroupedBackground
  )
  public static let backgroundColor: Color = .init(
    uiColor: .init(named: "BackgroundColor", in: Bundles.module, compatibleWith: .current)
      ?? .systemBackground
  )
}
