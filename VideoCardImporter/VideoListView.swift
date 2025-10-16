import SwiftUI

struct VideoFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let creationDate: Date
    var isSelected: Bool
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            self.size = attributes[.size] as? Int64 ?? 0
            self.creationDate = attributes[.creationDate] as? Date ?? Date()
        } catch {
            self.size = 0
            self.creationDate = Date()
        }
        self.isSelected = false
    }
}

struct VideoListView: View {
    let drive: Drive
    @Binding var selectedVideos: Set<URL>
    let onBack: () -> Void
    let onImport: () -> Void
    
    @State private var videoFiles: [VideoFile] = []
    @State private var isScanning = true
    @State private var lastClickedIndex: Int? = nil
    
    var body: some View {
        Group {
            if isScanning {
                VStack(spacing: 30) {
                    ProgressView()
                        .scaleEffect(2.0)
                    Text("Scanning for videos...")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.windowBackgroundColor))
            } else {
                List(videoFiles.indices, id: \.self) { index in
                    let video = videoFiles[index]
                    VideoRow(
                        video: video,
                        isSelected: selectedVideos.contains(video.url)
                    ) { isSelected in
                        handleSelection(index: index, isSelected: isSelected)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            scanForVideos()
        }
    }
    
    private func handleSelection(index: Int, isSelected: Bool) {
        let video = videoFiles[index]
        
        // Check if shift key is being held down
        if let event = NSApp.currentEvent, event.modifierFlags.contains(.shift), let lastIndex = lastClickedIndex {
            // Calculate the range of indices to select/deselect
            let range = lastIndex < index ? lastIndex...index : index...lastIndex
            
            // Update selection for all items in the range
            for i in range {
                let url = videoFiles[i].url
                if isSelected {
                    selectedVideos.insert(url)
                } else {
                    selectedVideos.remove(url)
                }
            }
        } else {
            // Single selection
            if isSelected {
                selectedVideos.insert(video.url)
            } else {
                selectedVideos.remove(video.url)
            }
        }
        
        // Update the last clicked index
        lastClickedIndex = index
    }
    
    private func scanForVideos() {
        DispatchQueue.global(qos: .userInitiated).async {
            let driveManager = DriveManager()
            let urls = driveManager.findVideoFiles(in: drive)
            
            DispatchQueue.main.async {
                videoFiles = urls.map { VideoFile(url: $0) }
                isScanning = false
            }
        }
    }
}

struct VideoRow: View {
    let video: VideoFile
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { onSelectionChanged($0) }
            ))
            
            VStack(alignment: .leading) {
                Text(video.name)
                    .font(.headline)
                HStack {
                    Text(formatSize(video.size))
                    Text("•")
                    Text(formatDate(video.creationDate))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .onTapGesture {
            onSelectionChanged(!isSelected)
        }
    }
    
    private func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 