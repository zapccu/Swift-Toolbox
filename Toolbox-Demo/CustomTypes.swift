//
//  CustomTypes.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 19.02.25.
//
//  Example for using custom types in a ParameterSet
//

//
// Enum custom type to be used as ParameterSet value
//
// Must be conform to protocols Castable, Codable
//

enum DrawMode: Int, Castable, Codable {
    case none = 0
    case solid = 1
    case dashed = 2
  
    // Define list of valid raw values
    static let values: [Int] = [0, 1, 2]
    
    // Define string aliases to make JSON encoded values more readable
    static let names: [String] = ["none", "solid", "dashed"]
    
    /// Check if value of type T could be casted to DrawMode
    static func isCastable<T>(from: T) -> Bool {
        if from is DrawMode { return true }
        if Int.isCastable(from: from), let v = from as? any Castable {
            return values.contains(Int.cast(from: v) as! Int)
        }
        else if from is String {
            return names.contains(from as! String)
        }
        return false
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        if from is DrawMode { return from }
        if Int.isCastable(from: from) {
            return DrawMode(rawValue: Int.cast(from: from) as! Int) ?? defaultValue
        }
        else if from is String {
            return DrawMode(rawValue: names.firstIndex(of: from as! String) ?? 0) ?? defaultValue
        }
        return defaultValue
    }
    
    static var defaultValue: DrawMode { .none }
    
    /// Put drawmode name into JSON instead of rawValue
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(DrawMode.names[rawValue])
    }
}


//
// Another custom type which is stored as rawValue
//
// Conformity to Codable is not needed because parameter is stored as rawValue (Int)
// which is already conform to Codable.
//

enum Orientation: Int, Castable {
   
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2

    static let values: [Int] = [0, 1, 2]
    
    static func isCastable<T>(from: T) -> Bool {
        if from is Orientation { return true }
        if Int.isCastable(from: from), let v = from as? any Castable {
            return values.contains(Int.cast(from: v) as! Int)
        }
        return false
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        if from is Orientation { return from }
        if Int.isCastable(from: from) {
            return Orientation(rawValue: Int.cast(from: from) as! Int) ?? defaultValue
        }
        return defaultValue
    }
    
    static var defaultValue: Orientation { .portrait }
}
