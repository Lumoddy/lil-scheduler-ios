//
//  ClosureExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import Foundation

public func either<TLhs, TRhs, TReturn>(
    _ lhFunction: @escaping (TLhs) throws -> TReturn,
    or rhFunction: @escaping (TRhs) throws -> TReturn
) -> (TLhs?, TRhs?) throws -> TReturn {
    return { lhs, rhs in
        if let lhValue = lhs {
            if rhs == nil {
                throw NSError(
                    domain: "FunctionError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Invalid closure merge call."
                    ])
            }
            return try lhFunction(lhValue)
        } else if let rhValue = rhs {
            return try rhFunction(rhValue)
        } else {
            throw NSError(
                domain: "FunctionError",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid closure merge call."
                ])
        }
    }
}

public func either<TLhs, TRhs, TReturn>(
    _ lhFunction: @escaping (TLhs) throws -> TReturn,
    or rhFunction: @escaping (TRhs) throws -> TReturn,
    else fallback: TReturn
) -> (TLhs?, TRhs?) -> TReturn {
    return { lhs, rhs in
        do {
            if let lhValue = lhs {
                if rhs == nil {
                    return fallback
                }
                return try lhFunction(lhValue)
            } else if let rhValue = rhs {
                return try rhFunction(rhValue)
            } else {
                return fallback
            }
        } catch {
            return fallback
        }
    }
}

public func either<TLhs, TRhs, TReturn>(
    fallback: TReturn,
    _ lhFunction: @escaping (TLhs) throws -> TReturn,
    or rhFunction: @escaping (TRhs) throws -> TReturn
) -> (TLhs?, TRhs?) -> TReturn {
    return either(lhFunction, or: rhFunction, else: fallback)
}

public func either<TLhs, TRhs>(
    _ lhFunction: @escaping (TLhs) -> (),
    or rhFunction: @escaping (TRhs) -> ()
) -> (TLhs?, TRhs?) -> () {
    return { lhs, rhs in
        if let lhValue = lhs {
            if rhs == nil { return }
            lhFunction(lhValue)
        } else if let rhValue = rhs {
            rhFunction(rhValue)
        }
    }
}
