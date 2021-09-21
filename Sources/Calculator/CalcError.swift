//
//  CalcError.swift
//
//
//  Created by tarunon on 2021/09/20.
//

public enum CalcError: Error {
  case tokensEmpty
  case parseError(reason: String)
  case runtimeError(reason: String)
}
