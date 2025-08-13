//
//  ValueExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

extension Result {
    
    /// A result based on whether or not the two cases are `nil`. If `success`
    /// is not nil it is returned, otherwise if `failure` is not nil it is
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
                "Result(_:or:) was called with two nil values. At least one " +
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

extension Array {
    
    public static func build(
        @ArrayBuilder<Self.Element> _ builder: () -> Self
    ) -> Self {
        return builder()
    }
}

@resultBuilder
struct ArrayBuilder<T> : IteratorProtocol {

    typealias Element = T
    private var _state: _State
    
    private init(_ state: _State) {
        self._state = state
    }
    
    public static var empty: ArrayBuilder<T> {
        return self.init(.empty)
    }

    private enum _State {
        case empty
        case single(T)
        case iterator(AnyIterator<T>)
        case range(Int, over: AnyIterator<T>)
        case array([T])
    }

    mutating func next() -> T? {
        switch self._state {
        case .empty:
            return nil
        case .single(let element):
            self._state = .empty
            return element
        case .iterator(var iterator):
            return iterator.next()
        case .range(var count, var iterator):
            if let value = iterator.next() {
                if count <= 0 {
                    preconditionFailure(
                        "Invalid state of iterator given to ArrayBuilder<T>.")
                }
                count -= 1
                return value
            }
            else {
                if count != 0 {
                    preconditionFailure(
                        "Invalid state of iterator given to ArrayBuilder<T>.")
                }
                return nil
            }
        case .array(let array):
            self._state = .iterator(.init(array.makeIterator()))
            return self.next()
        }
    }
    
    func count() -> Array<T>.Index? {
        switch self._state {
        case .empty:
            return 0
        case .single(let element):
            return 1
        case .iterator(let iterator):
            return nil
        case .range(let length, let iterator):
            return length
        case .array(let array):
            return array.count
        }
    }

    static func buildExpression(
        _ expression: T
    ) -> ArrayBuilder<T> {
        return self.init(.single(expression))
    }
    static func buildExpression<I>(
        _ expression: I
    ) -> ArrayBuilder<T> where I : IteratorProtocol<T> {
        return self.init(.iterator(.init(expression)))
    }
    static func buildExpression<I>(
        _ expression: I
    ) -> ArrayBuilder<T> where I : Sequence<T> {
        return self.init(.iterator(.init(expression.makeIterator())))
    }
    static func buildExpression(
        _ expression: @escaping () -> T
    ) -> ArrayBuilder<T> {
        var iterated = false
        return self.init(.iterator(.init {
            if iterated {
                return nil
            }
            else {
                iterated = true
                return expression()
            }
        }))
    }

    static func buildFinalResult(
        _ component: ArrayBuilder<T>
    ) -> [T] {
        switch component._state {
        case .empty:
            return []
        case .single(let value):
            return [value]
        case .iterator(let iterator):
            return Array(iterator)
        case .range(let count, let iterator):
            if let first = iterator.next() {
                if count <= 0 {
                    preconditionFailure(
                        "Invalid state of iterator given to ArrayBuilder<T>.")
                }
                var result = Array(repeating: first, count: count)
                for i in 1..<count {
                    guard let value = iterator.next() else {
                        preconditionFailure(
                            "Invalid state of iterator given to " +
                            "ArrayBuilder<T>.")
                    }
                    result[i] = value
                }
                if iterator.next() != nil {
                    preconditionFailure(
                        "Invalid state of iterator given to ArrayBuilder<T>.")
                }
                return result
            }
            else if count != 0 {
                preconditionFailure(
                    "Invalid state of iterator given to ArrayBuilder<T>.")
            }
            else {
                return []
            }
        case .array(let array):
            return array
        }
    }
    
    static func buildPartialBlock(
        first: ArrayBuilder<T>
    ) -> ArrayBuilder<T> {
        return first
    }
    static func buildPartialBlock(
        accumulated: ArrayBuilder<T>,
        next: ArrayBuilder<T>
    ) -> ArrayBuilder<T> {
        var first: ArrayBuilder<T>? = accumulated
        var second: ArrayBuilder<T> = next
        let count: Array<T>.Index?
        func iterate() -> T? {
            if first == nil {
                return second.next()
            }
            else if let value = first!.next() {
                return value
            }
            else {
                first = nil
                return second.next()
            }
        }
        switch (first?.count(), second.count()) {
        case (let first?, let second?):
            return self.init(.range(first + second, over: .init(iterate)))
        default:
            return self.init(.iterator(.init(iterate)))
        }
    }
    static func buildArray(
        _ components: [ArrayBuilder<T>]
    ) -> ArrayBuilder<T> {
        var iteratorIterator = components.makeIterator()
        var iterator = iteratorIterator.next()
        func iterate() -> T? {
            if iterator == nil {
                return nil
            }
            else if let value = iterator!.next() {
                return value
            }
            else {
                iterator = iteratorIterator.next()
                return iterate()
            }
        }
        if let count = components.reduce(0 as Int?, {
            if
                let previous = $0,
                let next = $1.count() {
                return previous + next
            }
            else {
                return nil
            }
        }) {
            return self.init(.range(count, over: .init(iterate)))
        }
        else {
            return self.init(.iterator(.init(iterate)))
        }
    }
    static func buildOptional(
        _ component: ArrayBuilder<T>?
    ) -> ArrayBuilder<T> {
        if let component = component {
            return component
        }
        else {
            return .empty
        }
    }
    static func buildEither(
        first component: ArrayBuilder<T>
    ) -> ArrayBuilder<T> {
        return component
    }
    static func buildEither(
        second component: ArrayBuilder<T>
    ) -> ArrayBuilder<T> {
        return component
    }
    static func buildLimitedAvailability(
        _ component: ArrayBuilder<T>
    ) -> ArrayBuilder<T> {
        return component
    }
    static func buildBlock(
        _ components: ArrayBuilder<T>...
    ) -> ArrayBuilder<T> {
        return buildArray(components)
    }
}
