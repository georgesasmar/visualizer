# Spotify Visualizer

A production-quality Flutter app with homescreen widgets that displays an old-school sound wave visualizer for your currently-playing Spotify tracks.

## Features

- **Spotify OAuth Integration**: Secure PKCE authentication flow
- **Real-time Audio Analysis**: Visualizes audio features and analysis from Spotify Web API
- **Multiple Visualizer Styles**: Choose from oscilloscope, bars, waveform, and spectrum
- **Home Screen Widgets**: Android App Widget and iOS WidgetKit support
- **Customizable Themes**: Multiple color presets and dark/light themes
- **Battery Efficient**: Smart update intervals and optimized rendering

## Screenshots

| Main App | Widget (Android) | Widget (iOS) |
|----------|------------------|--------------|
| ![Main App](demo/main_app.gif) | ![Android Widget](demo/android_widget.gif) | ![iOS Widget](demo/ios_widget.gif) |

## Setup Instructions

### 1. Spotify App Registration

1. Go to the [Spotify Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your **Client ID**
4. In app settings, add these redirect URIs:
   - `com.example.spotifyvisualizer://callback`
   - `http://localhost:8888/callback` (for testing)

### 2. Configure the App

1. Open `lib/src/core/services/spotify_service.dart`
2. Replace `YOUR_SPOTIFY_CLIENT_ID` with your actual Spotify Client ID:

```dart
static const String clientId = 'your_actual_client_id_here';
```

### 3. Android Setup

1. Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.spotify_visualizer">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application>
        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme">
            
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="com.example.spotifyvisualizer" />
            </intent-filter>
        </activity>
        
        <!-- Widget Provider -->
        <receiver android:name=".SpotifyVisualizerWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data android:name="android.appwidget.provider"
                android:resource="@xml/spotify_visualizer_widget_info" />
        </receiver>
    </application>
</manifest>
```

### 4. iOS Setup

1. Add URL scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>spotify-auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.spotifyvisualizer</string>
        </array>
    </dict>
</array>
```

2. Configure App Groups in Xcode:
   - Select your main app target
   - Go to "Signing & Capabilities"
   - Add "App Groups" capability
   - Create group: `group.com.example.spotify_visualizer`
   - Repeat for the widget extension target

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Generate Code (if needed)

```bash
flutter packages pub run build_runner build
```

## Building and Running

### Development
```bash
flutter run
```

### Android Release
```bash
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

## Widget Installation

### Android
1. Long press on home screen
2. Select "Widgets"
3. Find "Spotify Visualizer"
4. Drag to home screen

### iOS
1. Long press on home screen
2. Tap the "+" button
3. Search for "Spotify Visualizer"
4. Select widget size and add

## Architecture

### Core Services
- **SpotifyService**: Handles OAuth, API calls, and token management
- **VisualizerService**: Processes audio analysis and generates waveforms
- **StorageService**: Secure token storage and app preferences
- **WidgetService**: Cross-platform widget updates and data sharing

### Visualizer Styles
1. **Oscilloscope**: Retro CRT-style waveform with scan line
2. **Bars**: Classic frequency bars with reflections
3. **Waveform**: Filled waveform with progress indicator
4. **Spectrum**: Frequency spectrum with color-coded bands

### State Management
- Provider pattern for reactive state updates
- Automatic token refresh and error handling
- Efficient caching of audio analysis data

## Platform Limitations

### iOS Widget Constraints
- **Update Frequency**: Limited by iOS WidgetKit (15-30 min intervals)
- **Real-time Animation**: Not supported; uses precomputed timeline entries
- **Background Execution**: Restricted; updates when app is active

### Android Widget Constraints
- **Battery Optimization**: Updates limited on Android 12+
- **Update Frequency**: 15-30 minutes recommended for battery life
- **Memory Usage**: Simplified visualizations to reduce memory footprint

## API Rate Limits

- **Spotify Web API**: 100 requests per minute per user
- **Current Track Polling**: Every 2 seconds when app is active
- **Audio Analysis Caching**: Cached per track to avoid re-fetching

## Security & Privacy

- **Token Storage**: Uses platform secure storage (Keychain/EncryptedSharedPreferences)
- **PKCE Flow**: No client secret embedded in app
- **Data Transmission**: All API calls over HTTPS
- **Local Data**: Audio analysis cached locally, cleared on logout

## Testing

Run unit tests:
```bash
flutter test
```

Run widget tests:
```bash
flutter test test/widget/
```

Run integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify Client ID is correct
   - Check redirect URI matches Spotify app settings
   - Ensure app has required scopes

2. **No Audio Data**
   - Confirm music is playing in Spotify
   - Check network connectivity
   - Verify Spotify Premium subscription (required for some API endpoints)

3. **Widget Not Updating**
   - Check background app refresh permissions
   - Verify widget is added to home screen
   - Restart device if widget appears frozen

4. **iOS Widget Issues**
   - Ensure App Groups are configured correctly
   - Check widget timeline generation in logs
   - Verify shared UserDefaults access

### Debug Commands

Enable debug logging:
```bash
flutter run --debug
```

Check widget data (Android):
```bash
adb shell dumpsys appwidget
```

## App Store Submission

### Requirements
1. Spotify Developer Agreement compliance
2. Privacy policy mentioning Spotify data usage
3. App Store review guidelines compliance
4. Widget functionality clearly described

### Pre-submission Checklist
- [ ] Test on multiple device sizes
- [ ] Verify widget installation flow
- [ ] Test offline behavior
- [ ] Validate authentication flow
- [ ] Performance testing with large playlists
- [ ] Memory usage optimization
- [ ] Battery usage testing

## Known Limitations

1. Requires Spotify Premium for real-time playback state
2. Audio analysis limited to tracks in Spotify catalog
3. Widget updates subject to platform restrictions
4. No offline visualization (requires network connectivity)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
1. Check the troubleshooting section
2. Search existing GitHub issues
3. Create a new issue with detailed description and logs

---

Built with ❤️ using Flutter and the Spotify Web API