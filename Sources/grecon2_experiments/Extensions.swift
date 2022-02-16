//
//  Extensions.swift
//
//
//  Created by Roman Vyjídáček on 18/02/2020.
//

import Foundation
import FcaKit

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension URL {
    
    public var fileName: String? {
        lastPathComponent.split(separator: ".").first?.description
    }
    
}

extension String {
    
    func appendToFile(at path: String) throws {
        let data = (self + "\n").data(using: .utf8)
        try data?.append(fileURL: URL(fileURLWithPath: path))
    }
}


extension Data {
    // https://stackoverflow.com/questions/27327067/append-text-or-data-to-text-file-in-swift
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension FormalConcept {
    
    public func updateValues(coding: String) {
        let sets = coding.components(separatedBy: "-")
        let objectsTuple = bitsetValues(coding: sets[0])
        let attributesTuple = bitsetValues(coding: sets[1])
        
        if self.objects == nil { self.objects = BitSet(size: objectsTuple.size) }
        if self.attributes == nil { self.attributes = BitSet(size: attributesTuple.size) }
        
        self.objects.setBitArrayValues(objectsTuple.values)
        self.attributes.setBitArrayValues(attributesTuple.values)
    }
    
    private func bitsetValues(coding: String) -> (values: [UInt64], size: Int) {
        let setValues = coding.split(separator: ";")
        let bitsetSize = Int(setValues[0])!
        return (setValues[1].split(separator: " ").map { UInt64($0)! } , bitsetSize)
    }
}
