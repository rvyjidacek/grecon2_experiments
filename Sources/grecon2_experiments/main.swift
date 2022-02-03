import FcaKit
import Foundation

FileManager.default.changeCurrentDirectoryPath("/Users/romanvyjidacek/Library/Mobile Documents/com~apple~CloudDocs/UPOL/phd/research/grecon2_experiments/")

do {
    try compareGreConAndGreConDCoverage()
} catch {
    fatalError(error.localizedDescription)
}

