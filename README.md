# Video Card Importer

Videos on SD cards are often nested in a whole bunch of folders. This is a macOS application for easily importing videos from a camcorder card. 


### Download Release
1. Download the latest release from the [releases page](https://github.com/antler-hat/video-card-importer/releases)
2. Drag `VideoCardImporter.app` to your Applications folder

### Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/antler-hat/video-card-importer.git
   cd video-card-importer
   ```

2. Build the app:
   ```bash
   ./scripts/build.sh
   ```

## Usage

1. Connect your camera or memory card to your Mac
2. Launch Video Card Importer
3. The app will automatically scan for camcorder cards
4. Click on a drive to view its videos
5. Select the videos you want to import using:
   - Individual checkboxes
   - "Select All" button
   - "Select None" button
   - Shift-click for range selection
6. Click the "Import" button
7. Choose a destination folder
8. Wait for the import to complete


### Project Structure
```
VideoCardImporter/
├── VideoCardImporter.swift   # Main app and content view
├── DriveManager.swift         # Drive detection and validation
├── DriveListView.swift        # Drive selection UI
├── VideoListView.swift        # Video selection UI
└── FileOperations.swift       # File copying operations
```

### Building
The project includes a build script that compiles the app using the Swift compiler:
```bash
./scripts/build.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.