import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), trackName: "Song Title", artistName: "Artist Name", isPlaying: true, waveformData: Array(repeating: 0.5, count: 50))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), trackName: "Sample Song", artistName: "Sample Artist", isPlaying: true, waveformData: generateSampleWaveform())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Get widget data from UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.spotify_visualizer")
        let trackName = sharedDefaults?.string(forKey: "track_name") ?? "No track playing"
        let artistName = sharedDefaults?.string(forKey: "artist_name") ?? ""
        let isPlaying = sharedDefaults?.bool(forKey: "is_playing") ?? false
        let waveformDataString = sharedDefaults?.string(forKey: "waveform_data") ?? "[]"
        
        let waveformData: [Double]
        if let data = waveformDataString.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Double] {
            waveformData = jsonArray
        } else {
            waveformData = generateSampleWaveform()
        }

        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            trackName: trackName,
            artistName: artistName,
            isPlaying: isPlaying,
            waveformData: waveformData
        )
        entries.append(entry)

        // Schedule next update
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func generateSampleWaveform() -> [Double] {
        return (0..<50).map { i in
            0.5 + sin(Double(i) * 0.2) * 0.3
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let trackName: String
    let artistName: String
    let isPlaying: Bool
    let waveformData: [Double]
}

struct SpotifyVisualizerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: entry.isPlaying ? "play.fill" : "pause.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.trackName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(entry.artistName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            VisualizerView(waveformData: entry.waveformData, isPlaying: entry.isPlaying)
                .frame(height: 40)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct VisualizerView: View {
    let waveformData: [Double]
    let isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let barCount = min(waveformData.count, 32)
            let barWidth = geometry.size.width / CGFloat(barCount) * 0.8
            let barSpacing = geometry.size.width / CGFloat(barCount)
            
            HStack(spacing: 0) {
                ForEach(0..<barCount, id: \.self) { index in
                    let amplitude = waveformData[index * waveformData.count / barCount]
                    let barHeight = CGFloat(amplitude) * geometry.size.height * (isPlaying ? 0.8 : 0.4)
                    
                    RoundedRectangle(cornerRadius: barWidth / 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green,
                                    Color.green.opacity(0.6)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: barWidth, height: max(barHeight, 2))
                        .position(x: CGFloat(index) * barSpacing + barSpacing / 2,
                                y: geometry.size.height - barHeight / 2)
                }
            }
        }
    }
}

struct SpotifyVisualizerWidget: Widget {
    let kind: String = "SpotifyVisualizerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SpotifyVisualizerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Spotify Visualizer")
        .description("Shows your currently playing track with a retro sound wave visualizer")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SpotifyVisualizerWidget_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyVisualizerWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            trackName: "Sample Song",
            artistName: "Sample Artist",
            isPlaying: true,
            waveformData: Array(repeating: 0.7, count: 50)
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}