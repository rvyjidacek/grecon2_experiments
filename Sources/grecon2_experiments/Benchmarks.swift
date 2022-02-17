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
                if i < tuple.factors.count {
                    let cover = tuple.factors[i].cartesianProduct.intersected(uncovered)
                    fileContent += ";\(cover.count)"
                    
                    for t in cover {
                        uncovered.remove(t)
                    }
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
            if i < tuple.factors.count {
                let cover = tuple.factors[i].cartesianProduct.intersected(uncovered)
                totalCover += cover.count
                fileContent += ";\(totalCover)"
                
                for t in cover {
                    uncovered.remove(t)
                }
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
            
            for algorithm in algs {
                if algIndex == 0 {
                    times[algIndex].append(contentsOf: [0, 0])
                } else {
                    for _ in 0..<2 {
                        timer.start()
                        let _ = algorithm.countFactors(in: context)
                        let time = timer.stop()
                        times[algIndex].append(time)
                    }
                }
                algIndex += 1
                
                print(algorithm.name)
                
                for col in 0..<times.count {
                    let average = times[col].reduce(0, +) / Double(times[col].count)
                    let deviation = times[col].map({ (average - $0).magnitude }).reduce(0, +) / Double(times[col].count)
                    print(" & $\(String(format: "%.2f", average.rounded(toPlaces: 2))) \\pm \(String(format: "%.2f", deviation.rounded(toPlaces: 2)))$ ")
                }
            }
        }
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
            
            try FileManager.default.saveData(folder: [.concepts],
                                             filename: filename,
                                             content: concepts.map { $0.export() }.joined(separator: "\n"))
        }
    }
}

public func convertConcepts() throws {
    
    for url in try FileManager.default.getUrls() {
        if let filename = url.fileName {
            let context = try FormalContext(url: url)
            let conceptValues = FileManager.default
                .fileContent(path: [.data, .concepts], fileName: filename + ".fimi")?
                .components(separatedBy: "\n")
                .map { $0.components(separatedBy: " ").compactMap { Int($0) } } ?? []
        
                        
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
            let greConFactors = GreCon().countFactors(in: context)

            try FileManager.default.saveData(folder: [.factorisation, .greCon],
                                             filename: filename,
                                             content: greConFactors.map { $0.export() }.joined(separator: "\n"))
            
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


public func loadConcepts(dataset: String) throws -> [FormalConcept] {
    if let content = FileManager.default.fileContent(path: [.data, .concepts],
                                                     fileName: dataset) {
        return content.components(separatedBy: .newlines).compactMap { FormalConcept(coding: $0) }
    }
    return []
}

// MARK: - Quartiles

public typealias QuartilesPoints = (q1: Double, q2: Double, q3: Double)

public enum Quartile: Int {
    case q1 = 1
    case q2 = 2
    case q3 = 3
    case q4 = 4
}

func countQuartiles(concepts: [Double]) -> (q1: Double, q2: Double, q3: Double) {
    let a = concepts.sorted()//.map({ "\($0)" }).joined(separator: ";")
    
    var quartiles: [Double] = [0, 0, 0]
    let quotients: [Double] = [1/4, 1/2, 3/4]
    
    for i in 0..<3 {
        let upIndex = Int((Double(a.count) * quotients[i]).rounded(.up))
        let downIndex = upIndex - 1
        
        quartiles[i] = (a[upIndex] + a[downIndex]) / 2
    }
    return (quartiles[0], quartiles[1], quartiles[2])
}

func countQuartiles(fileName: String) throws -> (q1: Double, q2: Double, q3: Double) {
    if let quartiles = loadQuartiles(file: fileName) {
        return quartiles
    }
        
    var a = try loadConceptSizes(file: fileName)
    a.sort()
    
    var quartiles: [Double] = [0, 0, 0]
    let quotients: [Double] = [1/4, 1/2, 3/4]
    
    for i in 0..<3 {
        let upIndex = Int((Double(a.count) * quotients[i]).rounded(.up))
        let downIndex = upIndex - 1
        
        quartiles[i] = (a[upIndex] + a[downIndex]) / 2
    }
    
    try FileManager.default.saveData(folder: [.quartiles],
                                     filename: fileName,
                                     content: quartiles.map { $0.description }.joined(separator: ";"))
    
    return (quartiles[0], quartiles[1], quartiles[2])
}

func getQuartile(size: Double, quartiles: (q1: Double, q2: Double, q3: Double)) -> Quartile {
    if size < quartiles.q1 { return  .q1 }
    if size >= quartiles.q1 && size < quartiles.q2 { return .q2 }
    if size >= quartiles.q2 && size < quartiles.q3 { return .q3 }
    return .q4
}


public func quartileGraph() throws {
    for url in try FileManager.default.getUrls() {
        if let fileName = url.fileName {
            let quartiles = try countQuartiles(fileName: fileName)
            let factors = try loadFactorisation(algorithm: .greCon2, dataset: fileName)
            let iteration = (1...factors.count).map { "\($0)" }
            let quartile = factors.map { getQuartile(size: $0.size, quartiles: quartiles).rawValue.description }
            
            var content = "iteration;" + iteration.joined(separator: ";") + "\n"
            content.append(contentsOf: "quartile;" + quartile.joined(separator: ";"))
                
            try FileManager.default.saveResult(folder: [.quartiles],
                                               filename: fileName,
                                               fileType: .csv,
                                               content:  content)
        }
    }
}

public func quartilesInputTimes() throws {
    var content = ""
    
    for url in try FileManager.default.getUrls() {
        if let fileName = url.fileName {
            let context = try FormalContext(url: url, format: .fimi)
            let concepts = try loadConcepts(dataset: fileName)
            let quartiles = try countQuartiles(fileName: fileName)
            
            let inputs: [Set<Quartile>] = [
                [.q4],
                [.q4, .q3],
                [.q4, .q3, .q2],
                //[.q4, .q3, .q2, .q1]
            ]
            
            
            content += fileName + " "
            var outputs: [String] = []
            
            for quartileSet in inputs {
                let inputConcepts = concepts.filter { quartileSet.contains(getQuartile(size: $0.size, quartiles: quartiles)) }
                let measureResult = measure { () -> [FormalConcept] in
                    return GreCon2().countFactorization(using: inputConcepts, in: context)
                }
                
                outputs.append(String(format: "$%.2f \\pm %.2f$", measureResult.averageTime, measureResult.deviation, measureResult.closureResult.count))
            }

            content += outputs.joined(separator: " & ").appending("\\\\ \n")
        }
    }
    
    try FileManager.default.saveResult(folder: [], filename: "partial_input_times",
                                       fileType: .tex,
                                       content: content)
}

public func quartilesCoverageGraphs() throws {
    
    for url in try FileManager.default.getUrls() {
        if let fileName = url.fileName {
            let context = try FormalContext(url: url, format: .fimi)
            let concepts = try loadConcepts(dataset: fileName).filter { $0.size > 0 }
            let quartiles = try countQuartiles(fileName: fileName)
            
            let inputs: [Set<Quartile>] = [
                [.q4],
                [.q4, .q3],
                [.q4, .q3, .q2],
                //[.q4, .q3, .q2, .q1],
            ]
            
            let inputType = ["GreCon2", "GreCon2 (Q4)", "GreCon2 (Q4 $\\cup$ Q3)", "GreCon2 (Q4 $\\cup$ Q3 $\\cup$ Q2)"]
            
            for i in 0..<inputs.count {
                let inputConcepts = concepts.filter { inputs[i].contains(getQuartile(size: $0.size, quartiles: quartiles)) }
                let factors: [FormalConcept] = GreCon2().countFactorization(using: inputConcepts, in: context)
                //let coverage = dataForCoverageGraph(factors: factors, context: context, algorithmName: inputType[i])
                printDataForCoverageGraph(factors: inputConcepts, context: context, algorithmName: inputType[i])
               
                //content.append(contentsOf: coverage)
                //print(coverage)
            }
            
//            try FileManager.default.saveResult(folder: [.quartileCoverageGraph],
//                                               filename: fileName,
//                                               fileType: .csv,
//                                               content: content)
        }
    }
}

func dataForCoverageGraph(factors: [FormalConcept], context: FormalContext, algorithmName: String) -> String {
    var result = ""
    var totalCoverage: [Int] = []
    let contextRelation = CartesianProduct(context: context)
    
    result.append(contentsOf: "\(algorithmName);0;")
    for factor in factors {
        let cover = contextRelation.intersected(factor.cartesianProduct).count
    
        for tuple in factor.cartesianProduct {
            contextRelation.remove(tuple)
        }
        
        totalCoverage.append((totalCoverage.last ?? 0) + cover)
        
    }
    result.append(totalCoverage.map { "\($0)" }.joined(separator: ";"))
    result.append("\n")
    return result
}

func printDataForCoverageGraph(factors: [FormalConcept], context: FormalContext, algorithmName: String) {
    var lastCoverage = 0
    let contextRelation = CartesianProduct(context: context)
    
    print("\(algorithmName);0", terminator: "")
    for factor in factors {
        let cover = contextRelation.intersected(factor.cartesianProduct).count
    
        for tuple in factor.cartesianProduct {
            contextRelation.remove(tuple)
        }
        
        lastCoverage += cover
        print(";\(lastCoverage)", terminator: "")
        
    }
    print("")
}

private func loadQuartiles(file: String) -> (q1: Double, q2: Double, q3: Double)? {
    if let content = FileManager.default.fileContent(path: [.data, .quartiles], fileName: file) {
        let quartiles = content.components(separatedBy: ";").compactMap { Double($0) }
        if quartiles.count == 3 {
            return (quartiles[0], quartiles[1], quartiles[2])
        }
    }
    return nil
}

private func loadConceptSizes(file: String) throws -> [Double] {
    let url = FileManager.default.url(from: [.data, .concepts], fileName: file)
    let s = LineReader(path: url.path)
    var sizes: [Double] = []
    var concept: FormalConcept?
    
    while let line = s?.nextLine {
        if concept == nil {
            concept = FormalConcept(coding: line)
        } else {
            concept?.updateValues(coding: line)
        }
        
        if let concept = concept {
            sizes.append(concept.size)
        }
    }
    
    return sizes
}
