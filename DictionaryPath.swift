//
//  DictionaryPath.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//

//
// Extend Dictionaries of type <String,Any> to support direct access to
// dictionary hierarchies by specifying a path.
//
// A path is a string where the segments (representing the dictionary levels) are
// seperated by a ".".
//
// Example:
//
// var myDict = [
//    "a": 1,
//    "b": 2,
//    "c:" [
//       "d:" 3
//    ]
//
// let x: Int = myDict[path: "c.d", default: 0]         // Read a castable Int value
// let y: Double = myDict[path: "c.d", default: 0.0]    // Read an Int value and cast it to Double
//
// myDict[path: "c.d"] = 10                             // Assign Int
// myDict[path: "c.d"] = Complex(1.0)                   // Will fail if Complex is not castable
//
// myDict[path: "c.e"] = 1.5                            // Create a new entry of type Double
//
// if let a = myDict[keyPath: "a"] { ... }              // Read value of type Any?
//

import Foundation

typealias DictAny = [String: Any]

extension Dictionary where Key == String {
    
    /// Get or set a castable value identified by parameter path
    ///
    /// Getting a value for a non existing element returns ...
    ///    ... default if parameter default is specified
    ///    ... default of type T if no default is specified or value cannot be casted to type T
    ///
    /// Setting a value fails if type of a sub-dictionary element is not DictAny or if element
    /// exists but new value cannot be casted to type of existing element
    ///
    /*
    subscript<T>(path path: String, default def: T = T.defaultValue) -> T where T: Castable {
        get {
            if let v = self[keyPath: path] as? any Castable {
                return T.cast(v) as! T
            }
            
            return def
        }
        set {
            if let v = self[keyPath: path] as? any Castable {
                // Element exists and value is castable
                let t = type(of: v)
                if t.isCastable(newValue) {
                    self[keyPath: path] = t.cast(newValue)
                }
            }
            else if !self.keys.contains(path) {
                // Element doesn't exist. Create a new entry
                self[keyPath: path] = newValue
            }
        }
    }
     */
    
    /// Compare 2 dictionaries
    static func == (lhs: DictAny, rhs: DictAny) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: NSDictionary(dictionary: rhs))
    }
    
    /// Check if path exists
    func pathExists(_ path: String) -> Bool {
        let segs = path.components(separatedBy: ".")
        
        guard segs.count > 0 && segs[0] != "" else { return false }

        if segs.count == 1 {
            return self.keys.contains(Key(segs[0]))
        }
        else if let subDict = self[segs[0]] as? DictAny {
            let newPath = segs.dropFirst().joined(separator: ".")
            return subDict.pathExists(newPath)
        }
        
        return false
    }
    
    /// Get or set value of type Any identified by parameter keyPath
    ///
    /// Getting a value return nil if element doesn't exist and no default is specified
    /// Setting a value fails if type of a sub-dictionary element is not DictAny
    ///
    subscript(keyPath keyPath: String, default def: Any? = nil) -> Any? {
        get {
            let segs = keyPath.components(separatedBy: ".")
            
            // Prevent an empty key
            guard segs.count > 0 && segs[0] != "" && self.keys.contains(segs[0]) else { return def }
            
            let key = Key(segs[0])
            if segs.count == 1 {
                return self[key] ?? def
            }
            else if let subDict = self[key] as? DictAny {
                let newPath = segs.dropFirst().joined(separator: ".")
                return subDict[keyPath: newPath, default: def]
            }

            return def
        }
        set {
            let segs = keyPath.components(separatedBy: ".")
            
            // Prevent an empty key
            guard segs.count > 0 && segs[0] != "" else { return }
            
            let key = Key(segs[0])
            
            if segs.count == 1 {
                // Reached last element in path
                self[key] = newValue as? Value
            }
            else {
                let newPath = segs.dropFirst().joined(separator: ".")
                if self.keys.contains(key) {
                    if var subDict = self[key] as? DictAny {
                        subDict[keyPath: newPath] = newValue
                        self[key] = subDict as? Value
                    }
                    else {
                        return
                    }
                }
                else {
                    var subDict: [Key: Any] = [:]
                    subDict[keyPath: newPath] = newValue
                    self[key] = subDict as? Value
                }
            }
        }
    }
}


