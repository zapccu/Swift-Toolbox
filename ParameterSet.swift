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
//   let value: Type = parameterSet(_ path: String, _ defaultValue: Any? = nil]
//
// Writing parameter values:
//
//   parameterSet[_ path: String] = newValue
//

struct ParameterSet {
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
    subscript(_ mode: AccessMode) -> DictPar {
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
    subscript(_ path: String, _ defaultValue: Any? = nil) -> Any? {
        get {
            if self[.current].keys.contains(path) {
                return self[.current][path]
            }
            else {
                return defaultValue
            }
        }
        set {
            if self[.current].keys.contains(path) {
                // Modify existing parameter
                self[.previous][path] = self[.current][path]
                self[.current][path]  = newValue
            }
            else {
                // Add new parameter
                self[.previous][path] = newValue
                self[.current][path]  = newValue
                self[.initial][path]  = newValue
            }
        }
    }

}
