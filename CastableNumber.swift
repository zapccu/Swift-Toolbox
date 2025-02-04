//
//  Castable.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 25.01.25.
//

//
// Protocol for castable types
//

protocol Castable: Equatable, Any {
    
    /// Check if value is castable to type T
    static func isCastable<T>(_ value: T) -> Bool

    /// Cast a numeric value from type T to a type conform to protocol Castable.
    /// If casting is not possible, defaultValue must be returned.
    static func cast<T>(_ value: T) -> (any Castable) where T: Castable
    
    /// Compare two values
    func compareWith<T>(_ value: T) -> Bool where T: Castable
   
    /// Return a default value if a value is not castable
    static var defaultValue: Self { get }
    
}


//
// Make Int, UInt, Float, Double and String  conform to protocol Castable by
// implementing defaultValue, isCastable(), cast(), compareWith()
//

extension Int: Castable {
    
    static var defaultValue: Int {
        return 0
    }
    
    static func isCastable<T>(_ value: T) -> Bool {
        return value is Int || value is UInt || value is Float || value is Double || (value is String && Int(value as! String) != nil)
    }
    
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
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

    static func isCastable<T>(_ value: T) -> Bool {
        return value is UInt || value is Int || value is Float || value is Double || (value is String && UInt(value as! String) != nil)
    }
    
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
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

    static func isCastable<T>(_ value: T) -> Bool {
        return value is UInt || value is Int || value is Float || value is Double || (value is String && Float(value as! String) != nil)
    }
    
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
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
    
    static func isCastable<T>(_ value: T) -> Bool {
        return value is UInt || value is Int || value is Float || value is Double || (value is String && Double(value as! String) != nil)
    }
    
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
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
        return ""
    }
    
    static func isCastable<T>(_ value: T) -> Bool {
        return value is UInt || value is Int || value is Float || value is Double || value is String
    }
    
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
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

extension Dictionary where Key == String {
    
    /// Get or set a castable value identified by parameter path
    ///
    /// Getting a value for a non existing element returns ...
    ///    ... default if parameter default is specified
    ///    ... default of type T if no default is specified or value cannot be casted to type T
    ///
    /// Setting a value fails if type of a sub-dictionary element is not DictAny or if element
    /// exists but new value cannot be casted to type of existing element
    ///
    subscript<T>(path path: String, default def: T = T.defaultValue) -> T where T: Castable {
        get {
            if let v = self[keyPath: path] as? any Castable {
                return T.cast(v) as! T
            }
            
            return def
        }
        set {
            if let v = self[keyPath: path] as? any Castable {
                // Element exists and value is castable
                let t = type(of: v)
                if t.isCastable(newValue) {
                    self[keyPath: path] = t.cast(newValue)
                }
            }
            else if !self.keys.contains(path) {
                // Element doesn't exist. Create a new entry
                self[keyPath: path] = newValue
            }
        }
    }
}

//
// Extend dictionary of type <String, any Castable> to support automatic type casting
// of numeric elements. Strings containing numbers are supported.
//
// Requirements:
//
// - Elements of dictionary must not be nil
// - Element types must be conform to protocol Castable
//

/*
// Type alias
typealias DictPar = Dictionary<String, any Castable>

/// Compare two castable values of same type
func compareElements<T>(_ lhs: T, _ rhs: T) -> Bool where T: Castable {
    return lhs == rhs
}

/// Compare two castable values of different types
/// Value rhs is casted to T before comparing the values
func compareElemments<T, U>(_ lhs: T, _ rhs: U) -> Bool where T: Castable, U: Castable {
    if type(of: lhs) == type(of: rhs) {
        return compareElements(lhs, rhs as! T)
    }
    else {
        return compareElements(lhs, T.cast(rhs) as! T)
    }
}
 */

// Make Dictionary conform to protocol Castable
/*
extension Dictionary : Castable where Key == String, Value: Castable {
    
    static func isCastable<T>(_ value: T) -> Bool {
        return value is Dictionary<String, any Castable>
    }
    
    /// Cast to Dictionary
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
        // Only Dictionaries can be casted to Dictionaries
        if let v = value as? Dictionary<String, T> {
            return v
        }
        
        return defaultValue
    }
    
    /// Compare dictionary with value of castable type
    /// Return true if value is Dictionary and both dictionaries are equal
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let rhs = value as? Dictionary<String, any Castable> {
            guard keys.sorted() == rhs.keys.sorted() else { return false }
            
            for (k, v) in self {
                guard rhs[k] != nil else { return false }
                
                if !(v.compareWith(rhs[k]!)) {
                    return false
                }
            }
        }
        
        return false
    }
    
    // Default value is an empty dictionary
    static var defaultValue: Dictionary<Key, Value> {
        return [:]
    }

}
 */

//
// Extend dictionary to support automatic type casting of values
//
// Reading from dictionary:
//
// When reading from dictionaries with automatic type casting, the
// destination type must be inferable by Swift. The type must be
// specified either on the left hand side of an assignment in the
// variable definition or as a default value on the right hand side.
//
//   // Value of element "a" is casted to type of x (Int)
//   let x: Int = myDict[path: "a"]
//   let x: Int = myDict.get("a")
//
//   // Value of element "a" is casted to type of default value (Int)
//   let x = myDict[path: "a", default: 10]
//   let x = myDict.get("a", default: 10)
//
// Writing to dictionaries:
//
// When assigning a value to an existing dictionary element, the
// value is casted to the type of the element. If the element doesn't
// exist, a new element with the type of the value is created.
//
/*
extension Dictionary where Key == String, Value == any Castable {
//extension Dictionary<String, any Castable> {
    
    /// Compare dictionaries
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
    
    /// Get value of dictionary element
    /// Return specifid default if element doesn't exist
    func get<T>(_ key: Key, default def: T = T.defaultValue) -> T where T: Castable {
        print("  Dictionary func get key = \(key), default = >\(def)<")
                
        if let i = index(forKey: key) {
            if let v = self[i].value as? T {
                print("    Return value without cast")
                return v
            }
            else {
                // return T.cast(self[key]!) as! T
                print("    Return value casted to \(T.self)")
                // let v = self[i].value
                return T.cast(self[key]!) as! T
                //return T.cast(v) as! T
            }
        }
        
        return def
    }
    
    func get<T>(_ key: String, toType: T.Type) -> T where T: Castable {
        if self.keys.contains(key) {
            return toType.cast(self[key]!) as! T
        }
        
        return T.defaultValue
    }
    
    /// Set value of a dictionary element to the specified value or the default
    /// value of the castable type (if no value is specified)
    mutating func set<T>(_ key: Key, _ value: T) where T: Castable {
        print("  Dictionary func set key = \(key), value = \(value)")
        
        if let i = index(forKey: key) {
            let t = type(of: self[i].value)
            print("    Cast \(value) to \(t)")
            self[key] = t.cast(value)
        }
        else {
            print("    Assign \(value) to new element")
            self[key] = value
        }
    }

    /// Access dictionary element by subscript with type default
    subscript<T>(path path: String) -> T where T: Castable {
        get {
            print("  subscript get path = \(path)")
            return self[path: path, default: T.defaultValue]
        }
        set {
            print("  subscript set path = \(path), value = \(newValue)")
            if let i = index(forKey: path) {
                // Element exists. value must be casted to type of existing element
                print("    Assign \(newValue) to existing element")
                let t = type(of: self[i].value)
                self[path] = t.cast(newValue)
            }
            else {
                // Add a new parameter
                print("    Add \(newValue) as new parameter")
                self[path] = newValue
            }
        }
    }
    
    /// Access dictionary element by subscript with default value
    subscript<T>(path path: String, default def: T) -> T where T: Castable {
        get {
            print("  subscript get path = \(path), default = \(def)")
            if let i = index(forKey: path) {
                if self[i].value is T {
                    // types are matching
                    return self[i].value as! T
                }
                else {
                    let v = self[i].value
                    return T.cast(v) as! T
                }
            }

            return def
        }
        set {
            print("  subscript set path = \(path), value = \(newValue)")
            self[path] = newValue
        }
    }

}
*/
