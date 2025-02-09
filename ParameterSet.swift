//
//  ParameterSet.swift
//
//  Part of Swift-Toolbox
//
//  Requires Castable, Dictionary Path, JEncodeDecode
//
//  Created by Dirk Braner on 24.11.24.
//


import Foundation

//
// Extend Dictionary to support Castable element values
//

extension Dictionary where Key == String {
    
    /// Get or set a castable value identified by parameter path
    ///
    /// Getting a value for a non existing element returns ...
    ///    ... default if parameter default is specified
    ///    ... T.defaultValue if no default is specified
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
            if let v = self[keyPath: path, default: def] as? any Castable {
                print("  \(path) is \(type(of: v))")
                // Cast value of element to destination type
                if T.defaultValue.isCastable(from: v) {
                    return T.cast(from: v) as! T
                }
            }
            
            return def
        }
        set {
            if pathExists(path) {
                if let v = self[keyPath: path] as? any Castable, v.isCastable(from: newValue) {
                    // Element exists and new value is castable
                    let t = type(of: v)
                    self[keyPath: path] = t.cast(from: newValue)
                }
            }
            else {
                // Element doesn't exist. Create a new entry
                self[keyPath: path] = newValue
            }
        }
    }
}

//
// ParameterSet structure
//
// A ParameterSet contains 3 dictionaries for current, previous and initial
// parameter values which can be used to manage application parameters.
// The dictionaries are of type <String, Any> / DictAny
//
//   .current - Dictionary with current parameter values. When a parameter
//      value is changed in this dictionary, the old value is stored in
//      dictionary .previous
//
//   .previous - Dictionary with previous parameter values. After initialization
//      of a parameterset values of .current and .previous are identical
//
//   .initial - Dictionary with initial values
//
// Note:
//
//  *** The data type of an element must be conform to protocol Castable! ***
//
// Methods:
//
//   reset(_ path: String?) - Reset a parameter or the whole parameterset
//      to it's initial value(s)
//
//   apply(_ path: String?) - Copy a parameter or the whole parameterset
//      from .current to .previous
//
//   undo(_ path: String?) - Copy a parameter or the whole parameter set
//      from .previous to .current
//
//   addSettings(_ initialValues: DictPar) - Add new parameters to parameterset.
//      New parameters are merged with dictionaries .current, .previous, .initial
//
// Parameter values can be read or set by using subscripts.
//
// Example: Read a parameter value
//
//   let value: T = parameterSet[path: String, default: T? = nil]
//
// Reading a parameter value will never return nil. If no default value is
// specified and the path exists, the initial value of a parameter is returned.
// If the path doesn't exist, the default value of the castable type is returned.
//
// Example: Set a parameter value
//
//   parameterSet[path: String] = newValue
//
// If an element exists and newValue is castable to the type of the element,
// newValue is assigned to the element. If newValue is not castable to the type
// of an existing element, nothing happens.
// If an element doesn't exist, a new element with type of newValue is created.
//

struct ParameterSet : Castable, Codable {
    
    //
    // Make ParameterSet conform to protocol Castable
    //
    
    // Default value is an empty parameterset
    static var defaultValue: ParameterSet { ParameterSet([:]) }
    
    /// Check if value is castable to ParameterSet
    func isCastable<T>(from: T) -> Bool {
        return from is ParameterSet || from is DictAny
    }
    
    static func cast<T>(from: T) -> (any Castable) where T : Castable {
        switch from {
            case let v as ParameterSet: return v
            case let v as DictAny: return ParameterSet(v)
            default: return defaultValue
        }
    }
    
    /// Compare 2 parametersets
    static func == (lhs: ParameterSet, rhs: ParameterSet) -> Bool {
        return NSDictionary(dictionary: lhs.current).isEqual(to: NSDictionary(dictionary: rhs.current))
    }
    
    //
    // Make ParameterSet conform to Codable. Needs JEncodeDecode
    //
    
    // List elements to be encoded / decoded
    enum CodingKeys : String, CodingKey {
        case current
    }
    
    /// Decode from JSON data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONCodingKeys.self)
        current  = try container.decode(DictAny.self)
        previous = current
        initial  = current
    }
    
    /// Encode to JSON data
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: JSONCodingKeys.self)
        try container.encode(current)
    }
    
    //
    // Implementation of ParameterSet
    //
    
    // Dictionaries containing parameter values
    var current: DictAny
    var previous: DictAny
    var initial: DictAny
    
    /// Convert parameters to JSON
    var jsonString: String {
        do {
            let s = try JSONEncoder().encode(self)
            return String(data: s, encoding: .utf8) ?? ""
        }
        catch {
            return ""
        }
    }
    
    /// Convert JSON string to parameterset (DictAny)
    mutating func fromJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        do {
            self = try JSONDecoder().decode(ParameterSet.self, from: data)
            return true
        }
        catch {
            return false
        }
    }
    
    /// Initialize parameter set with dictionary of type DictPar
    init(_ initialSettings: DictAny = [:]) {
        current  = initialSettings
        previous = initialSettings
        initial  = initialSettings
    }
    
    /// Add dictionary of type DictPar with new settings to parameter set
    mutating func addSettings(_ initialSettings: DictAny) {
        current.merge(initialSettings)  { (_, new) in new }
        previous.merge(initialSettings) { (_, new) in new }
        initial.merge(initialSettings)  { (_, new) in new }
    }
    
    /// Set parameter or parameter set to initial settings
    mutating func reset(_ path: String?) {
        if let path = path {
            current[path] = initial[path]
        }
        else {
            current = initial
        }
    }
    
    /// Set parameter or parameterset to previuos settings
    mutating func undo(_ path: String?) {
        if let path = path {
            current[path] = previous[path]
        }
        else {
            current = previous
        }
    }
    
    /// Set previous settings of parameter or parameterset to current settings
    mutating func apply(_ path: String?) {
        if let path = path {
            previous[path] = current[path]
        }
        else {
            previous = current
        }
    }

    /// Get or set parameter value identified by path string subscript
    subscript<T>(path: String, default def: T? = nil) -> T where T: Castable {
        get {
            let defValue: T = def ?? T.defaultValue
            print("  ParameterSet subscript get \(path) default \(defValue)")

            if current.pathExists(path) {
                // Path exists => return current value
                return current[path: path, default: defValue]
            }
            else {
                // Path doesn't exist => return initial value
                return initial[path: path, default: defValue]
            }
        }
        set {
            print("  ParameterSet subscript set \(path) \(newValue)")
            if current.pathExists(path) {
                // Path exists, save current value to previous dictionary
                previous[path: path] = current[path: path, default: T.defaultValue]
                current[path: path] = newValue
            }
            else {
                current[path: path]  = newValue
                previous[path: path] = newValue
                initial[path: path]  = newValue
            }
        }
    }
    
}
