import SwiftUI
import UniformTypeIdentifiers

@main
struct AVCHDVideoImporter: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @StateObject private var driveManager = DriveManager()
    @State private var selectedDrive: Drive?
    @State private var selectedVideos: Set<URL> = []
    @State private var importProgress: Double = 0
    @State private var isImporting = false
    @State private var showImportDialog = false
    @State private var importError: String?
    @State private var showSuccessMessage = false

    var body: some View {
        Group {
            if driveManager.isScanning {
                // Loading state
                VStack(spacing: 30) {
                    ProgressView()
                        .scaleEffect(2.0)
                    Text("Looking for a Canon camera or card...")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("This may take a few moments")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.windowBackgroundColor))
            } else if !driveManager.isScanning && driveManager.validDrives.isEmpty {
                // No drives found state
                VStack(spacing: 30) {
                    Image(systemName: "externaldrive.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Canon camera or card found")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Please connect a Canon camera or memory card")
                        .foregroundColor(.secondary)
                    Button(action: {
                        driveManager.startScanning()
                    }) {
                        Label("Scan Again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.windowBackgroundColor))
            } else if selectedDrive == nil {
                // Drive list state
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            driveManager.startScanning()
                        }) {
                            Label("Scan Again", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                    DriveListView(
                        drives: driveManager.validDrives,
                        onDriveSelected: { drive in
                            selectedDrive = drive
                        }
                    )
                }
            } else {
                // Video list state
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            selectedDrive = nil
                            selectedVideos.removeAll()
                        }) {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        .padding()

                        Spacer()

                        Text("Videos on \(selectedDrive!.name)")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            // Select all videos
                            if let drive = selectedDrive {
                                let allUrls = driveManager.findVideoFiles(in: drive)
                                selectedVideos = Set(allUrls)
                            }
                        }) {
                            Text("Select All")
                        }
                        .buttonStyle(.bordered)
                        .padding(.trailing, 4)

                        Button(action: {
                            selectedVideos.removeAll()
                        }) {
                            Text("Select None")
                        }
                        .buttonStyle(.bordered)
                        .padding(.trailing, 8)

                        Button(action: {
                            showImportDialog = true
                        }) {
                            Text("Import")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedVideos.isEmpty)
                        .padding(.trailing)
                    }
                    VideoListView(
                        drive: selectedDrive!,
                        selectedVideos: $selectedVideos,
                        onBack: {
                            selectedDrive = nil
                            selectedVideos.removeAll()
                        },
                        onImport: {
                            showImportDialog = true
                        }
                    )
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .overlay {
            if isImporting {
                ZStack {
                    Color(.windowBackgroundColor).opacity(0.9)
                    VStack(spacing: 30) {
                        ProgressView()
                            .scaleEffect(2.0)
                        Text("Importing videos...")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("\(Int(importProgress * 100))%")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            } else if showSuccessMessage {
                ZStack {
                    Color(.windowBackgroundColor).opacity(0.9)
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Import Complete")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .fileImporter(
            isPresented: $showImportDialog,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let destinationURL = urls.first {
                    importVideos(to: destinationURL)
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
        .alert("Import Error", isPresented: .constant(importError != nil)) {
            Button("OK") {
                importError = nil
            }
        } message: {
            Text(importError ?? "")
        }
    }

    private func importVideos(to destinationURL: URL) {
        isImporting = true
        importProgress = 0

        let sourceURLs = Array(selectedVideos)

        FileOperations.copyFiles(
            from: sourceURLs,
            to: destinationURL,
            progress: { progress in
                DispatchQueue.main.async {
                    self.importProgress = progress
                }
            },
            completion: { result in
                DispatchQueue.main.async {
                    self.isImporting = false
                    switch result {
                    case .success:
                        self.showSuccessMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showSuccessMessage = false
                        }
                        self.selectedVideos.removeAll()
                    case .failure(let error):
                        self.importError = error.localizedDescription
                    }
                }
            }
        )
    }
}
