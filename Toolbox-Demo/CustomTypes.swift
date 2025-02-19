//
//  CustomTypes.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 19.02.25.
//
//  Example for using custom types in a ParameterSet
//

//
// Enum custom type
//

enum DrawMode: Int {
    case none = 0
    case solid = 1
    case dashed = 2
  
    // Define list of valid raw values
    static let values: [Int] = [0, 1, 2]
    
    // Define string aliases to make JSON encoded values more readable
    static let names: [String] = ["none", "solid", "dashed"]
}

// Make custom type conform to protocols Castable and Codable
extension DrawMode : Castable, Codable {
    
    /// Check if value of type T could be casted to DrawMode
    func isCastable<T>(from: T) -> Bool {
        var value: Int
        
        switch from {
        case _ as DrawMode:   return true
        case let v as Int:    value = v
        case _ as Bool:       return false
        case let v as UInt:   value = Int(v)
        case let v as Float:  value = Int(v)
        case let v as Double: value = Int(v)
        case let v as String: return DrawMode.names.contains(v)
        default: return false
        }
        
        return DrawMode.values.contains(value)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
        case let v as DrawMode: return v
        case let v as Int:      return DrawMode(rawValue: v) ?? defaultValue
        case let v as UInt:     return DrawMode(rawValue: Int(v)) ?? defaultValue
        case let v as Float:    return DrawMode(rawValue: Int(v)) ?? defaultValue
        case let v as Double:   return DrawMode(rawValue: Int(v)) ?? defaultValue
        case let v as String:   return DrawMode(rawValue: names.firstIndex(of: v) ?? 0) ?? defaultValue
        default: return defaultValue
        }
    }
    
    static var defaultValue: DrawMode {
        .none
    }
    
    /// Put drawmode name into JSON instead of rawValue
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(DrawMode.names[rawValue])
    }
}
