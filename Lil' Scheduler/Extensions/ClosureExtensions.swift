//
//  ClosureExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import Foundation

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
