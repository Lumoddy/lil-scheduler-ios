//
//  CollectionExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 30/7/2025.
//

extension Collection {
    
    public func contains(index: Self.Index) -> Bool {
        return index >= self.startIndex && index < self.endIndex
    }

    public subscript (safe index: Self.Index) -> Self.Element? {
        return contains(index: index) ? self[index] : nil
    }
}
