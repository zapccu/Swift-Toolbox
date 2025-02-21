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
    
    /// Check if value of type T is castable to current value
    /// Example: Int.isCastable(5.0)
    static func isCastable<T>(from: T) -> Bool

    /// Cast a numeric value from type T to a type conform to protocol Castable
    /// If casting is not possible, defaultValue must be returned.
    static func cast<T>(from: T) -> (any Castable) where T: Castable
    
    /// Value to be returned if a value is not castable. Usually zero
    static var defaultValue: Self { get }
    
}

/// Compare two castable values
///
/// If types are different, value on right hand side is casted to type
/// of left hand side value berfore comparing the values.
/// For exact matching without casting use operator ==
///
func compare<L,R>(_ lhs: L, _ rhs: R) -> Bool where L: Castable, R: Castable {
    return L.isCastable(from: rhs) ? L.cast(from: rhs) as! L == lhs : false
}

//
// Make Bool, Int, UInt, Float, Double and String conform to protocol Castable by
// implementing defaultValue { get }, isCastable(), cast()
//

extension Bool: Castable {
    
    static var defaultValue: Bool { false }
    
    static func isCastable<T>(from: T) -> Bool {
        switch from {
        case _ as Bool:   return true
        case _ as Int:    return true
        case _ as UInt:   return true
        case let v as String: return ["true", "false", "1", "0"].contains(v.lowercased()) ? true : false
        default:              return false
        }
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch(from) {
        case let v as Bool:    return v
        case let v as Int:     return v != 0 ? true : false
        case let v as UInt:    return v != 0 ? true : false
        case let v as String:  return ["true", "1"].contains(v.lowercased()) ? true : defaultValue
        default: return defaultValue
        }
    }
}

extension Int: Castable {
    
    static var defaultValue: Int { 0 }
    
    static func isCastable<T>(from: T) -> Bool {
        return from is Bool || from is Int || from is UInt || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
        case let v as Int:    return v
        case let v as Bool:   return v ? 1 : 0
        case let v as UInt:   return Int(v)
        case let v as Float:  return Int(v)
        case let v as Double: return Int(v)
        case let v as String where Double(v) != nil: return Int(Double(v)!)
        default: return defaultValue
        }
    }
}

extension UInt: Castable {
    
    static var defaultValue: UInt { 0 }

    static func isCastable<T>(from: T) -> Bool {
        return from is Bool || from is UInt || from is Int || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
        case let v as UInt:   return v
        case let v as Bool:   return v ? 1 : 0
        case let v as Int:    return UInt(v)
        case let v as Float:  return UInt(v)
        case let v as Double: return UInt(v)
        case let v as String where Double(v) != nil: return UInt(Double(v)!)
        default: return defaultValue
        }
    }
}

extension Float: Castable {
    
    static var defaultValue: Float { Float(0.0) }

    static func isCastable<T>(from: T) -> Bool {
        return from is UInt || from is Int || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as Float:  return v
            case let v as Int:    return Float(v)
            case let v as UInt:   return Float(v)
            case let v as Double: return Float(v)
            case let v as String where Double(v) != nil: return Float(Double(v)!)
            default: return defaultValue
        }
    }
}

extension Double: Castable {
    
    static var defaultValue: Double { Double(0.0) }
    
    static func isCastable<T>(from: T) -> Bool {
        return from is UInt || from is Int || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as Double: return v
            case let v as Int:    return Double(v)
            case let v as UInt:   return Double(v)
            case let v as Float:  return Double(v)
            case let v as String where Double(v) != nil: return Double(v)!
            default: return defaultValue
        }
    }
}

extension String: Castable {
    
    static var defaultValue: String { return "" }
    
    static func isCastable<T>(from: T) -> Bool {
        return from is Bool || from is UInt || from is Int || from is Float || from is Double || from is String
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
        case let v as String: return v
        case let v as Bool:   return v ? "true" : "false"
        case let v as Int:    return String(v)
        case let v as UInt:   return String(v)
        case let v as Float:  return String(v)
        case let v as Double: return String(v)
        default: return defaultValue
        }
    }
}


//
// Extend Dictionary to support Castable element values
//

extension Dictionary where Key == String {
    
    /*
    /// Get castable value
    func getValue<T>(path: String, default def: T) -> T where T: Castable {
        return self[path: path, default: def]
    }
    
    /// Set castable value
    mutating func setValue<T>(path: String, _ value: T) where T: Castable {
        self[path: path] = value
    }
    */
    
    /// Delete a dictionary element
    mutating func delete(_ path: String) {
        if pathExists(path) {
            self[keyPath: path] = nil
        }
    }
    
    /// Cast dictionary elements from specified dictionary
    mutating func cast(fromDict: DictAny) {
        for (key, value) in fromDict {
            if keys.contains(key) {
                // Element exists
                if let d = value as? DictAny, var e = self[key] as? DictAny {
                    // If existing element is a dictionary, recursively call cast()
                    e.cast(fromDict: d)
                    self[key] = (e as! Value)
                }
                else if let v = value as? any Castable, let e = self[key] as? any Castable, type(of: e).isCastable(from: v) {
                    // If existing element and source element are castable values, cast source to destination element
                    self[key] = (type(of: e).cast(from: v) as! Value)
                }
            }
            else {
                // Element doesn't exist. Create new element
                self[key] = (value as! Value)
            }
        }
    }
    
    /// Get or set dictionary of type [String: Any]
    subscript(path path: String, default def: DictAny = [:]) -> DictAny {
        get {
            guard let v = self[path] as? DictAny else { return def }
            return v
        }
        set {
            self[path] = (newValue as! Value)
        }
    }
    
    /// Get or set a castable value identified by parameter path
    ///
    /// Getting a value for a non existing element returns ...
    ///    ... default value if parameter default is specified
    ///    ... T.defaultValue if no default value is specified
    ///
    /// Getting a value for an existing but not castable element returns T.default
    ///
    /// Setting a value fails if ...
    ///    ... path addresses sub-dictionaries and type of a path segment is not DictAny
    ///    ... element exists but new value cannot be casted to type of existing element
    ///
    /// When setting a value for non-existing sub-dictionaries or elements, sub-dictionaries
    /// and elements are created.
    ///
    subscript<T>(path path: String, default def: T = T.defaultValue) -> T where T: Castable {
        get {
            // Split path into segments
            let segs = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard segs.count > 0 && segs[0] != "" && self.keys.contains(segs[0]) else { return def }
            
            let key = Key(segs[0])
            
            if segs.count == 1 {
                // Reached last element in path
                if let v = self[key] as? any Castable, T.isCastable(from: v) {
                    // Cast element value to desired type
                    return T.cast(from: v) as! T
                }
            }
            else if let subDict = self[key] as? DictAny {
                // Current element is a (sub-)dictionary of type [String: Any]
                let newPath = segs.dropFirst().joined(separator: ".")
                // return subDict.getValue(path: newPath, default: def)
                return subDict[path: newPath, default: def]
            }

            // In any other case return default value
            return def
        }
        set {
            // Split path into segments
            let segs = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard segs.count > 0 && segs[0] != "" else { return }
            
            let key = Key(segs[0])
            
            if segs.count == 1 {
                // Reached last element in path
                if self.keys.contains(key) {
                    if let v = self[path] as? any Castable, type(of: v).isCastable(from: newValue) {
                        // Element exists and new value is castable
                        // Cast new value to type of existing element
                        let t = type(of: v)
                        self[key] = (t.cast(from: newValue) as! Value)
                    }
                }
                else {
                    // Element doesn't exist. Add element to dictionary
                    self[key] = (newValue as! Value)
                }
            }
            else {
                let newPath = segs.dropFirst().joined(separator: ".")
                
                if self.keys.contains(key) {
                    // Element exists
                    if var subDict = self[key] as? DictAny {
                        // Element is a (sub-)dictionary of type [String: Any]
                        subDict[path: newPath] = newValue
                        //subDict.setValue(path: newPath, newValue)
                        self[key] = (subDict as! Value)
                    }
                }
                else {
                    // Element does not exist. Create sub-dictionary and assign value
                    var subDict: [Key: Any] = [:]
                    subDict[path: newPath] = newValue
                    //subDict.setValue(path: newPath, newValue)
                    self[key] = (subDict as! Value)
                }
            }
        }
    }
    
}
