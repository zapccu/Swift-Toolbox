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
// ParameterSet structure
//
// A ParameterSet contains 3 dictionaries for current, previous and initial
// parameter values which can be used to manage application parameters.
// The dictionaries are of type <String, Any> / type alias DictAny.
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
//   mergeSettings(_ initialValues: DictPar) - Add new parameters to parameterset.
//      New parameters are merged with dictionaries .current, .previous, .initial
//
//   addSetting(_ path: String, setting: T) - Add new parameter to parameterset.
//      Existing parameter is replaced by the new one.
//
//   deleteSetting(_ path: String) - Delete a parameter from parameterset.
//
// Parameter values can be read or set by using subscripts.
//
// Reading parameter values
//
// Example:
//
//   let value: T = parameterSet[path: String, default: T? = nil]
//
// Reading a parameter value will never return nil. If no default value is
// specified (default is nil) and path exists but parameter doesn't exist, the
// initial value of a parameter is returned.
// If the path doesn't exist, the default value of the castable type is returned.
//
// Setting parameter values
//
// Example:
//
//   parameterSet[path: String] = newValue
//
// If an element exists and newValue is castable to the type of the element,
// newValue is assigned to the element. If newValue is not castable to the type
// of an existing element, nothing happens.
// If an element doesn't exist, assignment fails.
//

struct ParameterSet : Castable, Codable {
    
    //
    // Make ParameterSet conform to protocol Castable
    //
    
    // Default value is an empty parameterset
    static var defaultValue: ParameterSet { ParameterSet([:]) }
    
    /// Check if value is castable to ParameterSet
    static func isCastable<T>(from: T) -> Bool {
        return from is ParameterSet || from is DictAny
    }
    
    /// Cast to ParameterSet
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
    // Make ParameterSet conform to protocol Codable. Needs JEncodeDecode
    //
    
    // List elements to be encoded / decoded
    enum CodingKeys : String, CodingKey {
        case current
    }
    
    /// Create and initialize a new ParameterSet object from JSON data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONCodingKeys.self)
        initial = try container.decode(DictAny.self)
        current = initial
        previous = initial
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
    var current: DictAny = [:]        // Current values
    var previous: DictAny = [:]       // Previous values
    var initial: DictAny = [:]        // Initial values
    
    /// Convert parameters to JSON. Return empty string on error
    var jsonString: String { return toJSON(prettyPrinted: false) }
    
    /// Cast dictionary elements from specified dictionary to ParameterSet value types.
    /// Elements not existing in current ParameterSet are ignored
    mutating func cast(fromDict: DictAny) {
        for (key, value) in fromDict {
            if initial.pathExists(key) {
                if let d = value as? DictAny {
                    if var e = initial[key] as? DictAny {
                        // If existing element is a dictionary, cast dictionary-value to copy of existing dictionary
                        // Assign casted copy of dictionary to current element
                        e.cast(fromDict: d)
                        current[key] = e
                    }
                    else if var e = initial[key] as? ParameterSet {
                        // If existing element is a ParameterSet, cast dictionary-value to copy of existing ParameterSet
                        // Assign casted copy of ParameterSet to initial element
                        e.cast(fromDict: d)
                        current[key] = e
                    }
                    else {
                        // print("Decode: Ignoring element \(key) with value \(value)")
                    }
                }
                else if let v = value as? any Castable, let e = initial[key] as? any Castable, type(of: e).isCastable(from: v) {
                    // If existing element and source element are castable values, cast source to type of destination element
                    current[key] = type(of: e).cast(from: v)
                }
                else {
                    // print("Decode: Ignoring element \(key) with value \(value)")
                }
            }
            else {
                // print("Decode: Path \(key) does not exist in initial dictionary")
            }
        }
    }
    
    // Convert parameters to (optionally) formatted JSON
    func toJSON(prettyPrinted: Bool = true) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = prettyPrinted ? [.prettyPrinted] : []
            let s = try encoder.encode(self)
            return String(data: s, encoding: .utf8) ?? ""
        }
        catch {
            print(error)
            return ""
        }
    }
    
    /// Convert JSON string to parameterset (DictAny)
    mutating func fromJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        do {
            let newParameterset = try JSONDecoder().decode(ParameterSet.self, from: data)
            previous = current
            cast(fromDict: newParameterset.current)
            return true
        }
        catch {
            print(error)
            return false
        }
    }
    
    /// Initialize parameter set with dictionary of type DictPar
    init(_ initialSettings: DictAny = [:]) {
        current  = initialSettings
        previous = initialSettings
        initial  = initialSettings
    }
    
    /// Initialize parameter set with JSON string
    init(_ jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON string"))
        }
        self = try JSONDecoder().decode(ParameterSet.self, from: data)
    }
    
    /// Add dictionary of type DictPar with new settings to parameter set
    mutating func mergeSettings(_ initialSettings: DictAny) {
        current.merge(initialSettings)  { (_, new) in new }
        previous.merge(initialSettings) { (_, new) in new }
        initial.merge(initialSettings)  { (_, new) in new }
    }
    
    /// Add parameter of a castable type to parameter set
    mutating func addSetting<T: Castable>(_ path: String, _ setting: T) -> Bool {
        if !initial.pathExists(path) {
            initial[path: path]  = setting
            previous[path: path] = setting
            current[path: path]  = setting
            return true
        }
        return false
    }
    
    /// Add sub dictionary of type DictAny to parameter set
    mutating func addSetting(_ path: String, _ setting: DictAny) -> Bool {
        if !initial.pathExists(path) {
            initial[path: path]  = setting
            previous[path: path] = setting
            current[path: path]  = setting
            return true
        }
        return false
    }
    
    /// Delete parameter from parameter set
    mutating func deleteSetting(_ path: String) {
        current.delete(path)
        previous.delete(path)
        initial.delete(path)
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
            if current.pathExists(path) {
                // Path exists, save current value to previous dictionary
                previous[path: path] = current[path: path, default: T.defaultValue]
                current[path: path] = newValue
            }
            else if initial.pathExists(path) {
                current[path: path] = newValue
                previous[path: path] = newValue
            }
            else {
                // Assigning values is only allowed for existing elements
                return
            }
        }
    }
    
}
