//
//  SnapshotTests.swift
//
//
//  Created by tarunon on 2021/10/02.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import CalcEditorView
@testable import CalcKeyboard
@testable import FlickButton
@testable import InputField

class SnapshotTests: XCTestCase {
  func snapshotTest<V: View>(_ view: V, function: String = #function, line: UInt = #line) {
    for colorScheme in [ColorScheme.light, .dark] {
      assertSnapshot(
        matching:
          view
          .environment(\.colorScheme, colorScheme),
        as: .image,
        named: "[color: \(colorScheme)]",
        file: #file,
        testName: function,
        line: line
      )
    }
  }

  func testCalcEditorView() {
    snapshotTest(CalcEditorView_Preview.previews.frame(width: 320.0, height: 320.0))
  }

  func testCalcTextView() {
    snapshotTest(CalcTextView_Preview.previews.frame(width: 320.0, height: 320.0))
  }

  func testCalcKeyboardView() {
    snapshotTest(CalcKeyboardView_Preview.previews.frame(width: 320.0, height: 256.0))
  }

  func testFlickButtonView() {
    snapshotTest(FlickButton_Preview.previews)
  }

  func testFlickChip() {
    snapshotTest(FlickChip_Preview.previews)
  }

  func testInputField() {
    snapshotTest(InputField_Preview.previews.frame(width: 320.0, height: 30.0))
  }

  func testTextMarker() {
    snapshotTest(TextMarker_Preview.previews)
  }
}
