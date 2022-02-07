//
//  Benchmarks.swift
//  
//
//  Created by Roman Vyjídáček on 01.02.2022.
//

import Foundation
import FcaKit

public func greCon2AndGreConDCoverage() throws {
    for url in try FileManager.default.getUrls() {
        let fileContent = try compareAlgorithms(algorithms: [.greCon2, .greConD], url: url)
        
        if let dataset = url.fileName {
            try FileManager.default.saveResult(folder: [.grecon2GreConDCoverageGraph],
                                               filename: dataset,
                                               fileType: .csv,
                                               content: fileContent)
        }
    }
}

public func allAgorithmCoverage() throws {
    for url in try FileManager.default.getUrls() {
        let fileContent = try compareAlgorithms(algorithms: [.greCon, .greConD, .greCon2], url: url)
        
        if let dataset = url.fileName {
            try FileManager.default.saveResult(folder: [.allAlgorithmsCoverageGraph],
                                               filename: dataset,
                                               fileType: .csv,
                                               content: fileContent)
        }
    }
}

public func coverageCompare() throws {
    for url in try FileManager.default.getUrls() {
        let context = try FormalContext(url: url)
        let algorithms: [Algorithm] = [.greCon, .greConD]
        let factors: [[FormalConcept]] = try algorithms.map { try loadFactorisation(algorithm: $0, dataset: url.lastPathComponent) }
        
        var tuples: [CoverageTuple] = []
        
        for i in 0..<factors.count { tuples.append((algorithms[i], factors[i])) }
        
        let iterationCount = factors.map { $0.count }.max() ?? 0
        var fileContent = ""
        
        for tuple in tuples {
            let uncovered = CartesianProduct(context: context)
            
            fileContent += "\(tuple.alg.name)"
            for i in 0..<iterationCount {
                if i >= tuple.factors.count {
                    fileContent += ";0"
                    continue
                }
                
                let cover = tuple.factors[i].cartesianProduct.intersected(uncovered)
                fileContent += ";\(cover.count)"
                
                for t in cover {
                    uncovered.remove(t)
                }
            }
            fileContent += "\n"
        }
        
        if let dataset = url.fileName {
            try FileManager.default.saveResult(folder: [.greconVsGrecondSimilarity],
                                               filename: dataset,
                                               fileType: .csv,
                                               content: fileContent)
        }
    }
}
    

private typealias CoverageTuple = (alg: Algorithm, factors: [FormalConcept])

private func compareAlgorithms(algorithms: [Algorithm], url: URL) throws -> String {
    let context = try FormalContext(url: url)
    let factors: [[FormalConcept]] = try algorithms.map { try loadFactorisation(algorithm: $0, dataset: url.lastPathComponent) }
    
    var tuples: [CoverageTuple] = []
    
    for i in 0..<factors.count { tuples.append((algorithms[i], factors[i])) }
    
    var fileContent = ""
    let iterationCount = factors.map { $0.count }.max() ?? 0
    
    for tuple in tuples {
        let uncovered = CartesianProduct(context: context)
        var totalCover = 0
        
        fileContent += "\(tuple.alg.name);0"
        for i in 0..<iterationCount {
            if i >= tuple.factors.count {
                fileContent += ";-1"
                continue
            }
            
            let cover = tuple.factors[i].cartesianProduct.intersected(uncovered)
            totalCover += cover.count
            fileContent += ";\(totalCover)"
            
            for t in cover {
                uncovered.remove(t)
            }
        }
        fileContent += "\n"
    }
    
    return fileContent
}

public func printTimeBenchmark() throws {
    let timer = Timer()
    
    for url in try FileManager.default.getUrls() {
        if url.isFileURL {
            let context = try FormalContext(url: url, format: .fimi)
            var times: [[Double]] = [[], [], []]
            var algIndex = 0
            let algs = [GreCon(), GreCon2(), GreConD()]
            
            print("\\begin{tabular}{|l|c|c|c|}\n\\hline")
            print("Dataset & GreCon & GreCon2 & GreConD \\\\ \n \\hline")
            print(url.fileName ?? "NIL", separator: "", terminator: "")
            
            for algorithm in algs {
                if algIndex == 0 && url.fileName == "nfs" {
                    times[algIndex].append(0)
                } else {
                    for _ in 0..<2 {
                        timer.start()
                        let _ = algorithm.countFactors(in: context)
                        let time = timer.stop()
                        times[algIndex].append(time)
                    }
                }
                algIndex += 1
            }
            
            
            for col in 0..<times.count {
                let average = times[col].reduce(0, +) / Double(times[col].count)
                let deviation = times[col].map({ (average - $0).magnitude }).reduce(0, +) / Double(times[col].count)
                print(" & $\(String(format: "%.2f", average.rounded(toPlaces: 2))) \\pm \(String(format: "%.2f", deviation.rounded(toPlaces: 2)))$ ", separator: "", terminator: "")
            }
            print("\\\\ \\hline")
        }
        print("\\end{tabular}")
    }
    
    
}


public func timeBenchmark() throws {
    let timer = Timer()
    
    var fileContent = "\\begin{tabular}{|l|c|c|c|}\n\\hline\n"
    fileContent += "Dataset & GreCon & GreCon2 & GreConD \\\\ \n \\hline\n"
    
    for url in try FileManager.default.getUrls() {
        if url.isFileURL {
            
            let context = try FormalContext(url: url, format: .fimi)
            var times: [[Double]] = [[], [], []]
            var algIndex = 0
            let algs = [GreCon(), GreCon2(), GreConD()]
            
            for algorithm in algs {
                if algorithm.name == "GreCon" && url.fileName == "nfs.fimi" {
                    times[algIndex].append(0)
                } else {
                    for _ in 0..<2 {
                        timer.start()
                        let _ = algorithm.countFactors(in: context)
                        let time = timer.stop()
                        times[algIndex].append(time)
                    }
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
                                       fileType: .tex,
                                       content: fileContent)
}

public func computeAndStoreConcepts() throws {
    for url in try FileManager.default.getUrls() {
        if let filename = url.fileName {
            let context = try FormalContext(url: url)
            let concepts = PFCbO().count(in: context)
            
            try FileManager.default.saveData(folder: [.concepts, .greCon2],
                                             filename: filename,
                                             content: concepts.map { $0.export() }.joined(separator: "\n"))
        }
    }
}

public func convertConcepts() throws {
    
    let attributes = [
        "americas_large": 3485,
        "nfs": 4894
        
    ]
    
    for url in try FileManager.default.getUrls() {
        if let filename = url.fileName {
            let context = try FormalContext(url: url)
            let conceptValues = FileManager.default
                .fileContent(path: [.data, .concepts], fileName: filename + ".fimi")?
                .components(separatedBy: "\n")
                .map { $0.components(separatedBy: " ").compactMap { Int($0) } } ?? []
        
            print("File Parsed")
            
            let maxAttribute = attributes[filename]!
            
            let objects = context.objectSet()
            let attributes = context.attributeSet()
            let concept = FormalConcept(objects: objects, attributes: attributes, context: context)
            
            for intent in conceptValues {
                concept.attributes.erase()
                concept.attributes.addMany(intent)
                concept.objects.erase()
                
                context.down(attributes: concept.attributes, into: concept.objects)
                print(concept.export())
            }
        }
    }
}

public func computeAndStoreFactorisation() throws {
    
    for url in try FileManager.default.getUrls() {
        let context = try FormalContext(url: url, format: .fimi)
        
        if let filename = url.fileName {
//            let greConFactors = GreCon().countFactors(in: context)
//
//            try FileManager.default.saveData(folder: [.factorisation, .greCon],
//                                             filename: filename,
//                                             content: greConFactors.map { $0.export() }.joined(separator: "\n"))
            
            let greCon2Factors = GreCon2().countFactors(in: context)
            
            try FileManager.default.saveData(folder: [.factorisation, .greCon2],
                                             filename: filename,
                                             content: greCon2Factors.map { $0.export() }.joined(separator: "\n"))
            
            let greConDFactors = GreConD().countFactors(in: context)
            
            try FileManager.default.saveData(folder: [.factorisation, .greConD],
                                             filename: filename,
                                             content: greConDFactors.map { $0.export() }.joined(separator: "\n"))
        }
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
    
    var name: String {
        switch self {
        case .greCon:
            return "GreCon"
        case .greCon2:
            return "GreCon2"
        case .greConD:
            return "GreConD"
        }
    }
}

public func loadFactorisation(algorithm: Algorithm, dataset: String) throws -> [FormalConcept] {
    if let content = FileManager.default.fileContent(path: [.data, .factorisation, algorithm.folder],
                                                     fileName: dataset.replacingOccurrences(of: ".fimi", with: "")) {
        return content.components(separatedBy: .newlines).compactMap { FormalConcept(coding: $0) }
    }
    return []
}

