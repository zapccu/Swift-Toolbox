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
    
    /// Convert dictionary to JSON
    /// 
    /// Returns empty String on error
    var jsonString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
              let string = String(data: data, encoding: .utf8)
        else { return "" }
        return string
    }
    
    /// Convert dictionary to JSON string
    var toJSON: String {
        var str = ""
        
        for (k,v) in self {
            if str != "" { str += ",\n\"\(k)\":" }
            
            switch v {
                case let v as DictAny: str += v.toJSON
                case let v as UInt: str += String(v)
                case let v as Int: str += String(v)
                case let v as Float: str += String(v)
                case let v as Double: str += String(v)
                case let v as String: str += "\"\(v)\""
                default: break
            }
        }
        
        return "{\n\(str)\n}"
    }

    /// Create dictionary from JSON string
    ///
    /// Creates an empty dictionary if input string is not convertible
    init(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            self = [:]
            return
        }
        do {
            self = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Value]
        }
        catch {
            self = [:]
        }
    }

}

func expect<T,C>(_ value: T, _ current: C, _ varname: String) where T: Equatable, C: Equatable {
    if (T.self == C.self) {
        if current as! T != value {
            print("ERR: Expected value \(value) for \(varname), but got \(current)")
        }
        else {
            print("OK: \(varname) = \(current), type = \(type(of: current))")
        }
    }
    else {
        print("ERR: Expected type \(T.self) for \(varname), but got \(C.self)")
    }
}
