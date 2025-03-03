# Canon Video Importer

A macOS application for easily importing videos from Canon cameras. This app helps you transfer MTS video files from your Canon camera's memory card to your computer with a clean, modern interface.

## Features

- 🔍 Automatic detection of Canon camera memory cards
- 📹 Lists all available video files with size and creation date
- ✅ Multiple video selection with Select All/None options
- 📊 Real-time import progress tracking
- 🎨 Modern SwiftUI interface
- 💾 Safe file copying with progress tracking

## Requirements

- macOS 11.0 or later
- A Canon camera with AVCHD video recording capability

## Installation

### Download Release
1. Download the latest release from the [releases page](https://github.com/yourusername/CanonVideoImporter/releases)
2. Drag `CanonVideoImporter.app` to your Applications folder
3. Launch the app from your Applications folder

### Build from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/CanonVideoImporter.git
   cd CanonVideoImporter
   ```

2. Build the app:
   ```bash
   ./scripts/build.sh
   ```

3. The built app will be in `build/CanonVideoImporter.app`

## Usage

1. Connect your Canon camera or memory card to your Mac
2. Launch Canon Video Importer
3. The app will automatically scan for Canon drives
4. Click on a drive to view its videos
5. Select the videos you want to import using:
   - Individual checkboxes
   - "Select All" button
   - "Select None" button
6. Click the "Import" button
7. Choose a destination folder
8. Wait for the import to complete

## Development

### Project Structure
```
CanonVideoImporter/
├── CanonVideoImporter.swift   # Main app and content view
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

## Acknowledgments

- Built with SwiftUI
- Designed for Canon camera users
- Inspired by the need for a simple, modern video import tool 