//
//  Doule+RoundTo.swift
//  Snacktacular
//
//  Created by 18ericz on 4/15/19.
//  Copyright © 2019 Eric Zhou. All rights reserved.
//

import Foundation

extension Double {
    func roundTo(places: Int) -> Double {
        let tenToPower = pow(10.0,Double((places >= 0 ? places: 0)))
        let roundedValue = (self*tenToPower).rounded() / tenToPower
        return roundedValue
    }
}
