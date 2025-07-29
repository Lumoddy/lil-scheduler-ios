//
//  UserData.swift
//  Lil' Scheduler
//
//  Created by 13878 on 29/7/2025.
//

public class UserData : Codable {
    
    private enum _Key : CodingKey {
        
        case tasks
        
        public var stringValue: String {
            switch self {
            case .tasks: "tasks"
            }
        }
        
        public init?(stringValue: String) {
            switch stringValue {
            case "tasks":
                self = .tasks
                return
            default:
                return nil
            }
        }
        
        public init?(intValue: Int) { nil }
    }

    public var tasks: [CalendarTask];
    
    public init() {
        self.tasks = []
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: _Key.self)
        self.tasks = try container.decode(
            [CalendarTask].self,
            forKey: _Key.tasks)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: _Key.self)
        try container.encode(self.tasks, forKey: _Key.tasks)
    }
}
