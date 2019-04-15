//
//  Spots.swift
//  Snacktacular
//
//  Created by 18ericz on 3/31/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase


class Spots{
    var spotArray = [Spot]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    
}
