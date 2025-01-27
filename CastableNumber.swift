//
//  Castable.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 25.01.25.
//

//
// Protocol for numeric types castable to each other
//

protocol Castable: Equatable {
    
    /// Cast a numeric value
    static func cast<T>(_ value: T) -> (any Castable)? where T: Castable
}


//
// Make Int, UInt, Float, Double conform to protocol Castable
//

extension Int: Castable {

    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
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
        else if let v = value as? String {
            return Int(v)
        }

        return nil
    }
}

extension UInt: Castable {

    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
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
        else if let v = value as? String {
            return UInt(v)
        }
        
        return nil
    }
}

extension Float: Castable {
    
    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
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
        else if let v = value as? String {
            return Float(v)
        }
        
        return nil
    }
}

extension Double: Castable {
    
    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
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
        else if let v = value as? String {
            return Double(v)
        }
        
        return nil
    }
}

extension String: Castable {
    
    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
        if let v = value as? String {
            return v
        }
        else if let v = value as? Int {
            return String(v)
        }
        else if let v = value as? UInt {
            return String(v)
        }
        else if let v = value as? Float {
            return String(v)
        }
        else if let v = value as? Double {
            return String(v)
        }
        
        return nil
    }
}


//
// Extend dictionary of type <String, Any> to support automatic type casting
// of numeric elements
//

extension Dictionary<String, any Castable> where Key == String {
    
    static func == (lhs: Dictionary<String, any Castable>, rhs: Dictionary<String, any Castable>) -> Bool {
        return lhs.keys.sorted() == rhs.keys.sorted()
    }
    
    func getVal<D>(_ key: Key, _ defaultValue: D = 0) -> D where D: Castable {
        if self[key] is D {
            return self[key] as? D ?? defaultValue
        }
        else {
            return D.cast(self[key]!) as! D
        }
    }
    
    /// Return type casted numeric value of dictionary entry of type Int, UInt, Float, Double, String
    /*
    func getValue<T>(_ key: Key, _ defaultValue: T = 0) -> T where T: Castable {
        guard self[key] != nil else { return defaultValue }

        if self[key] is T {
            // No type casting necessary
            return self[key] as? T ?? defaultValue
        }
        else if let v = self[key] {
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
     */

    mutating func setVal(_ key: Key, _ value: Value) {
        if !self.keys.contains(key) {
            // Create new entry
            self[key] = (value )
        }
        else {
            self[key] = type(of: self[key]!).cast(value)
        }
    }
    
    /// Set dictionary entry to numeric value
    /*
    mutating func setValue<T>(_ key: Key, _ value: T, defaultValue: T = 0) where T: Castable {
        if !self.keys.contains(key) {
            // Create new entry
            self[key] = (value as! Value)
        }
        else {
            // Entry exists
            if self[key] is Int {
                self[key] = (((Int.cast(value)) ?? defaultValue) )
            }
            else if self[key] is UInt {
                self[key] = (((UInt.cast(value)) ?? defaultValue) )
            }
            else if self[key] is Float {
                self[key] = (((Float.cast(value)) ?? defaultValue) )
            }
            else if self[key] is Double {
                self[key] = (((Double.cast(value)) ?? defaultValue) )
            }
            else if self[key] is String {
                self[key] = (((String.cast(value)) ?? defaultValue) )
            }
        }
    }
     */
    
    subscript<T>(_ path: String, defaultValue: T? = nil) -> T? where T: Castable {
        get {
            return getVal(path, defaultValue!)
        }
        set {
            setVal(path, newValue!)
        }
    }
    
    /*
    subscript<T>(_ path: String, defaultValue: T? = nil) -> T? where T: StringProtocol {
        get {
            return getValue(path, defaultValue!)
        }
        set {
            setVal(path, newValue!)
        }
    }
     */
}
