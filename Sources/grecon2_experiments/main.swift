import FcaKit
import Foundation

#if DEBUG
    FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/Library/Mobile Documents/com~apple~CloudDocs/UPOL/phd/research/grecon2_experiments/")
#endif

do {
    try compareGreConAndGreConDCoverage()
} catch {
    fatalError(error.localizedDescription)
}

