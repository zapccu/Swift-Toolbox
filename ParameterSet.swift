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
// Reading parameter values:
//
//   let value: Type = parameterSet[_: String, default: Type? = nil]
//
// Reading a parameter value will never return nil. If no default value is
// specified, the default value of the destination type is returned (0 or "0").
//
// Writing parameter values:
//
//   parameterSet[_: String] = newValue
//
// If an element exists, newValue is casted to type of element.
// If an element doesn't exist, a new element with type of newValue is created.
//

struct ParameterSet : Castable {
    
    static var defaultValue: ParameterSet {
        return ParameterSet([:])
    }
    
    static func cast<T>(_ value: T) -> (any Castable)? where T : Castable {
        return value
    }
    
    static func == (lhs: ParameterSet, rhs: ParameterSet) -> Bool {
        return lhs.settings[AccessMode.current.rawValue] == rhs.settings[AccessMode.current.rawValue]
    }
    
    func compareWith<T>(_ value: T) -> Bool where T: Castable {
        if let v = value as? ParameterSet {
            return self == v
        }
        
        return false
    }
    
    enum AccessMode: Int {
        case current  = 0
        case previous = 1
        case initial  = 2
    }
    
    static let numSettings: Int = 3
    
    /// Array with dictionaries "current", "previous", "initial"
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
    
    /// Add dictionary of type DictPar  with new settings to parameter set
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
