//
//  TaskAttributeDescription.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import Foundation

public enum TaskAttributeDescription : Codable, CustomStringConvertible {
        
    private enum _Type {
        
        case duration
        case fixedDate
        case priority
        
        public var stringValue: String {
            switch self {
            case .duration: "duration"
            case .fixedDate: "fixed-date"
            case .priority: "priority"
            }
        }
    }
    
    private enum _Key : CodingKey {
        
        case type
        case durationMilliseconds
        case fixedDateAt
        case priorityIndex
        
        public var stringValue: String {
            switch self {
            case .type: "type"
            case .durationMilliseconds: "duration"
            case .fixedDateAt: "fixed-date"
            case .priorityIndex: "priority"
            }
        }
        
        public init?(stringValue: String) {
            switch stringValue {
            case "type":
                self = .type
                return
            case "duration":
                self = .durationMilliseconds
                return
            case "fixed-date":
                self = .fixedDateAt
                return
            case "priority":
                self = .priorityIndex
                return
            default:
                return nil
            }
        }
        
        public init?(intValue: Int) { nil }
    }

    case duration(milliseconds: Int64)
    case fixedDate(at: Date)
    case priority(index: Int)
    
    public init(from decoder: any Decoder) throws {

        let container = try decoder.container(keyedBy: _Key.self)

        switch try container.decode(String.self, forKey: _Key.type) {
        case _Type.duration.stringValue:
            self = .duration(
                milliseconds: try container.decode(
                    Int64.self,
                    forKey: _Key.durationMilliseconds))
            return
        case _Type.fixedDate.stringValue:
            self = .fixedDate(
                at: try container.decode(
                    Date.self,
                    forKey: _Key.fixedDateAt))
            return
        case _Type.priority.stringValue:
            self = .priority(
                index: try container.decode(
                    Int.self,
                    forKey: _Key.priorityIndex))
            return
        default:
            throw DecodingError.typeMismatch(
                TaskAttributeDescription.self,
                DecodingError.Context.init(
                    codingPath: container.codingPath,
                    debugDescription: "Attribute type is invalid."))
        }
    }
    
    public var description: String {
        switch self {
        case .duration(let milliseconds):
            return "Lasts for \(milliseconds / 60000) minutes"
        case .fixedDate(let at):
            return at.description(with: .current)
        case .priority(index: 0):
            return "Low Priority"
        case .priority(index: 1):
            return "High Priority"
        case .priority(index: 2):
            return "Highest Priority"
        case .priority:
            return "Unknown Priority"
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: _Key.self);
        switch self {
        case .duration(let milliseconds):
            try container.encode(
                _Type.duration.stringValue,
                forKey: .type)
            try container.encode(
                milliseconds,
                forKey: .durationMilliseconds)
            return
        case .fixedDate(let date):
            try container.encode(
                _Type.fixedDate.stringValue,
                forKey: .type)
            try container.encode(
                Int64(date.timeIntervalSince1970 * 1000),
                forKey: .durationMilliseconds)
            return
        case .priority(let index):
            try container.encode(
                _Type.priority.stringValue,
                forKey: .type)
            try container.encode(
                index,
                forKey: .priorityIndex)
            return
        }
    }
    
    public func clone() -> TaskAttributeDescription {
        switch self {
        case .duration(let milliseconds):
            return .duration(milliseconds: milliseconds)
        case .fixedDate(let at):
            return .fixedDate(at: at)
        case .priority(let index):
            return .priority(index: index)
        }
    }
}
