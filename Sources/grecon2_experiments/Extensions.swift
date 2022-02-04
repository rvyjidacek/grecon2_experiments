//
//  Extensions.swift
//
//
//  Created by Roman Vyjídáček on 18/02/2020.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

