//
//  CollectionExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 30/7/2025.
//

import Foundation

extension Collection {
    
    public func contains(index: Self.Index) -> Bool {
        return self.indices.contains(index)
    }

    public subscript (safe index: Self.Index) -> Self.Element? {
        return self.contains(index: index) ? self[index] : nil
    }
}

extension RangeReplaceableCollection {
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElement` is then inserted before it.
    public mutating func insert(
        _ newElement: Self.Element,
        before target: Self.Element,
        where equals: (Self.Element, Self.Element) throws -> Bool
    ) rethrows {
        for (index, element) in zip(self.indices, self) {
            if try equals(element, target) {
                self.insert(newElement, at: index)
                return
            }
        }
        self.append(newElement)
    }
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElements` is then inserted before it.
    public mutating func insert<S>(
        contentsOf newElements: S,
        before target: Self.Element,
        where equals: (Self.Element, Self.Element) throws -> Bool
    ) rethrows where S : Collection, Self.Element == S.Element {
        for (index, element) in zip(self.indices, self) {
            if try equals(element, target) {
                self.insert(contentsOf: newElements, at: index)
                return
            }
        }
        self.append(contentsOf: newElements)
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElement` after them.
    public mutating func insert(
        _ newElement: Self.Element,
        after target: Self.Element,
        where equals: (Self.Element, Self.Element) throws -> Bool
    ) rethrows {
        var found = false
        for (index, element) in zip(self.indices, self) {
            if try equals(element, target) {
                found = true
            }
            else if found {
                self.insert(newElement, at: index)
                return
            }
        }
        self.append(newElement)
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElements` after them.
    public mutating func insert<S>(
        contentsOf newElements: S,
        after target: Self.Element,
        where equals: (Self.Element, Self.Element) throws -> Bool
    ) rethrows where S : Collection, Self.Element == S.Element {
        var found = false
        for (index, element) in zip(self.indices, self) {
            if try equals(element, target) {
                found = true
            }
            else if found {
                self.insert(contentsOf: newElements, at: index)
                return
            }
        }
        self.append(contentsOf: newElements)
    }
    
    @discardableResult
    public mutating func removeFirst(
        where shouldBeRemoved: (Self.Element) throws -> Bool
    ) rethrows -> Self.Element? {
        guard let index = try self.firstIndex(where: shouldBeRemoved) else {
            return nil
        }
        return self.remove(at: index)
    }
    
    @discardableResult
    public mutating func remove(safelyAt index: Self.Index) -> Self.Element? {
        if self.contains(index: index) {
            return self.remove(at: index)
        }
        else {
            return nil
        }
    }
}

extension RangeReplaceableCollection where Self.Index : BinaryInteger {
    
    /// Searches the collection using binary search and inserts `newElement`
    /// after all equal or lower elements.
    public mutating func orderedInsert(
        _ newElement: Self.Element,
        by areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool
    ) rethrows {
        var start = self.startIndex
        var end = self.endIndex
        while true {
            switch start {
            case end - 1 where try areInIncreasingOrder(newElement, self[start]):
                return self.insert(newElement, at: start)
            case end - 1:
                return self.insert(newElement, at: end)
            case end:
                return self.insert(newElement, at: end)
            case end...:
                preconditionFailure(
                    "orderedInsert() encountered an invalid state. " +
                    "Check the comparison function to make sure it's " +
                    "consistent.")
            default:
                let middle = (start + end - 1) / 2
                if try areInIncreasingOrder(newElement, self[start]) {
                    start = middle + 1
                }
                else {
                    end = middle
                }
                continue
            }
        }
    }
    
    /// Uses binary search to find an element that fits a condition and
    /// returns its index. The `comparer` must return `.orderedSame` if the
    /// element is what your looking for, otherwise `.orderedAscending` if it
    /// would be sorted before and `.orderedDecending` if after.
    ///
    /// An example of an implementation would be the below:
    ///
    ///     let targetValue: Int = 37
    ///     collection.orderedFirstIndex(
    ///         whereElementIs: { element in
    ///             if element == targetValue {
    ///                 return .orderedSame
    ///             }
    ///             else if element < targetValue {
    ///                 return .orderedAscending
    ///             }
    ///             else {
    ///                 return .orderedDescending
    ///             }
    ///         })
    ///
    public func orderedFirstIndex(
        where comparer: (Self.Element) throws -> ComparisonResult
    ) rethrows -> Self.Index? {
        var start = self.startIndex
        var end = self.endIndex
        while true {
            switch start {
            case end - 1 where try comparer(self[start]) == .orderedSame:
                return start
            case end - 1:
                return nil
            case end:
                return nil
            case end...:
                preconditionFailure(
                    "orderedFirstIndex() encountered an invalid state. " +
                    "Check the comparison function to make sure it's " +
                    "consistent.")
            default:
                let middle = (start + end - 1) / 2
                switch try comparer(self[middle]) {
                case .orderedSame, .orderedAscending:
                    end = middle
                    continue
                case .orderedDescending:
                    start = middle + 1
                    continue
                }
            }
        }
    }
    
    /// Uses binary search to see if the array contains an element that fits a
    /// condition. The `comparer` must return `.orderedSame` if the element
    /// is what your looking for, otherwise `.orderedAscending` if it would be
    /// sorted before and `.orderedDecending` if after.
    ///
    /// An example of an implementation would be the below:
    ///
    ///     let targetValue: Int = 37
    ///     collection.orderedContains(
    ///         whereElementIs: { element in
    ///             if element == targetValue {
    ///                 return .orderedSame
    ///             }
    ///             else if element < targetValue {
    ///                 return .orderedAscending
    ///             }
    ///             else {
    ///                 return .orderedDescending
    ///             }
    ///         })
    ///
    public func orderedContains(
        where comparer: (Self.Element) throws -> ComparisonResult
    ) rethrows -> Bool {
        var start = self.startIndex
        var end = self.endIndex
        while true {
            switch start {
            case end - 1:
                return try comparer(self[start]) == .orderedSame
            case end:
                return false
            case end...:
                preconditionFailure(
                    "orderedContains() encountered an invalid state. Check " +
                    "the comparison function to make sure it's " +
                    "consistent.")
            default:
                let middle = (start + end - 1) / 2
                switch try comparer(self[middle]) {
                case .orderedSame:
                    return true
                case .orderedAscending:
                    end = middle
                    continue
                case .orderedDescending:
                    start = middle + 1
                    continue
                }
            }
        }
    }
    
    /// Uses binary search to find an element that fits a condition and
    /// returns its index. The `comparer` must return `.orderedSame` if the
    /// element is what your looking for, otherwise `.orderedAscending` if it
    /// would be sorted before and `.orderedDecending` if after.
    ///
    /// An example of an implementation would be the below:
    ///
    ///     let targetValue: Int = 37
    ///     collection.orderedRemoveFirst(
    ///         whereElementIs: { element in
    ///             if element == targetValue {
    ///                 return .orderedSame
    ///             }
    ///             else if element < targetValue {
    ///                 return .orderedAscending
    ///             }
    ///             else {
    ///                 return .orderedDescending
    ///             }
    ///         })
    ///
    public mutating func orderedRemoveFirst(
        where comparer: (Self.Element) throws -> ComparisonResult
    ) rethrows -> Self.Element? {
        guard let index = try orderedFirstIndex(where: comparer) else {
            return nil
        }
        return self.remove(at: index)
    }
}

extension RangeReplaceableCollection where Self.Element : Equatable {
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElement` is then inserted before it.
    public mutating func insert(
        _ newElement: Self.Element,
        before target: Self.Element
    ) {
        self.insert(newElement, before: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElements` is then inserted before it.
    public mutating func insert<S>(
        contentsOf newElements: S,
        before target: Self.Element
    ) where S : Collection, Self.Element == S.Element {
        self.insert(contentsOf: newElements, before: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElement` after them.
    public mutating func insert(
        _ newElement: Self.Element,
        after target: Self.Element
    ) {
        self.insert(newElement, after: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElement` after them.
    public mutating func insert<S>(
        contentsOf newElements: S,
        after target: Self.Element
    ) where S : Collection, Self.Element == S.Element {
        self.insert(contentsOf: newElements, after: target, where: { $0 == $1 })
    }
}

extension RangeReplaceableCollection
    where Self.Element : Comparable,
        Self.Index : BinaryInteger {
    
    /// Searches the collection using binary search and inserts `newElement`
    /// after all equal or lower elements.
    public mutating func orderedInsert(_ newElement: Self.Element) {
        self.orderedInsert(newElement, by: { $0 < $1 })
    }
    
    public func orderedFirstIndex(
        of element: Self.Element
    ) -> Self.Index? {
        return orderedFirstIndex(where: {
            if $0 == element {
                return .orderedSame
            }
            else if $0 < element {
                return .orderedAscending
            }
            else {
                return .orderedDescending
            }
        })
    }
    
    public func orderedContains(element: Self.Element) -> Bool {
        return orderedContains(where: {
            if $0 == element {
                return .orderedSame
            }
            else if $0 < element {
                return .orderedAscending
            }
            else {
                return .orderedDescending
            }
        })
    }
}
