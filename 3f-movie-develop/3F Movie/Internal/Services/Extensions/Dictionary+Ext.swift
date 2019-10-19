//
//  Dictionary+Ext.swift
//  3F Movie
//
//  Created by stud on 14/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

extension Dictionary where Value == [Movie], Key == Int {
    
    func safelyGetElementFrom(key: Int, at indexPath: IndexPath) -> Movie? {
        guard let valueForKey = self[key], valueForKey.count > indexPath.row else { return nil }
        return valueForKey[indexPath.row]
    }
    
}
