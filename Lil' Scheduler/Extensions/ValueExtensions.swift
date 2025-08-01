//
//  ValueExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

extension Result {
    
    /// A result based on whether or not the two cases are `nil`. If `success`
    /// is not nil it is returned, otherwise if `failure` is not nil _it_ is
    /// returned. If both are nil, an uncatchable error is thrown.
    public init(_ success: Success?, or failure: Failure?) {
        switch (success, failure) {
        case (let success?, _):
            self = .success(success)
            break
        case (nil, let failure?):
            self = .failure(failure)
            break
        case (nil, nil):
            preconditionFailure(
                "either() was called with two nil values. At least one " +
                "parameter has to be non-nil.")
        }
    }
    
    /// A result based on whether or not the two cases are `nil`. If `success`
    /// is not nil it is returned, otherwise faliure is returned.
    public init(_ success: Success?, or failure: Failure) {
        switch success {
        case let success?:
            self = .success(success)
            break
        case nil:
            self = .failure(failure)
            break
        }
    }
}
