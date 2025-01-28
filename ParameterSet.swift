//
//  ParameterSet.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//
//  Requires DictionaryPath
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

struct ParameterSet : Castable {
    
    // Default value is an empty parameterset
    static var defaultValue: ParameterSet {
        return ParameterSet([:])
    }
    
    // A castable type cannot be casted to type ParameterSet.
    // If T is not of type ParameterSet, the default value is returned
    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
        if let v = value as? ParameterSet {
            return v
        }
        
        return defaultValue
    }
    
    // Compare 2 parametersets
    static func == (lhs: ParameterSet, rhs: ParameterSet) -> Bool {
        return lhs.settings[AccessMode.current.rawValue] == rhs.settings[AccessMode.current.rawValue]
    }
    
    // Compare current parameterset with a castable value
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? ParameterSet {
            return self == v
        }
        
        return false
    }
    
    enum AccessMode: Int {
        case current  = 0   // Parameterset with current values
        case previous = 1   // Parameterset with previous values
        case initial  = 2   // Parameterset with initial values
    }
    
    // Number of dictionaries (for future enhancements)
    static let numSettings: Int = 3
    
    // Array with dictionaries .current, .previous, .initial
    var settings: [DictPar]
    
    /// Initialize parameter set with dictionary of type DictPar
    init(_ initialSettings: DictPar = [:]) {
        settings = Array(repeating: initialSettings, count: ParameterSet.numSettings)
    }

    /// Direct access to a dictionary via AccessMode subscript
    subscript(mode: AccessMode) -> DictPar {
        get {
            return settings[mode.rawValue]
        }
        set {
            settings[mode.rawValue] = newValue
        }
    }
    
    /// Add dictionary of type DictPar with new settings to parameter set
    mutating func addSettings(_ initialSettings: DictPar) {
        for i in 0..<ParameterSet.numSettings {
            settings[i].merge(initialSettings) { (_, new) in new }
        }
    }
    
    /// Set parameter or parameter set to initial settings
    mutating func reset(_ path: String?) {
        if let path = path {
            self[.current][path] = self[.initial][path]
        }
        else {
            self[.current] = self[.initial]
        }
    }
    
    /// Set parameter or parameterset to previuos settings
    mutating func undo(_ path: String?) {
        if let path = path {
            self[.current][path] = self[.previous][path]
        }
        else {
            self[.current] = self[.previous]
        }
    }
    
    /// Set previous settings of parameter or parameterset to current settings
    mutating func apply(_ path: String?) {
        if let path = path {
            self[.previous][path] = self[.current][path]
        }
        else {
            self[.previous] = self[.current]
        }
    }

    /// Return parameter value
    ///
    /// path - Hierarchical dictionary key. Keys/subkeys are separated by '.'
    /// default - Value to be returned if key doesn't exist or value is nil.
    ///    If default is nil, the default value of the destination data type
    ///    is returned. Returned value is never nil!
    ///
    func get<T>(_ path: String, default def: T? = nil) -> T where T: Castable {
        // Split path into segments
        let segs = path.components(separatedBy: ".")
        
        if segs.count == 1 {
            return self[.current][path, default: def]
        }
        else if segs.count == 0 {
            return self[.current]["", default: def]
        }
        
        if let v = self[.current][segs[0]] as? ParameterSet {
            // Recursively call get() with rest of path
            let newPath = segs.dropFirst().joined(separator: ".")
            return v.get(newPath, default: def)
        }
        else {
            // Ignore everything after fist segment
            return self[.current][segs[0], default: def]
        }
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
        // Split path into segments
        let segs = path.components(separatedBy: ".")

        guard segs.count > 0 else { return }
        
        if segs.count == 1 {
            if self[.current].keys.contains(path) {
                // Save current value and set element to new value
                self[.previous][path] = self[.current][path]
                self[.current][path]  = value
            }
            else {
                // Add a new parameter
                self[.previous][path] = value
                self[.current][path]  = value
                self[.initial][path]  = value
            }
        }
        else if var v = self[.current][segs[0]] as? ParameterSet {
                // Recursively call set() with rest of path
                let newPath = segs.dropFirst().joined(separator: ".")
                v.set(newPath, value)
        }
        else {
            return
        }
    }
    
    /// Get or set parameter value identified by path string subscript
    subscript<T>(path: String, default def: T? = nil) -> T where T: Castable {
        get {
           return self[.current][path, default: def]
        }
        set {
            if self[.current].keys.contains(path) {
                // Save current value and set element to new value
                self[.previous][path] = self[.current][path]
                self[.current][path]  = newValue
            }
            else {
                // Add a new parameter
                self[.previous][path] = newValue
                self[.current][path]  = newValue
                self[.initial][path]  = newValue
            }
        }
    }

}
