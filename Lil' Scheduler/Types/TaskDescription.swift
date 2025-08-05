//
//  TaskDescription.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

public final class TaskDescription : Codable {
    
    private enum _Key: CodingKey {
        
        case title
        case description
        case color
        case attributes
        
        public var stringValue: String {
            switch self {
            case .title: "title"
            case .description: "description"
            case .color: "color"
            case .attributes: "attributes"
            }
        }
        
        public init?(stringValue: String) {
            switch stringValue {
            case "title":
                self = .title
                return
            case "description":
                self = .description
                return
            case "color":
                self = .color
                return
            case "attributes":
                self = .attributes
                return
            default:
                return nil
            }
        }
    }

    public var title: String
    public var description: String
    public var color: RGB
    public var attributes: [CalendarTaskAttribute]?
    
    public init(
        title: String,
        description: String,
        color: RGB,
        attributes: [CalendarTaskAttribute]? = nil
    ) {
        self.title = title
        self.description = description
        self.color = color
        self.attributes = attributes
    }
    
    public init(from decoder: any Decoder) throws {

        let container = try decoder.container(keyedBy: _Key.self)

        title = try container.decode(
            String.self,
            forKey: .title)

        description = try container.decodeIfPresent(
            String.self,
            forKey: .description) ?? ""

        let encodedColor = try container.decodeIfPresent(
            String.self,
            forKey: .color) ?? ""

        if encodedColor == "" {
            color = RGB.white
        }
        else {
            guard let parsedColor = RGB(fromHex: encodedColor) else {
                throw DecodingError.typeMismatch(
                    TaskDescription.self,
                    DecodingError.Context.init(
                        codingPath: container.codingPath,
                        debugDescription: "Failed to parse color."))
            }
            color = parsedColor
        }

        attributes = try container.decodeIfPresent(
            [CalendarTaskAttribute].self,
            forKey: .attributes)
    }

    public func encode(to encoder: any Encoder) throws {

        var container = encoder.container(keyedBy: _Key.self)

        try container.encode(title, forKey: .title)

        if description.count != 0 {
            try container.encode(description, forKey: .description)
        }

        try container.encode(color.hex, forKey: .color)

        if let attributes = attributes, attributes.count != 0 {
            try container.encode(attributes, forKey: .attributes)
        }
    }
    
    public func clone() -> TaskDescription {
        return TaskDescription(
            title: self.title,
            description: self.description,
            color: self.color,
            attributes: self.attributes?.map { attribute in
                attribute.clone()
            })
    }
}
