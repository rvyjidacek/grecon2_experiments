//
//  Benchmarks.swift
//  
//
//  Created by Roman Vyjídáček on 01.02.2022.
//

import Foundation
import FcaKit

public func compareGreConAndGreConDCoverage() throws {
    
    for url in try FileManager.default.getUrls() {
        let context = try FormalContext(url: url)
        let factors1: [FormalConcept] = try loadFactorisation(algorithm: .greCon, dataset: url.lastPathComponent)
        let factors2: [FormalConcept] = try loadFactorisation(algorithm: .greConD, dataset: url.lastPathComponent)
        let alg1 = GreCon()
        let alg2 = GreConD()
        
        let iterationCount = min(factors1.count, factors2.count)
        let tuples: [(alg: BMFAlgorithm, factors: [FormalConcept])] = [(alg: alg1, factors: factors1), (alg: alg2, factors: factors2)]
        
        var fileContent = ""
        
        for tuple in tuples {
            let uncovered = CartesianProduct(context: context)
            var totalCover = 0
            
            fileContent += "\(tuple.alg.name);0"
            for i in 0..<iterationCount {
                let cover = tuple.factors[i].cartesianProduct.intersected(uncovered)
                totalCover += cover.count
                fileContent += ";\(totalCover)"
                
                for t in cover {
                    uncovered.remove(t)
                }
            }
            fileContent += "\n"
        }
        let dataset = url.lastPathComponent.replacingOccurrences(of: ".fimi", with: "")
        
        try FileManager.default.saveResult(folder: [.greconGreConDCoverageCmp],
                                           filename: dataset,
                                           content: fileContent)
    }
}

public func timeBenchmark() throws {
    var fileContent = "\\begin{tabular}{|l|c|c|c|}\n\\hline\n"
    fileContent += "Dataset & GreCon & GreCon2 & GreConD \\\\ \n \\hline\n"
    
    for url in try FileManager.default.getUrls() {
        if url.isFileURL {
            let context = try FormalContext(url: url, format: .fimi)
            var times: [[Double]] = [[], [], []]
            var algIndex = 0
            let algs = [GreCon(), GreCon2(), GreConD()]
            
            for algorithm in algs {
                for _ in 0..<5 {
                    let timer = Timer()
                    let _ = algorithm.countFactors(in: context)
                    let time = timer.stop()
                    times[algIndex].append(time)
                }
                algIndex += 1
            }
            
            
            for col in 0..<times.count {
                let average = times[col].reduce(0, +) / Double(times[col].count)
                let deviation = times[col].map({ (average - $0).magnitude }).reduce(0, +) / Double(times[col].count)
                fileContent += " & $\(String(format: "%.2f", average.rounded(toPlaces: 2))) \\pm \(String(format: "%.2f", deviation.rounded(toPlaces: 2)))$ "
            }
            fileContent += "\\\\ \\hline\n"
            
        }
    }
    
    fileContent += "\\end{tabular}\n"
    try FileManager.default.saveResult(folder: [.time],
                                       filename: "times",
                                       content: fileContent)
}

public func computeAndStoreFactorisation() throws {
    
    for url in try FileManager.default.getUrls() {
        let context = try FormalContext(url: url, format: .fimi)
        let filename = url.lastPathComponent.replacingOccurrences(of: ".fimi", with: "")
        
        let greCon2Factors = GreCon2().countFactors(in: context)
        
        try FileManager.default.saveData(folder: [.factorisation, .greCon],
                                         filename: filename,
                                         content: greCon2Factors.map { $0.export() }.joined(separator: "\n"))
        
        let greConDFactors = GreConD().countFactors(in: context)
        
        try FileManager.default.saveData(folder: [.factorisation, .greConD],
                                         filename: filename,
                                         content: greConDFactors.map { $0.export() }.joined(separator: "\n"))
    }
}

public enum Algorithm {
    case greCon
    case greCon2
    case greConD
    
    var folder: FileManager.FilePath {
        switch self {
        case .greCon:  return .greCon
        case .greCon2: return .greCon2
        case .greConD: return .greConD
        }
    }
}

public func loadFactorisation<T: Bicluster>(algorithm: Algorithm, dataset: String) throws -> [T] {
    if let content = FileManager.default.fileContent(path: [.data, .factorisation, algorithm.folder],
                                                     fileName: dataset.replacingOccurrences(of: ".fimi", with: "")) {
        return content.components(separatedBy: .newlines).compactMap { .init(coding: $0) }
    }
    return []
}
