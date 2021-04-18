//
//  Codable+Extensions.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.04.2021.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Decodable {
    
    init?(jsonDictionary: [String: Any]?) throws {
        guard let jsonDictionary = jsonDictionary else {
            return nil
        }
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
}
