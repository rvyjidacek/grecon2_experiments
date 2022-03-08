import FcaKit
import Foundation

#if DEBUG
    FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")
#endif

FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")

do {
    try computeAndStoreConcepts()
    try computeAndStoreFactorisation()
    try datasetStatistics()
    try coverageCompare()
    try greCon2AndGreConDCoverage()
    try allAgorithmCoverage()
    try quartilesCoverageGraphs()
    try quartilesInputTimes()
    try quartilesCoverageGraphs()
    try attributeAndObjectConceptsTimeBenchmark()
    try considerationBenchmark()
    try timeBenchmark()
} catch {
    fatalError(error.localizedDescription)
}
