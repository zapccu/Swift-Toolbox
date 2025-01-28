//
//  Castable.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 25.01.25.
//

//
// Protocol for numeric types castable to each other
//
// This protocol does not support nil values. Therefor a static property
// "defaultValue" must be defined by each datatype. This values is returned
// by the static casting function cast(), if type casting is not possible.
//

protocol Castable: Equatable {
    
    /// Cast a numeric value from type T to type conform to protocol Castable
    static func cast<T>(_ value: T) -> (any Castable)? where T: Castable
 
    /// Compare two values
    func compareWith<T>(_ value: T) -> Bool where T: Castable
    
    /// Return a default value if a value is not castable
    static var defaultValue: Self { get }
}


//
// Make Int, UInt, Float, Double and String  conform to protocol Castable by
// implementing function cast()
//

extension Int: Castable {
    
    static var defaultValue: Int {
        return 0
    }
    
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
        else if let v = value as? String, let d = Double(v) {
            // Casting a floating point string directly to Int doesn't work
            return Int(d)
        }
        
        return defaultValue
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? Int {
            return self == v
        }
        
        return false
    }
}

extension UInt: Castable {
    
    static var defaultValue: UInt {
        return 0
    }

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
        else if let v = value as? String, let d = Double(v) {
            // Casting a floating point string directly to UInt doesn't work
            return UInt(d)
        }
        
        return defaultValue
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? UInt {
            return self == v
        }
        
        return false
    }
}

extension Float: Castable {
    
    static var defaultValue: Float {
        return Float(0.0)
    }
    
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
        else if let v = value as? String, let d = Double(v) {
            return Float(d)
        }
        
        return defaultValue
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? Float {
            return self == v
        }
        
        return false
    }
}

extension Double: Castable {
    
    static var defaultValue: Double {
        return Double(0.0)
    }
    
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
        else if let v = value as? String, let d = Double(v) {
            return d
        }
        
        return defaultValue
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? Double {
            return self == v
        }
        
        return false
    }
}

extension String: Castable {
    
    static var defaultValue: String {
        return "0"
    }
    
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
        
        return defaultValue
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? String {
            return self == v
        }
        
        return false
    }
}


//
// Extend dictionary of type <String, any Castable> to support automatic type casting
// of numeric elements. Strings containing numbers are supported. Elements of dictionary
// must not be nil!
//

typealias DictPar = Dictionary<String, any Castable>

func compareElements<T>(_ lhs: T, _ rhs: T) -> Bool where T: Castable {
    return lhs == rhs
}

extension Dictionary<String, any Castable> where Key == String, Value == any Castable {
    
    // Compare dictionaries
    static func == (lhs: Dictionary<String, any Castable>, rhs: Dictionary<String, any Castable>) -> Bool {
        guard lhs.keys.sorted() == rhs.keys.sorted() else { return false }
        
        for (k, v) in lhs {
            guard rhs[k] != nil else { return false }
            
            if !(v.compareWith(rhs[k]!)) {
                return false
            }
        }
        
        return true
    }
    
    /// Return the value of a dictionary element or a default value
    ///
    /// If key doesn't exist or element value is nil, return default (if specified) or T.defaultValue
    ///
    func get<T>(_ key: Key, default: T? = nil) -> T where T: Castable {
        guard self.keys.contains(key) && self[key] != nil else { return `default` ?? T.defaultValue }
        
        if self[key] is T {
            // types are matching
            return self[key] as! T
        }
        else {
            // cast to destination type
            return T.cast(self[key]!) as! T
        }
    }

    /// Set value of a dictionary element to the specified value or the default
    /// value of the castable type (if no value is specified)
    ///
    mutating func set<T>(_ key: Key, _ value: T? = nil) where T: Castable {
        let value: T = value ?? T.defaultValue
        
        if !self.keys.contains(key) {
            // Create new entry
            self[key] = value
        }
        else {
            // Element exists. value must be casted to type of existing element
            self[key] = type(of: self[key]!).cast(value)
        }
    }
    
    subscript<T>(_ path: String, default def: T? = nil) -> T where T: Castable {
        get {
            return get(path, default: def)
        }
        set {
            set(path, newValue)
        }
    }

}
