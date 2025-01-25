//
//  DictionaryPath.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//

typealias DictPar = Dictionary<String,Any>

//
// Extend Dictionaries of type <String,Any> by subscript parameter "path".
// A path allows read and write access to a Dictionary hierarchy.
// A path is a string where the segments are seperated by a ".".
//
// Example:
//
// let myDict = [
//    "a": 1, "b": 2,
//    "c:" [
//       "d:" 3
//    ]
//
// let x = myDict["c.d"]!
// myDict["c.d"] = 10
//

extension Dictionary<String, Any> {

    /// Check if path exists
    func pathExists(_ path: String) -> Bool {
        let seg = path.components(separatedBy: ".")
        
        // Prevent an empty key
        guard seg.count > 0 else { return false }
        
        if let element = self[seg[0]] {
            if element is DictPar {
                let newDict = element as! DictPar
                let newPath = seg.dropFirst().joined(separator: ".")
                return newDict.pathExists(newPath)
            }
            else if seg.count == 1 {
                return true
            }
        }
        
        return false
    }
    
    /// Get or set value identified by path
    subscript(_ path: String, _ defaultValue: Any? = nil) -> Any? {
        get {
            let seg = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard seg.count > 0 else { return nil }
            
            if seg.count == 1 {
                return self[seg[0], default: defaultValue!]
            }

            if let element = self[seg[0]] {
                if element is DictPar {
                    // Element is a dictionary
                    // Recursively call subscript with child dictionary and remanining path
                    let newDict = element as! DictPar
                    let newPath = seg.dropFirst().joined(separator: ".")
                    return newDict[newPath, defaultValue]
                }
            }
            
            return defaultValue
        }
        set {
            let seg = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard seg.count > 0 else { return }
            
            if seg.count == 1 {
                // Reached last element in path
                self[seg[0]] = newValue
            }
            else {
                // Recursively call subscript assignment with remaining path
                var dict: DictPar = self[seg[0]] == nil ? [:] : self[seg[0]] as! DictPar
                let newPath = seg.dropFirst().joined(separator: ".")
                dict[newPath] = newValue
                self[seg[0]] = dict
            }
        }
    }
}


//
// Protocol for numeric types castable to each other
//

protocol CastableNumber: Numeric {
    
    /// Cast a numeric value
    static func cast<T>(_ value: T) -> (any CastableNumber)? where T: CastableNumber
}


//
// Make Int, UInt, Float, Double conform to protocol CastableNumber
//

extension Int: CastableNumber {

    static func cast<T>(_ value: T) -> (any CastableNumber)? where T : CastableNumber {
        if let v = value as? Int {
            return v
        }
        else if let v = value as? UInt {
            return Int(v)
        }
        else if let v = value as? Float {
            return Int(v)
        }
        else if let v = value as? Double {
            return Int(v)
        }
        else {
            return nil
        }
    }
}

extension UInt: CastableNumber {

    static func cast<T>(_ value: T) -> (any CastableNumber)? where T : CastableNumber {
        if let v = value as? UInt {
            return v
        }
        else if let v = value as? Int {
            return UInt(v)
        }
        else if let v = value as? Float {
            return UInt(v)
        }
        else if let v = value as? Double {
            return UInt(v)
        }
        else {
            return nil
        }
    }
}

extension Float: CastableNumber {
    
    static func cast<T>(_ value: T) -> (any CastableNumber)? where T : CastableNumber {
        if let v = value as? Float {
            return v
        }
        else if let v = value as? Int {
            return Float(v)
        }
        else if let v = value as? UInt {
            return Float(v)
        }
        else if let v = value as? Double {
            return Float(v)
        }
        else {
            return nil
        }
    }
}

extension Double: CastableNumber {
    
    static func cast<T>(_ value: T) -> (any CastableNumber)? where T : CastableNumber {
        if let v = value as? Double {
            return v
        }
        else if let v = value as? Int {
            return Double(v)
        }
        else if let v = value as? UInt {
            return Double(v)
        }
        else if let v = value as? Float {
            return Double(v)
        }
        else {
            return nil
        }
    }
}


//
// Extend dictionary of type <String, Any> to support automatic type casting
// of numeric elements
//

extension Dictionary<String, Any> {
    
    /// Return type casted numeric value of dictionary entry of type Int, UInt, Float, Double, String
    func getValue<T>(_ key: Key, _ defaultValue: T = 0) -> T where T: CastableNumber {
        guard self[key] != nil else { return defaultValue }
        
        if self[key] is T {
            // No type casting necessary
            return self[key] as? T ?? defaultValue
        }
        else if let v = self[key] as? (any CastableNumber) {
            if T.self == Int.self {
                return Int.cast(v) as? T ?? defaultValue
            }
            else if T.self == UInt.self {
                return UInt.cast(v) as? T ?? defaultValue
            }
            else if T.self == Float.self {
                return Float.cast(v) as? T ?? defaultValue
            }
            else if T.self == Double.self {
                return Double.cast(v) as? T ?? defaultValue
            }
        }
        else if let v = self[key] as? String {
            if T.self == Int.self {
                return (Int(v) as? T) ?? defaultValue
            }
            else if T.self == UInt.self {
                return (UInt(v) as? T) ?? defaultValue
            }
            else if T.self == Float.self {
                return (Float(v) as? T) ?? defaultValue
            }
            else if T.self == Double.self {
                return (Double(v) as? T) ?? defaultValue
            }
        }
        
        return defaultValue
    }
    
    /// Return string value of dictionary entry of type Int, UInt, Float, Double, String
    func getValue<T>(_ key: Key, _ defaultValue: T = "") -> T where T: StringProtocol {
        if self[key] is T {
            return self[key] as? T ?? defaultValue
        }
        else if let v = self[key] as? (any LosslessStringConvertible) {
            return String(v) as? T ?? defaultValue
        }
        else {
            return defaultValue
        }
    }
    
    /// Set dictionary entry to numeric value
    mutating func setValue<T>(_ key: Key, _ value: T, defaultValue: T = 0) where T: CastableNumber {
        if self[key] == nil {
            // Create new entry
            self[key] = value
        }
        else {
            // Entry exists
            if self[key] is Int {
                self[key] = (Int.cast(value)) ?? defaultValue
            }
            else if self[key] is UInt {
                self[key] = (UInt.cast(value)) ?? defaultValue
            }
            else if self[key] is Float {
                self[key] = (Float.cast(value)) ?? defaultValue
            }
            else if self[key] is Double {
                self[key] = (Double.cast(value)) ?? defaultValue
            }
        }
    }
    
    /// Set dictionary entry to String value. If entry exists an has a numeric type, String value is converted to numeric type
    mutating func setValue<T>(_ key: Key, _ value: T, defaultValue: T = "0") where T: StringProtocol {
        if self[key] == nil {
            self[key] = value
        }
        else {
            // Entry exists
            if self[key] is String {
                self[key] = value
            }
            else if self[key] is Int {
                self[key] = (Int(value)) ?? defaultValue
            }
            else if self[key] is UInt {
                self[key] = (UInt(value)) ?? defaultValue
            }
            else if self[key] is Float {
                self[key] = (Float(value)) ?? defaultValue
            }
            else if self[key] is Double {
                self[key] = (Double(value)) ?? defaultValue
            }
        }
    }
    
    subscript<T>(_ path: String, defaultValue: T? = nil) -> T? where T: CastableNumber {
        get {
            return getValue(path, defaultValue!)
        }
        set {
            setValue(path, newValue!)
        }
    }
    
    subscript<T>(_ path: String, defaultValue: T? = nil) -> T? where T: StringProtocol {
        get {
            return getValue(path, defaultValue!)
        }
        set {
            setValue(path, newValue!)
        }
    }
}
