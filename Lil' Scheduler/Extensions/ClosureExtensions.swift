//
//  ClosureExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import Foundation

// Firestore has a janky-arse completion closure and `either()` is ment to
// make it less so.

/// Combines two closures that each take a single value into one with two
/// optional parameters. One of parameters has to be not `nil` and the other
/// has be `nil`.
public func either<First, Second, Result>(
    _ firstFunction: @escaping (First) throws -> Result,
    or secondFunction: @escaping (Second) throws -> Result
) -> (First?, Second?) throws -> Result {
    return { first, second in
        if let firstValue = first {
            if second == nil {
                return try firstFunction(firstValue)
            }
            else {
                throw NSError(
                    domain: "FunctionError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Invalid closure merge call."
                    ])
            }
        }
        else if let secondValue = second {
            return try secondFunction(secondValue)
        }
        else {
            throw NSError(
                domain: "FunctionError",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid closure merge call."
                ])
        }
    }
}

/// Combines two returning closures that each take a single value into one with
/// two optional parameters. One of parameters has to be not `nil` and the
/// other has be `nil`.
public func either<First, Second, Result>(
    _ firstFunction: @escaping (First) throws -> Result,
    or secondFunction: @escaping (Second) throws -> Result,
    else fallback: Result
) -> (First?, Second?) -> Result {
    return { first, second in
        do {
            if let firstValue = first {
                if second == nil {
                    return try firstFunction(firstValue)
                }
                else {
                    return fallback
                }
            }
            else if let secondValue = second {
                return try secondFunction(secondValue)
            }
            else {
                return fallback
            }
        }
        catch {
            return fallback
        }
    }
}

/// Combines two returning closures that each take a single value into one with
/// two optional parameters. One of parameters has to be not `nil` and the
/// other has be `nil`.
///
/// This exists to allow the special trailing closure syntax.
public func either<First, Second, Result>(
    fallback: Result,
    _ firstFunction: @escaping (First) throws -> Result,
    or secondFunction: @escaping (Second) throws -> Result
) -> (First?, Second?) -> Result {
    return either(firstFunction, or: secondFunction, else: fallback)
}

/// Combines two closures that each take a single value into one with two
/// optional parameters. One of parameters has to be not `nil` and the other
/// has be `nil`.
///
/// **Warning**: The returned closure does not throw if incorrect paramters were
/// passed
public func either<First, Second>(
    _ firstFunction: @escaping (First) -> (),
    or secondFunction: @escaping (Second) -> ()
) -> (First?, Second?) -> () {
    return { first, second in
        if let firstValue = first {
            if second == nil {
                firstFunction(firstValue)
            }
            else {
                print(NSError(
                    domain: "FunctionError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Invalid closure merge call."
                    ]))
            }
        } else if let secondValue = second {
            secondFunction(secondValue)
        } else {
            print(NSError(
                domain: "FunctionError",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid closure merge call."
                ]))
        }
    }
}

/// Calls the closure '`then`' when the async closure returns a value.
@discardableResult
public func when<Result>(
    _ task: @escaping () async throws -> Result,
    then completion: @escaping (Result) throws -> ()
) -> Task<(), any Error> {
    return Task {
        let result = try await task();
        try completion(result);
    }
}

/// Calls the closure '`then`' when the async closure returns a value.
/// Otherwise if the closure throws, '`catch`' is called instead.
@discardableResult
public func when<Result>(
    _ task: @escaping () async throws -> Result,
    then completion: @escaping (Result) throws -> (),
    catch fallback: @escaping (any Error) throws -> ()
) -> Task<(), any Error> {
    return Task {
        let result: Result;
        do {
            result = try await task();
        }
        catch {
            try fallback(error)
            return
        }
        try completion(result);
    }
}
