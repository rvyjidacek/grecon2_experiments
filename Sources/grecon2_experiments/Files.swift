//
//  Files.swift
//  
//
//  Created by Roman Vyjídáček on 01.02.2022.
//

import Foundation

extension FileManager {
    
    public enum FilePath: String {
        case datasets = "datasets"
        case data = "data"
        case results = "results"
        case greCon = "grecon"
        case greCon2 = "greCon2"
        case greConD = "greConD"
        case factorisation = "factorisation"
        case greconGreConDCoverageCmp = "grecon_greConD_coverage_cmp"
        case time = "time"
        
    }
    
    public func folderExists(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
    
    public func fileExists(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory:&isDirectory)
        return exists && !(isDirectory.boolValue)
    }
    
    public func fileExists(at path: [FilePath], fileName: String) -> Bool {
        return fileExists(at: combinePath(components: path, filename: fileName))
    }
    
    public func createFileIfNotExists(at path: [FilePath], fileName: String, content: String) throws {
        if !(fileExists(at: path, fileName: fileName)){
            
            createFile(atPath: combinePath(components: path, filename: fileName),
                       contents: content.data(using: .utf8),
                       attributes: nil)
        } else {
            try content.write(to: url(from: path, fileName: fileName),
                              atomically: false,
                              encoding: .utf8)
        }
    }
    
    public func url(from path: [FilePath], fileName: String) -> URL {
        URL(fileURLWithPath: combinePath(components: path, filename: fileName))
    }
    
    public func fileContent(path: [FilePath], fileName: String) -> String? {
        return try! String(contentsOfFile: combinePath(components: path, filename: fileName),
                           encoding: .utf8)
    }
    
    public func createDirectoryIfNotExists(at path: String) throws {
        if !(folderExists(at: path)) {
            try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public func getUrls() throws -> [URL] {
        let path = combinePath(components: [.datasets])
        
        let urls = try contentsOfDirectory(at: URL(fileURLWithPath: path, isDirectory: true),
                                                   includingPropertiesForKeys: nil,
                                                   options: [.skipsHiddenFiles]).filter { $0.absoluteString.contains(".fimi") }
        return urls
    }
    
    public func getUrls(path: [FilePath]) throws -> [URL] {
        let path = combinePath(components: path)
        
        let urls = try contentsOfDirectory(at: URL(fileURLWithPath: path, isDirectory: true),
                                                   includingPropertiesForKeys: nil,
                                                   options: [.skipsHiddenFiles]).filter { $0.absoluteString.contains(".fimi") }
        return urls
    }

    public func saveResult(folder: [FilePath], filename: String, content: String) throws {
        var results: [FilePath] = [.results]
        results.append(contentsOf: folder)
        
        let folder = combinePath(components: results)
        
        try createDirectoryIfNotExists(at: folder)
        try createFileIfNotExists(at: results, fileName: filename, content: content)
        
    }
    
    public func saveData(folder: [FilePath], filename: String, content: String) throws {
        var data: [FilePath] = [.data]
        data.append(contentsOf: folder)
        
        let folder = combinePath(components: data)
        
        try createDirectoryIfNotExists(at: folder)
        try createFileIfNotExists(at: data, fileName: filename, content: content)
    }
    
    private func combinePath(components: [FilePath], filename: String) -> String {
        return currentDirectoryPath + "/" + components.map { $0.rawValue }.joined(separator: "/") + "/" + filename
    }
    
    private func combinePath(components: [FilePath]) -> String {
        return currentDirectoryPath + "/" + components.map { $0.rawValue }.joined(separator: "/")
    }
}
