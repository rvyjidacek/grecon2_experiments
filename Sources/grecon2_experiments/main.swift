import FcaKit
import Foundation

#if DEBUG
    FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")
#endif

do {
    try printTimeBenchmark()
    //try computeAndStoreFactorisation()
    //try timeBenchmark()
    //try coverageCompare()
    //try greCon2AndGreConDCoverage()
    //try allAgorithmCoverage()
} catch {
    fatalError(error.localizedDescription)
}
