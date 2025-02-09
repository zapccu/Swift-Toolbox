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
    ///
    /// Example: Int.isCastable(5.0)
    func isCastable<T>(from: T) -> Bool

    /// Cast a numeric value from type T to a type conform to protocol Castable
    ///
    /// If casting is not possible, defaultValue must be returned.
    static func cast<T>(from: T) -> (any Castable) where T: Castable
    
    /// Value to be returned of a value is not castable. Usually zero
    static var defaultValue: Self { get }
    
}

/// Compare two castable values
///
/// If types are different, value on right hand side is casted to type
/// of left hand side value berfore comparing the values.
/// For exact matching without casting use operator ==
///
func compare<L,R>(_ lhs: L, _ rhs: R) -> Bool where L: Castable, R: Castable {
    return lhs.isCastable(from: rhs) ? L.cast(from: rhs) as! L == lhs : false
}

//
// Make Int, UInt, Float, Double and String  conform to protocol Castable by
// implementing defaultValue, isCastable(), cast(), compareWith()
//

extension Int: Castable {
    
    static var defaultValue: Int { 0 }
    
    func isCastable<T>(from: T) -> Bool {
        return from is Int || from is UInt || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as Int:    return v
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

    func isCastable<T>(from: T) -> Bool {
        return from is UInt || from is Int || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as UInt:   return v
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

    func isCastable<T>(from: T) -> Bool {
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
    
    func isCastable<T>(from: T) -> Bool {
        return from is UInt || from is Int || from is Float || from is Double || (from is String && Double(from as! String) != nil)
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as Double: return v
            case let v as Int:    return Double(v)
            case let v as UInt:   return Double(v)
            case let v as Float:  return Int(v)
            case let v as String where Double(v) != nil: return Double(v)!
            default: return defaultValue
        }
    }
}

extension String: Castable {
    
    static var defaultValue: String { return "" }
    
    func isCastable<T>(from: T) -> Bool {
        return from is UInt || from is Int || from is Float || from is Double || from is String
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as String: return v
            case let v as Int:    return String(v)
            case let v as UInt:   return String(v)
            case let v as Float:  return String(v)
            case let v as Double: return String(v)
            default: return defaultValue
        }
    }
}


