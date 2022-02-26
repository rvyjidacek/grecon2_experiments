//
//  LineReader.swift
//  
//
//  Source StackOverflow
//  https://stackoverflow.com/questions/43238966/swift-version-of-streamreader-only-streams-the-entire-file-not-in-chunks-which
//

import Foundation

/// Reads text file line by line
class LineReader {
    let path: String

    fileprivate let file: UnsafeMutablePointer<FILE>!

    init?(path: String) {
        self.path = path

        file = fopen(path, "r")

        guard file != nil else { return nil }

    }

    var nextLine: String? {
        var line:UnsafeMutablePointer<CChar>? = nil
        var linecap: Int = 0
        
        defer { free(line) }
        if getline(&line, &linecap, file) > 0 {
            let string = String(cString: line!)
            return string.substring(to: string.index(before: string.endIndex))
        }
        return nil
    }

    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    func  makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine
        }
    }
}
