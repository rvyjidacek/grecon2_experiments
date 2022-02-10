import FcaKit
import Foundation

#if DEBUG
    FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")
#endif

FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")

do {

    try quartileGraph()
//    try computeAndStoreConcepts()
//    try computeAndStoreFactorisation()
//    try quartilesInputTimes()
//    try quartilesCoverageGraphs()
//    try convertConcepts()
    try printTimeBenchmark()
//    try timeBenchmark()
//    try coverageCompare()
//    try greCon2AndGreConDCoverage()
//    try allAgorithmCoverage()
} catch {
    fatalError(error.localizedDescription)
}
