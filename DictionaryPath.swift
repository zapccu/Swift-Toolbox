//
//  DictionaryPath.swift
//  Swift-Toolbox
//
//  Created by Dirk Braner on 24.11.24.
//

typealias DictPar = Dictionary<String,Any>

/*
 *  Extend Dictionaries of type <String,Any> by subscript parameter "path".
 *  A path allows read and write access to a Dictionary hierarchy.
 *  A path is a string where the segments are seperated by a ".".
 *
 *  Example:
 *
 *    let myDict = [
 *      "a": 1, "b": 2,
 *      "c:" [
 *        "d:" 3
 *      ]
 *
 *    let x = myDict[path: "c.d"]!
 *    myDict[path: "c.d"] = 10
 */

extension Dictionary where Key == String, Value == Any {

    // Check if path exists
    func pathExists(_ path: String) -> Bool {
        let seg = path.components(separatedBy: ".")
        
        // Prevent an empty key
        guard seg.count > 0 else { return false }
        
        if let element = self[seg[0]] {
            if element is DictPar {
                let newDict = element as! DictPar
                let newPath = seg.dropFirst().joined(separator: ".")
                return newDict.pathExists(newPath)
            }
            else if seg.count == 1 {
                return true
            }
        }
        
        return false
    }
    
    // Get or set value identified by path
    subscript(path path: String) -> Any? {
        get {
            let seg = path.components(separatedBy: ".")
            
            // Prevent an empty key
            guard seg.count > 0 else { return nil }
            
            if let element = self[seg[0]] {
                if element is DictPar {
                    // Element is a dictionary
                    // Recursively call subscript with child dictionary and remanining path
                    let newDict = element as! DictPar
                    let newPath = seg.dropFirst().joined(separator: ".")
                    return newDict[path: newPath]
                }
                else if seg.count == 1 {
                    // Element is a value
                    return element
                }
                else {
                    return nil
                }
            }
            else {
                // Element has no value or doesn't exist
                return nil
            }
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
                var dict: DictPar = self[seg[0]] == nil ? [:] : self[seg[0]] as! DictPar
                let newPath = seg.dropFirst().joined(separator: ".")
                dict[path: newPath] = newValue
                self[seg[0]] = dict
            }
        }
    }
}
