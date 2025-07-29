//
//  ColorExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 25/7/2025.
//

import SwiftUICore
import UIKit

public struct RGB
{
    private static var _pattern = /#?(?<r>[0-9A-Fa-f]{2})(?<g>[0-9A-Fa-f]{2})(?<b>[0-9A-Fa-f]{2})/
    
    public static let white = RGB(r: 1.0, g: 1.0, b: 1.0)
    public static let black = RGB(r: 0.0, g: 0.0, b: 0.0)
    
    public var r, g, b: Float;
    
    public var red: Float { get { r } set { r = newValue } }
    public var green: Float { get { g } set { g = newValue } }
    public var blue: Float { get { b } set { b = newValue } }
    
    public init(r: Float, g: Float, b: Float) {
        self.r = r
        self.g = g
        self.b = b
    }
    public init(red: Float, green: Float, blue: Float) {
        self.init(r: red, g: green, b: blue)
    }
    public init(_ color: RGBA) {
        self.init(r: color.r, g: color.g, b: color.b)
    }
    public init?(fromHex hex: String) {
        guard let match = try? RGB._pattern.wholeMatch(in: hex) else {
            return nil
        }
        self.init(
            r: Float(Int(match.output.r, radix: 16)!) / 0xFF,
            g: Float(Int(match.output.g, radix: 16)!) / 0xFF,
            b: Float(Int(match.output.b, radix: 16)!) / 0xFF)
    }

    public var hex: String {
        return "#"
            + String(Int(r * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
            + String(Int(g * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
            + String(Int(b * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
    }
}

public struct RGBA
{
    private static var _pattern = /#?(?<r>[0-9A-Fa-f]{2})(?<g>[0-9A-Fa-f]{2})(?<b>[0-9A-Fa-f]{2})(?<a>[0-9A-Fa-f]{2})?/
    
    public static let white = RGBA(r: 1.0, g: 1.0, b: 1.0)
    public static let black = RGBA(r: 0.0, g: 0.0, b: 0.0)
    public static let transparent = RGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
    
    public var r, g, b, a: Float;
    
    public var red: Float { get { r } set { r = newValue } }
    public var green: Float { get { g } set { g = newValue } }
    public var blue: Float { get { b } set { b = newValue } }
    public var alpha: Float { get { a } set { a = newValue } }
    
    public var rgb: RGB { get { RGB(r: r, g: g, b: b) } }
    
    public init(r: Float, g: Float, b: Float, a: Float = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    public init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.init(r: red, g: green, b: blue, a: alpha)
    }
    public init(_ color: RGBA, a: Float = 1.0) {
        self.init(r: color.r, g: color.g, b: color.b, a: a)
    }
    public init(_ color: RGBA, alpha: Float = 1.0) {
        self.init(color, a: alpha)
    }
    public init?(fromHex hex: String) {
        guard let match = try? RGBA._pattern.wholeMatch(in: hex) else {
            return nil
        }
        self.init(
            r: Float(Int(match.output.r, radix: 16)!) / 0xFF,
            g: Float(Int(match.output.g, radix: 16)!) / 0xFF,
            b: Float(Int(match.output.b, radix: 16)!) / 0xFF,
            a: match.output.a == nil
                ? 1.0
                : Float(Int(match.output.a!, radix: 16)!) / 0xFF)
    }
    
    public var hex: String {
        return hex(alwaysIncludeAlpha: false)
    }
    public func hex(alwaysIncludeAlpha: Bool) -> String {
        return "#"
            + String(Int(r * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
            + String(Int(g * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
            + String(Int(b * 0xFF) & 0xFF, radix: 16, uppercase: true)
                .padding(toLength: 2, withPad: "0", startingAt: 0)
            + (!alwaysIncludeAlpha && a >= 1.0
                ? ""
                : String(Int(a * 0xFF) & 0xFF, radix: 16, uppercase: true)
                    .padding(toLength: 2, withPad: "0", startingAt: 0))
    }
}

extension Color {
    
    public init?(fromHex hex: String) {
        guard let color = RGBA(fromHex: hex) else {
            return nil
        }
        self.init(from: color)
    }
    public init(from color: RGBA) {
        self.init(
            red: Double(color.r),
            green: Double(color.g),
            blue: Double(color.b),
            opacity: Double(color.a))
    }
    public init(from color: RGB) {
        self.init(
            red: Double(color.r),
            green: Double(color.g),
            blue: Double(color.b))
    }
}

extension Color.Resolved {
    
    public var hex: String {
        return self.hex(alwaysIncludeAlpha: false)
    }
    public func hex(alwaysIncludeAlpha: Bool) -> String {
        return RGBA(from: self).hex(alwaysIncludeAlpha: alwaysIncludeAlpha)
    }
}

extension RGB {
    
    public init(from color: Color.Resolved) {
        self.init(
            r: color.red,
            g: color.green,
            b: color.blue)
    }
}

extension RGBA {
    
    public init(from color: Color.Resolved) {
        self.init(
            r: color.red,
            g: color.green,
            b: color.blue,
            a: color.opacity)
    }
}

extension UIColor {
    
    public convenience init?(fromHex hex: String) {
        guard let color = RGBA(fromHex: hex) else {
            return nil
        }
        self.init(from: color)
    }
    public convenience init(from color: RGBA) {
        self.init(
            red: Double(color.r),
            green: Double(color.g),
            blue: Double(color.b),
            alpha: Double(color.a))
    }
    public convenience init(from color: RGB) {
        self.init(
            red: Double(color.r),
            green: Double(color.g),
            blue: Double(color.b),
            alpha: 1.0)
    }
    
    public var hex: String {
        return self.hex(alwaysIncludeAlpha: false)
    }
    public func hex(alwaysIncludeAlpha: Bool) -> String {
        return RGBA(from: self).hex(alwaysIncludeAlpha: alwaysIncludeAlpha)
    }
}

extension RGBA {
    
    public init(from color: UIColor) {

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.init(
            r: Float(red),
            g: Float(green),
            b: Float(blue),
            a: Float(alpha))
    }
}

extension RGB {
    
    public init(from color: UIColor) {

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        self.init(
            r: Float(red),
            g: Float(green),
            b: Float(blue))
    }
}
