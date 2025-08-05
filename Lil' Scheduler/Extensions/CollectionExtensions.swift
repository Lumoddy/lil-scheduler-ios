//
//  CollectionExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 30/7/2025.
//

import Foundation

extension Collection {
    
    public func contains(index: Index) -> Bool {
        return index >= self.startIndex && index < self.endIndex
    }

    public subscript (safe index: Index) -> Element? {
        return contains(index: index) ? self[index] : nil
    }
}

extension RangeReplaceableCollection {
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElement` is then inserted before it.
    public mutating func insert(
        _ newElement: Element,
        before target: Element,
        where equals: (Element, Element) throws -> Bool
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
        before target: Element,
        where equals: (Element, Element) throws -> Bool
    ) rethrows where S : Collection, Element == S.Element {
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
        _ newElement: Element,
        after target: Element,
        where equals: (Element, Element) throws -> Bool
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
        after target: Element,
        where equals: (Element, Element) throws -> Bool
    ) rethrows where S : Collection, Element == S.Element {
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
    
    public mutating func take(at index: Index) -> Element? {
        guard let element = self[safe: index] else {
            return nil
        }
        self.remove(at: index)
        return element
    }
    
    public mutating func take<S>(
        from collection: inout S,
        at index: Index
    ) -> ()? where S : RangeReplaceableCollection,
        S.Element == Element,
        S.Index == Index {
        guard let element = collection.take(at: index) else {
            return nil
        }
        self.append(element)
        return ()
    }
}

extension RangeReplaceableCollection where Index : BinaryInteger {
    
    /// Searches the collection using binary search and inserts `newElement`
    /// after all equal or lower elements.
    public mutating func orderedInsert(
        _ newElement: Element,
        by areInIncreasingOrder: (Element, Element) throws -> Bool
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
        where comparer: (Element) throws -> ComparisonResult
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
        where comparer: (Element) throws -> ComparisonResult
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
        where comparer: (Element) throws -> ComparisonResult
    ) rethrows -> ()? {
        guard let index = try orderedFirstIndex(where: comparer) else {
            return nil
        }
        self.remove(at: index)
        return ()
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
    public mutating func orderedTakeFirst(
        where comparer: (Element) throws -> ComparisonResult
    ) rethrows -> Element? {
        guard let index = try orderedFirstIndex(where: comparer) else {
            return nil
        }
        return self.take(at: index)!
    }
}

extension RangeReplaceableCollection where Element : Equatable {
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElement` is then inserted before it.
    public mutating func insert(
        _ newElement: Element,
        before target: Element
    ) {
        self.insert(newElement, before: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element until an equal element is
    /// found. `newElements` is then inserted before it.
    public mutating func insert<S>(
        contentsOf newElements: S,
        before target: Element
    ) where S : Collection, Self.Element == S.Element {
        self.insert(contentsOf: newElements, before: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElement` after them.
    public mutating func insert(
        _ newElement: Element,
        after target: Element
    ) {
        self.insert(newElement, after: target, where: { $0 == $1 })
    }
    
    /// Searches the collection element by element for a range of elements
    /// that are equal and inserts `newElement` after them.
    public mutating func insert<S>(
        contentsOf newElements: S,
        after target: Element
    ) where S : Collection, Self.Element == S.Element {
        self.insert(contentsOf: newElements, after: target, where: { $0 == $1 })
    }
}

extension RangeReplaceableCollection
    where Element : Comparable,
    Index : BinaryInteger {
    
    /// Searches the collection using binary search and inserts `newElement`
    /// after all equal or lower elements.
    public mutating func orderedInsert(_ newElement: Element) {
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
    
    public func orderedContains(element: Element) -> Bool {
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
