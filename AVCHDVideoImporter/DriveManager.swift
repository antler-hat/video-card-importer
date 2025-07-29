import Foundation
import SwiftUI

class Drive: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: url.path)
            self.size = attributes[.systemSize] as? Int64 ?? 0
        } catch {
            self.size = 0
        }
    }
    
    func findVideoFiles() -> [URL] {
        let fileManager = FileManager.default
        var videoFiles: [URL] = []
        
        // Look for AVCHD/BDMV/STREAM path
        let streamPath = url.appendingPathComponent("AVCHD/BDMV/STREAM")
        if fileManager.fileExists(atPath: streamPath.path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: streamPath, includingPropertiesForKeys: nil)
                videoFiles.append(contentsOf: files.filter { $0.pathExtension.uppercased() == "MTS" })
            } catch {
                print("Error reading STREAM directory: \(error)")
            }
        }
        
        // Also check PRIVATE/AVCHD/BDMV/STREAM path
        let privateStreamPath = url.appendingPathComponent("PRIVATE/AVCHD/BDMV/STREAM")
        if fileManager.fileExists(atPath: privateStreamPath.path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: privateStreamPath, includingPropertiesForKeys: nil)
                videoFiles.append(contentsOf: files.filter { $0.pathExtension.uppercased() == "MTS" })
            } catch {
                print("Error reading PRIVATE STREAM directory: \(error)")
            }
        }
        
        return videoFiles
    }
}

class DriveManager: ObservableObject {
    @Published var validDrives: [Drive] = []
    @Published var isScanning = false
    
    init() {
        print("DriveManager initialized")
        // Add a small delay before starting the scan
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startScanning()
        }
    }
    
    func startScanning() {
        print("Starting drive scan...")
        isScanning = true
        validDrives.removeAll()
        
        // Add a minimum scanning time to ensure the loading state is visible
        let startTime = Date()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fileManager = FileManager.default
            let mountedVolumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil) ?? []
            print("\n=== Mounted Volumes ===")
            for (index, volume) in mountedVolumes.enumerated() {
                print("\(index + 1). \(volume.path)")
            }
            print("=====================\n")
            
            for volumeURL in mountedVolumes {
                print("\n=== Checking Volume: \(volumeURL.path) ===")
                
                // Skip system volumes and internal drives
                if self?.isSystemVolume(volumeURL) == true {
                    print("Skipping system volume: \(volumeURL.path)")
                    continue
                }
                
                // List contents of the volume's root directory
                do {
                    let contents = try fileManager.contentsOfDirectory(at: volumeURL, includingPropertiesForKeys: nil)
                    print("\nContents of \(volumeURL.path):")
                    for item in contents {
                        print("- \(item.lastPathComponent)")
                    }
                } catch {
                    print("Error listing contents: \(error)")
                }
                
                if self?.isValidCanonDrive(at: volumeURL) == true {
                    print("Found valid Canon drive: \(volumeURL.path)")
                    DispatchQueue.main.async {
                        self?.validDrives.append(Drive(url: volumeURL))
                    }
                } else {
                    print("Not a valid Canon drive: \(volumeURL.path)")
                }
                print("=====================\n")
            }
            
            // Ensure minimum scanning time of 1.5 seconds
            let elapsedTime = Date().timeIntervalSince(startTime)
            let minimumScanTime: TimeInterval = 1.5
            if elapsedTime < minimumScanTime {
                Thread.sleep(forTimeInterval: minimumScanTime - elapsedTime)
            }
            
            DispatchQueue.main.async {
                print("Scan complete. Found \(self?.validDrives.count ?? 0) valid drives")
                self?.isScanning = false
            }
        }
    }
    
    private func isSystemVolume(_ url: URL) -> Bool {
        // Skip root volume
        if url.path == "/" {
            print("Skipping root volume")
            return true
        }
        
        // Skip volumes mounted under /Volumes that are internal drives
        let volumeName = url.lastPathComponent
        let internalDriveNames = ["Macintosh HD", "Data", "System", "Preboot", "Recovery"]
        if internalDriveNames.contains(volumeName) {
            print("Skipping internal drive: \(volumeName)")
            return true
        }
        
        // Skip volumes that are mounted as read-only
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: url.path)
            let isReadOnly = attributes[.systemFreeNodes] == nil
            if isReadOnly {
                print("Skipping read-only volume")
                return true
            }
            return false
        } catch {
            print("Error checking volume attributes: \(error)")
            return true
        }
    }
    
    private func isValidCanonDrive(at url: URL) -> Bool {
        let fileManager = FileManager.default
        
        // Check for AVCHD file in root
        let avchdURL = url.appendingPathComponent("AVCHD")
        print("Checking for AVCHD at: \(avchdURL.path)")
        if fileManager.fileExists(atPath: avchdURL.path) {
            print("Found AVCHD in root")
            return true
        }
        
        // Check for AVCHD file in PRIVATE folder
        let privateURL = url.appendingPathComponent("PRIVATE")
        print("Checking for PRIVATE at: \(privateURL.path)")
        if fileManager.fileExists(atPath: privateURL.path) {
            let privateAvchdURL = privateURL.appendingPathComponent("AVCHD")
            print("Checking for AVCHD in PRIVATE at: \(privateAvchdURL.path)")
            if fileManager.fileExists(atPath: privateAvchdURL.path) {
                print("Found AVCHD in PRIVATE")
                return true
            }
        }
        
        print("No valid Canon structure found")
        return false
    }
    
    func findVideoFiles(in drive: Drive) -> [URL] {
        let fileManager = FileManager.default
        var videoFiles: [URL] = []

        // Look for AVCHD/BDMV/STREAM path
        let streamPath = drive.url.appendingPathComponent("AVCHD/BDMV/STREAM")
        if fileManager.fileExists(atPath: streamPath.path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: streamPath, includingPropertiesForKeys: nil)
                videoFiles.append(contentsOf: files.filter { $0.pathExtension.uppercased() == "MTS" })
            } catch {
                print("Error reading STREAM directory: \(error)")
            }
        }

        // Also check PRIVATE/AVCHD/BDMV/STREAM path
        let privateStreamPath = drive.url.appendingPathComponent("PRIVATE/AVCHD/BDMV/STREAM")
        if fileManager.fileExists(atPath: privateStreamPath.path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: privateStreamPath, includingPropertiesForKeys: nil)
                videoFiles.append(contentsOf: files.filter { $0.pathExtension.uppercased() == "MTS" })
            } catch {
                print("Error reading PRIVATE STREAM directory: \(error)")
            }
        }

        // Recursively search for .mp4 and .mov files
        if let enumerator = fileManager.enumerator(at: drive.url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                let ext = fileURL.pathExtension.lowercased()
                if ext == "mp4" || ext == "mov" {
                    // Avoid duplicates (in case .mp4/.mov are in AVCHD folders)
                    if !videoFiles.contains(fileURL) {
                        videoFiles.append(fileURL)
                    }
                }
            }
        }

        return videoFiles
    }
}
