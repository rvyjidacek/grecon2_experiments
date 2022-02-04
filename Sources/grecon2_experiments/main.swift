import FcaKit
import Foundation

#if DEBUG
    FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/")
#endif

do {
    try computeAndStoreFactorisation()
    try timeBenchmark()
    
    try compareGreConAndGreConDCoverage()
} catch {
    fatalError(error.localizedDescription)
}
