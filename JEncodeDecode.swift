//
//  JEncodeDecode.swift
//  Toolbox-Demo
//
//  Created by Dirk Braner on 07.02.25.
//
//  Adapted from:
//
//  Original: https://gist.github.com/loudmouth/332e8d89d8de2c1eaf81875cfcd22e24
//  Adds encoding: https://github.com/3D4Medical/glTFSceneKit/blob/master/Sources/glTFSceneKit/GLTF/JSONCodingKeys.swift
//  Adds fix for null inside arrays causing infinite loop: https://gist.github.com/loudmouth/332e8d89d8de2c1eaf81875cfcd22e24#gistcomment-2807855
//


// --------------------------------------------------------
//  JSONCodingKeys
// --------------------------------------------------------

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

// --------------------------------------------------------
//  Decoding
// --------------------------------------------------------

//
// Extend KeyedDecodingContainer (dictionaries)
//

extension KeyedDecodingContainer {
    
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()
        
        for key in allKeys {
            print("KeyedDecodingContainer decode \(key.stringValue)")
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                print("KeyedDecodingContainer decode nestedDictionary \(key.stringValue)")
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

//
// Extend UnkeyedDecondigContainer (arrays)
//

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        
        while isAtEnd == false {
            let value: String? = try decode(String?.self)
            if value == nil {
                continue
            }
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

//
// Encoding
//

extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    
    mutating func encode(_ value: [String: Any]) throws {
        try value.forEach({ (key, value) in
            print("KeyedEncodingContainerProtocol JSONCodingKeys encode [String : Any], key = \(key), value = \(value), type = \(type(of: value))")
            let key = JSONCodingKeys(stringValue: key)
            switch value {
            case let value as any Codable:
                print("  type = any codable")
                try encode(value, forKey: key)
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as Float:
                try encode(value, forKey: key)
            case let value as [String: Any]:
                try encode(value, forKey: key)
            case let value as [Any]:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                print("  encode [String : Any], type not supported")
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        })
    }
}

extension KeyedEncodingContainerProtocol {
    
    mutating func encode(_ value: [String: Any]?, forKey key: Key) throws {
        print("KeyedEncodingContainerProtocol encode [String : Any]?, type = \(type(of: value))")
        if value != nil {
            var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
            try container.encode(value!)
        }
    }
    
    mutating func encode(_ value: [Any]?, forKey key: Key) throws {
        print("encode [Any]?, type = \(type(of: value))")
        if value != nil {
            var container = self.nestedUnkeyedContainer(forKey: key)
            try container.encode(value!)
        }
    }
}

extension UnkeyedEncodingContainer {
    
    mutating func encode(_ value: [Any]) throws {
        print("encode [Any], type = \(type(of: value))")
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as Float:
                try encode(value)
            case let value as [String: Any]:
                try encode(value)
            case let value as [Any]:
                try encode(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                print("UnkeyedEncodingContainer encode [Any], type not supported")
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }
    
    mutating func encode(_ value: [String: Any]) throws {
        print("encode Dictionary")
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encode(value)
    }
}
