//
//  Array+Ext.swift
//  3F Movie
//
//  Created by stud on 14/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

extension Array where Element == Movie {
    
    func safelyGetElementAt(_ indexPath: IndexPath) -> Movie? {
        guard self.count > indexPath.row else { return nil }
        return self[indexPath.row]
    }
    
}
