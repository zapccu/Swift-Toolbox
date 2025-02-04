//
//  ParameterSet.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//

//
// ParameterSet structure
//
// A ParameterSet is an array of 3 dictionaries which can be used to manage
// application parameters. The dictionaries are of type <String, Any> / DictPar
//
//   .current - Dictionary with current parameter values. When a parameter
//      value is changed in this dictionary, the old value is stored in
//      dictionary .previous
//
//   .previous - Dictionary with previous parameter values. After initialization
//      of a parameter set values of .current and .previous are identical
//
//   .initial - Dictionary with initial values
//
//  *** Data type of an element must be conform to protocol Castable! ***
//
// Methods:
//
//   reset(_ path: String?) - Reset a parameter or the whole parameter set
//      to it's initial value(s)
//
//   apply(_ path: String?) - Copy a parameter or the whole parameter set
//      from .current to .previous
//
//   undo(_ path: String?) - Copy a parameter or the whole parameter set
//      from .previous to .current
//
//   addSettings(_ initialValues: DictPar) - Add new parameters to parameter set.
//      New parameters are merged with dictionaries .current, .previous, .initial
//
//   get<T>(_ path: String, default: T = nil) - Return parameter value
//
//   set<T>(_ path: String, value: T) - Create or update a parameter value
//
// Accessing parameter values by subscripts:
//
//   let value: T = parameterSet[path: String, default: T? = nil]
//
// Reading a parameter value will never return nil. If no default value is
// specified, the default value of the destination type is returned (i.e. 0 or "0").
//
//   parameterSet[path: String] = newValue
//
// If an element exists, newValue is casted to the type of the element.
// If an element doesn't exist, a new element with type of newValue is created.
//

import Foundation

struct ParameterSet : Castable {
    
    // Default value is an empty parameterset
    static var defaultValue: ParameterSet {
        return ParameterSet([:])
    }
    
    /// Check if value is castable to ParameterSet
    static func isCastable<T>(_ value: T) -> Bool {
        return value is ParameterSet
    }
    
    /// A castable type cannot be casted to type ParameterSet.
    /// If T is not of type ParameterSet, the default value (empty ParameterSet) is returned
    static func cast<T>(_ value: T) -> (any Castable) where T : Castable {
        if let v = value as? ParameterSet {
            return v
        }
        
        return defaultValue
    }
    
    /// Compare 2 parametersets
    static func == (lhs: ParameterSet, rhs: ParameterSet) -> Bool {
        return NSDictionary(dictionary: lhs.current).isEqual(to: NSDictionary(dictionary: rhs.current))
    }
    
    /// Compare current parameterset with a castable value
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? ParameterSet {
            return self == v
        }
        
        return false
    }
    
    // Dictionaries containing parameter values
    var current: DictAny
    var previous: DictAny
    var initial: DictAny
    
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

    /// Return parameter value
    ///
    /// path - Hierarchical dictionary key. Keys/subkeys are separated by '.'
    ///
    /// default - Value to be returned if key doesn't exist or value is nil.
    ///    If default is nil, the default value of the destination data type
    ///    is returned. Returned value is never nil!
    ///
    func get<T>(_ path: String, default def: T = T.defaultValue) -> T where T: Castable {
        print("  ParameterSet get \(path) default \(def)")
        /*
        if let val = anyDict[keyPath: path, default: def] {
            if let cval = val as? any Castable {
                return T.cast(cval) as! T
            }
        }
         */
        // Split path into segments
        let segs = path.components(separatedBy: ".")
        
        // Empty path is not allowed
        guard segs.count > 0 && segs[0] != "" else { return def }
        
        if current.keys.contains(segs[0]) {
            // First segment key exists
            if segs.count == 1 {
                // Last/only one segment. Return element value
                return current[path: segs[0], default: def]
            }
            else {
                // More than 1 segment left in path
                if let v = current[segs[0]] as? ParameterSet {
                    // If element of first segment is a ParameterSet, recursively call get() with rest of path
                    let newPath = segs.dropFirst().joined(separator: ".")
                    return v.get(newPath, default: def)
                }
                else {
                    // Other types (i.e. sub-dictionaries) are not yet supported
                    return def
                }
            }
        }
        
        return def
    }

    /// Set parameter value
    ///
    /// path - Hierarchical dictionary key. Keys/subkeys are separated by '.'
    ///    Each segment of the path except of the last one must exist.
    /// value - New parameter value. If path exists, value is casted to the
    ///    type of the existing element. Otherwise a new element is created.
    ///
    /// Example: Create and access a hierarchical paramterset
    ///
    /// let parset = ParameterSet(["a": 1, "b:" 0])
    ///
    /// This won't work: parset.set("c.x", 10)
    ///
    /// The sub-parameterset must exist before it can be accessed. So first
    /// we need to add the new sub-parameterset as element "c":
    ///
    /// parset.set("c", ParameterSet(["x": 10, "y": 20])
    ///
    /// Now we can change element "x" of sub-parameterset "c":
    ///
    /// parset.set("c.x", 100)
    ///
    /// Or we can add new elements to sub-parameterset "c":
    ///
    /// parset.set("c.z", 300)
    ///
    mutating func set<T>(_ path: String, _ value: T) where T: Castable {
        print("  ParameterSet set \(path) \(value)")
        
        // Split path into segments
        let segs = path.components(separatedBy: ".")

        // Empty path is not allowed
        guard segs.count > 0 && segs[0] != "" else { return }
        
        if segs.count == 1 {
            // Last segment
            if current.keys.contains(segs[0]) {
                // Save current value and set element to new value by using DictPar subscript
                previous[segs[0]] = current[segs[0]]
                current[path: segs[0]] = value
            }
            else {
                // Add a new parameter
                previous[segs[0]] = value
                current[segs[0]]  = value
                initial[segs[0]]  = value
            }
        }
        else {
            // More than 1 segment left in path
            if current.keys.contains(segs[0]) {
                // First segment key exists
                if var v = current[segs[0]] as? ParameterSet {
                    // If element of first segment is a ParameterSet, recursively call set() with rest of path
                    let newPath = segs.dropFirst().joined(separator: ".")
                    v.set(newPath, value)
                    current[segs[0]] = v
                }
                else {
                    // If number of segements is > 1, the element of the first segment key must be ParameterSet
                    return
                }
            }
            else {
                // First segment key doesn't exist. Create an empty ParameterSet value and assign it to segs[0]
                let newPath = segs.dropFirst().joined(separator: ".")
                var ps = ParameterSet()
                ps.set(newPath, value)
                current[segs[0]] = ps
            }
        }
    }
    
    /// Get or set parameter value identified by path string subscript
    subscript<T>(path: String, default def: T) -> T where T: Castable {
        get {
            print("  ParameterSet subscript get \(path) default \(def)")
            return current[path: path, default: def]
        }
        set {
            print("  ParameterSet subscript set \(path) \(newValue)")
            if current.pathExists(path) {
                previous[path: path] = current[path: path, default: def]
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
