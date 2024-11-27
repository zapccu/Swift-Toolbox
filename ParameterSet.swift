//
//  ParameterSet.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//
//  Requires DictionaryPath
//


struct ParameterSet {
    enum AccessMode: Int {
        case current = 0
        case previous = 1
        case initial = 2
    }
    
    static let numSettings: Int = 3
    
    /// Array with dictionaries "current", "previous", "initial"
    var settings: [DictPar]
    
    /// Initialize parameter set with dictionary of type DictPar = <String>,<Any>
    init(_ initialSettings: DictPar = [:]) {
        settings = Array(repeating: initialSettings, count: ParameterSet.numSettings)
    }

    /// Direct access to dictionary
    subscript(_ mode: AccessMode) -> DictPar {
        get {
            return settings[mode.rawValue]
        }
        set {
            settings[mode.rawValue] = newValue
        }
    }
    
    /// Add dictionary of type DictPar = <String>,<Any> with new settings to parameter set
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
        
    /// Get parameter value identified by path string
    func get(_ path: String, _ defaultValue: Any? = nil, _ mode: AccessMode = .current) -> Any? {
        return self[mode][path, defaultValue]
    }

    /// Get or set parameter value identified by path string subscript
    subscript(_ path: String, _ defaultValue: Any? = nil) -> Any? {
        get {
            return get(path, defaultValue, .current)
        }
        set {
            self[.previous][path] = self[.current][path]
            self[.current][path] = newValue
        }
    }

}
