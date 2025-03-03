import SwiftUI

struct DriveListView: View {
    let drives: [Drive]
    let onDriveSelected: (Drive) -> Void
    
    var body: some View {
        List(drives) { drive in
            DriveRow(drive: drive)
                .contentShape(Rectangle())
                .onTapGesture {
                    onDriveSelected(drive)
                }
        }
        .listStyle(PlainListStyle())
    }
}

struct DriveRow: View {
    let drive: Drive
    
    var body: some View {
        HStack {
            Image(systemName: "externaldrive.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(drive.name)
                    .font(.headline)
                Text(formatSize(drive.size))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    private func formatSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
} 