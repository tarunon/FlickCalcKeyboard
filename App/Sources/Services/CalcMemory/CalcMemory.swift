//
//  File.swift
//
//
//  Created by tarunon on 2021/09/28.
//

import Calculator
import Numerics

public struct CalcMemory {
  var memory: Complex<Double> = 0
  var answerHistory: [Complex<Double>] = []
  var tokensHistory: [[CalcToken]] = []
  var answerCursor: Int = -1
  var tokensCursor: Int = -1

  public init() {}

  public mutating func resetCursor() {
    answerCursor = -1
    tokensCursor = -1
  }

  public func getMemory() -> CalcToken {
    return .Const.answer(memory)
  }

  public mutating func memoryAdd(_ complex: Complex<Double>) {
    memory += complex
  }

  public mutating func memorySub(_ complex: Complex<Double>) {
    memory -= complex
  }

  public mutating func memoryClear() {
    memory = 0
  }

  public mutating func getAnswer() -> CalcToken {
    if answerHistory.isEmpty {
      return .Const.answer(0)
    }
    if answerCursor < 0 {
      answerCursor = answerHistory.count - 1
    }
    defer {
      answerCursor -= 1
    }
    return .Const.answer(answerHistory[answerCursor])
  }

  public mutating func addAnswer(_ complex: Complex<Double>) {
    answerHistory.append(complex)
  }

  public mutating func getTokens() -> [CalcToken] {
    if tokensHistory.isEmpty {
      return []
    }
    if tokensCursor < 0 {
      tokensCursor = tokensHistory.count - 1
    }
    defer {
      tokensCursor -= 1
    }
    return tokensHistory[tokensCursor]
  }

  public mutating func addTokens(_ tokens: [CalcToken]) {
    if tokens.isEmpty { return }
    tokensHistory.append(tokens)
  }
}
