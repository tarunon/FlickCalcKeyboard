//
//  File.swift
//
//
//  Created by tarunon on 2021/09/21.
//

public enum CalcAction {
  case insertText(String)
  case deleteLeft(line: Bool)
  case deleteRight(line: Bool)
  case moveCursor(offset: Int)
  case exit
}
