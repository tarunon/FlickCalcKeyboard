//
//  Utilities.swift
//
//
//  Created by tarunon on 2021/09/25.
//

@_exported import Builder

public func setup<T: AnyObject>(
  from initialize: @autoclosure @escaping () -> T,
  _ mutation: (T) -> Void
) -> T {
  let instance = initialize()
  mutation(instance)
  return instance
}

@_disfavoredOverload
public func setup<T>(_ initialize: @autoclosure @escaping () -> T, _ mutation: (inout T) -> Void)
  -> T
{
  var instance = initialize()
  mutation(&instance)
  return instance
}
