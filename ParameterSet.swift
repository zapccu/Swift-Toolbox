//
//  ParameterSet.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//
//  Requires DictionaryPath
//


struct ParameterSet {

    static let current: Int = 0
    static let previous: Int = 1
    static let initial: Int = 2
    
    static let numSettings: Int = 3
    
    var settings: [DictPar]
    
    // Initialize parameter set
    init(_ initialSettings: DictPar) {
        settings = Array(repeating: initialSettings, count: ParameterSet.numSettings)
    }
    
    // Add new settings
    mutating func addSettings(_ initialSettings: DictPar) {
        for i in 0..<ParameterSet.numSettings {
            settings[i].merge(initialSettings) { (_, new) in new }
        }
    }
    
    // Set parameter or parameterset to initial settings
    mutating func reset(_ path: String?) {
        if let path = path {
            settings[ParameterSet.current][path: path] = settings[ParameterSet.initial][path: path]
        }
        else {
            settings[ParameterSet.current] = settings[ParameterSet.initial]
        }
    }
    
    // Set parameter or parameterset to previuos settings
    mutating func undo(_ path: String?) {
        if let path = path {
            settings[ParameterSet.current][path: path] = settings[ParameterSet.previous][path: path]
        }
        else {
            settings[ParameterSet.current] = settings[ParameterSet.previous]
        }
    }
    
    // Set previous settings of parameter or parameterset to current settings
    mutating func apply(_ path: String?) {
        if let path = path {
            settings[ParameterSet.previous][path: path] = settings[ParameterSet.current][path: path]
        }
        else {
            settings[ParameterSet.previous] = settings[ParameterSet.current]
        }
    }
    
    // Return parameter value identified by key string
    func get<T>(_ key: String, _ mode: Int = current, _ defaultValue: T? = nil) -> T? {
        let result = settings[ParameterSet.current][key]
        if result == nil {
            if let value = settings[ParameterSet.initial][key] {
                return value as? T
            }
            else {
                return defaultValue
            }
        }
        else if result is DictPar {
            return ParameterSet(result as! DictPar) as? T
        }
        
        return result as? T
    }
    
    // Get parameter value identified by path string
    func get<T>(path: String, _ mode: Int = current, _ defaultValue: T? = nil) -> T? {
        let result = settings[ParameterSet.current][path: path]
        if result == nil {
            if let value = settings[ParameterSet.initial][path: path] {
                return value as? T
            }
            else {
                return defaultValue
            }
        }
        else if result is DictPar {
            return ParameterSet(result as! DictPar) as? T
        }
        
        return result as? T
    }
    
    // Get or set parameter value identified by key string subscript
    subscript<T>(_ key: String) -> T? {
        get {
            return get(key)
        }
        set {
            settings[ParameterSet.previous][key] = settings[ParameterSet.current][key]
            settings[ParameterSet.current][key] = newValue
        }
    }

    // Get or set parameter value identified by path string subscript
    subscript<T>(path path: String) -> T? {
        get {
            return get(path: path)
        }
        set {
            settings[ParameterSet.previous][path: path] = settings[ParameterSet.current][path: path]
            settings[ParameterSet.current][path: path] = newValue
        }
    }
    
    /*
    static func += (lhs: inout ParameterSet, rhs: ParameterSet) {
        lhs.currentSettings.merge(rhs.currentSettings) { (_, new) in new }
    }
    
    static func += (lhs: inout ParameterSet, rhs: DictPar) {
        lhs.currentSettings.merge(rhs) { (_, new) in new }
    }
     */
}
