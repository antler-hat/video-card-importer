import Foundation

class FileOperations {
    static func copyFiles(from sourceURLs: [URL], to destinationURL: URL, progress: @escaping (Double) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        let queue = DispatchQueue(label: "com.canonball.fileoperations", qos: .userInitiated)
        let group = DispatchGroup()
        var totalBytes: Int64 = 0
        var copiedBytes: Int64 = 0
        
        // First, calculate total size
        for url in sourceURLs {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                totalBytes += attributes[.size] as? Int64 ?? 0
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Then copy files
        for url in sourceURLs {
            group.enter()
            queue.async {
                let destinationFileURL = destinationURL.appendingPathComponent(url.lastPathComponent)
                
                do {
                    let fileHandle = try FileHandle(forReadingFrom: url)
                    let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
                    
                    if FileManager.default.fileExists(atPath: destinationFileURL.path) {
                        try FileManager.default.removeItem(at: destinationFileURL)
                    }
                    
                    FileManager.default.createFile(atPath: destinationFileURL.path, contents: nil)
                    let destinationHandle = try FileHandle(forWritingTo: destinationFileURL)
                    
                    let bufferSize = 1024 * 1024 // 1MB buffer
                    var buffer = Data(capacity: bufferSize)
                    var bytesRead: Int64 = 0
                    
                    while bytesRead < fileSize {
                        buffer = try fileHandle.read(upToCount: bufferSize) ?? Data()
                        try destinationHandle.write(contentsOf: buffer)
                        bytesRead += Int64(buffer.count)
                        
                        DispatchQueue.main.async {
                            copiedBytes += Int64(buffer.count)
                            progress(Double(copiedBytes) / Double(totalBytes))
                        }
                    }
                    
                    try fileHandle.close()
                    try destinationHandle.close()
                } catch {
                    completion(.failure(error))
                    return
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(()))
        }
    }
} 