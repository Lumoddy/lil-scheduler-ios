//
//  ClosureExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import Foundation

// Firestore has a janky-arse completion closure and `either()` is ment to
// make it less so.

// Later note: While it's fun to play with closures like this, it is a bad
// practice to use them for something so simple, especially if they escape.
// I've now replaced this with `Result(_:or:)`.

///// Merges two closures into one with two optional parameters, one for each
///// closure. The resulting closure must be called with exactly one parameter
///// nil and the other non-nil, otherwise an uncatchable error is thrown.
//public func either<First, Second, Result>(
//    _ firstClosure: @escaping (First) -> Result,
//    or secondClosure: @escaping (Second) -> Result
//) -> (First?, Second?) -> Result {
//    return { firstValue, secondValue in
//        switch (firstValue, secondValue) {
//        case (let firstValue?, nil):
//            return firstClosure(firstValue)
//        case (nil, let secondValue?):
//            return secondClosure(secondValue)
//        case (nil, nil):
//            preconditionFailure(
//                "either() was called with two nil values. Exactly one " +
//                "parameter has to be non-nil.")
//        case (_?, _?):
//            preconditionFailure(
//                "either() was called with two non-nil values. Exactly one " +
//                "parameter has to be nil.")
//        }
//    }
//}
//
///// Merges two closures into one with two optional parameters, one for each
///// closure. The resulting closure must be called with exactly one parameter
///// nil and the other non-nil, otherwise an uncatchable error is thrown.
//public func either<First, Second, Result, Failure>(
//    _ firstClosure: @escaping (First) throws(Failure) -> Result,
//    or secondClosure: @escaping (Second) throws(Failure) -> Result
//) -> (First?, Second?) throws(Failure) -> Result {
//    return { firstValue, secondValue in
//        switch (firstValue, secondValue) {
//        case (let firstValue?, nil):
//            return try firstClosure(firstValue)
//        case (nil, let secondValue?):
//            return try secondClosure(secondValue)
//        case (nil, nil):
//            preconditionFailure(
//                "either() was called with two nil values. Exactly one " +
//                "parameter has to be non-nil.")
//        case (_?, _?):
//            preconditionFailure(
//                "either() was called with two non-nil values. Exactly one " +
//                "parameter has to be nil.")
//        }
//    }
//}
//
///// Merges two closures into one with two optional parameters, one for each
///// closure. The resulting closure must be called with exactly one parameter
///// nil and the other non-nil, otherwise `else` is called.
//public func either<First, Second, Result>(
//    _ firstClosure: @escaping (First) -> Result,
//    or secondClosure: @escaping (Second) -> Result,
//    else fallbackClosure: @escaping () -> Result
//) -> (First?, Second?) -> Result {
//    return { firstValue, secondValue in
//        switch (firstValue, secondValue) {
//        case (let firstValue?, nil):
//            return firstClosure(firstValue)
//        case (nil, let secondValue?):
//            return secondClosure(secondValue)
//        default:
//            return fallbackClosure()
//        }
//    }
//}
//
///// Merges two closures into one with two optional parameters, one for each
///// closure. The resulting closure must be called with exactly one parameter
///// nil and the other non-nil, otherwise `else` is called.
//public func either<First, Second, Result, Failure>(
//    _ firstClosure: @escaping (First) throws(Failure) -> Result,
//    or secondClosure: @escaping (Second) throws(Failure) -> Result,
//    else fallbackClosure: @escaping () throws(Failure) -> Result
//) -> (First?, Second?) throws(Failure) -> Result {
//    return { firstValue, secondValue in
//        switch (firstValue, secondValue) {
//        case (let firstValue?, nil):
//            return try firstClosure(firstValue)
//        case (nil, let secondValue?):
//            return try secondClosure(secondValue)
//        default:
//            return try fallbackClosure()
//        }
//    }
//}
//
///// Merges two closures into one with an optional parameter, one for each
///// case.
//public func either<Value, Result>(
//    _ firstClosure: @escaping (Value) -> Result,
//    or secondClosure: @escaping () -> Result
//) -> (Value?) -> Result {
//    return { value in
//        if let value = value {
//            return firstClosure(value)
//        }
//        else {
//            return secondClosure()
//        }
//    }
//}
//
///// Merges two closures into one with an optional parameter, one for each
///// case.
//public func either<Value, Result, Failure>(
//    _ firstClosure: @escaping (Value) throws(Failure) -> Result,
//    or secondClosure: @escaping () throws(Failure) -> Result
//) -> (Value?) throws(Failure) -> Result {
//    return { value in
//        if let value = value {
//            return try firstClosure(value)
//        }
//        else {
//            return try secondClosure()
//        }
//    }
//}

/// Calls the closure '`then`' when the async closure returns a value.
@discardableResult
public func when<Result>(
    _ task: sending @escaping @isolated(any) () async -> Result,
    then completion: sending @escaping (Result) -> ()
) -> Task<(), Never> {
    return Task { completion(await task()) }
}

/// Calls the closure '`then`' when the async closure returns a value.
@discardableResult
public func when<Result>(
    _ task: sending @escaping @isolated(any) () async throws -> Result,
    then completion: sending @escaping (Result) throws -> ()
) -> Task<(), any Error> {
    return Task { try completion(try await task()) }
}

/// Calls the closure '`then`' when the async closure returns a value.
/// Otherwise if the closure throws, '`catch`' is called instead.
@discardableResult
public func when<Result>(
    _ task: sending @escaping @isolated(any) () async throws -> Result,
    then completion: sending @escaping (Result) -> (),
    catch fallback: sending @escaping (any Error) -> ()
) -> Task<(), Never> {
    return Task {
        let result: Result
        do {
            result = try await task()
        }
        catch {
            fallback(error)
            return
        }
        completion(result)
    }
}

/// Calls the closure '`then`' when the async closure returns a value.
/// Otherwise if the closure throws, '`catch`' is called instead.
@discardableResult
public func when<Result>(
    _ task: sending @escaping @isolated(any) () async throws -> Result,
    then completion: sending @escaping (Result) throws -> (),
    catch fallback: sending @escaping (any Error) throws -> ()
) -> Task<(), any Error> {
    return Task {
        let result: Result
        do {
            result = try await task()
        }
        catch {
            try fallback(error)
            return
        }
        try completion(result)
    }
}
