//
//  Colors.swift
//
//
//  Created by tarunon on 2021/09/25.
//

import SwiftUI

extension Color {
  public static let lightButtonColor: Color = .init(
    uiColor: .init(named: "LightButtonColor", in: .module, compatibleWith: .current)!
  )
  public static let darkButtonColor: Color = .init(
    uiColor: .init(named: "DarkButtonColor", in: .module, compatibleWith: .current)!
  )
  public static let backgroundColor: Color = .init(
    uiColor: .init(named: "BackgroundColor", in: .module, compatibleWith: .current)!
  )
}
