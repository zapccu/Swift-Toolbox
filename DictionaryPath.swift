//
//  DictionaryPath.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//

typealias DictAny = Dictionary<String,Any>

//
// Extend Dictionaries of type <String,Any> by subscript parameter "path".
// A path allows read and write access to a Dictionary hierarchy.
// A path is a string where the segments are seperated by a ".".
//
// Example:
//
// let myDict = [
//    "a": 1, "b": 2,
//    "c:" [
//       "d:" 3
//    ]
//
// let x = myDict["c.d"]!
// myDict["c.d"] = 10
//

extension Dictionary<String, Any> {

    /// Check if path exists
    func pathExists(_ path: String) -> Bool {
        // Split path into segments
        let seg = path.components(separatedBy: ".")
        
        // Prevent an empty key
        guard seg.count > 0 else { return false }
        
        if let element = self[seg[0]] {
            if element is DictAny {
                let newDict = element as! DictAny
                let newPath = seg.dropFirst().joined(separator: ".")
                return newDict.pathExists(newPath)
            }
            else if seg.count == 1 {
                return true
            }
        }
        
        return false
    }
    
    /// Get or set value identified by path
    subscript(_ path: String, _ defaultValue: Any? = nil) -> Any? {
        get {
            let seg = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard seg.count > 0 else { return nil }
            
            if seg.count == 1 {
                return self[seg[0], default: defaultValue!]
            }

            if let element = self[seg[0]] {
                if element is DictAny {
                    // Element is a dictionary
                    // Recursively call subscript with child dictionary and remanining path
                    let newDict = element as! DictAny
                    let newPath = seg.dropFirst().joined(separator: ".")
                    return newDict[newPath, defaultValue]
                }
            }
            
            return defaultValue
        }
        set {
            let seg = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard seg.count > 0 else { return }
            
            if seg.count == 1 {
                // Reached last element in path
                self[seg[0]] = newValue
            }
            else {
                // Recursively call subscript assignment with remaining path
                var dict: DictAny = self[seg[0]] == nil ? [:] : self[seg[0]] as! DictAny
                let newPath = seg.dropFirst().joined(separator: ".")
                dict[newPath] = newValue
                self[seg[0]] = dict
            }
        }
    }
}


