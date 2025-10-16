# AFL Stats Tracker

A comprehensive Android application for tracking Australian Football League (AFL) match statistics in real-time.

## 🏈 Features

- **Real-time Statistics Tracking**: Live recording of player actions during matches
- **Team Management**: Create teams with custom logos and player rosters
- **Match Recording**: Track kicks, handballs, marks, tackles, goals, and behinds
- **Score Management**: Automatic score calculation with quarter-by-quarter tracking
- **Match History**: View and analyze previous matches
- **Player Analytics**: Individual player performance statistics
- **Undo Functionality**: Reverse actions while maintaining data integrity

## 🛠️ Technical Stack

- **Language**: Kotlin
- **Platform**: Android (API 24+)
- **Database**: Firebase Firestore
- **Architecture**: MVVM with View Binding
- **UI**: Android Views with RecyclerView

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites
- Android Studio Arctic Fox or later
- Android SDK 24 or higher
- Firebase project setup

### Installation
1. Clone the repository
2. Open in Android Studio
3. Add your `google-services.json` file to the `app/` directory
4. Sync project with Gradle files
5. Run on device or emulator

## 📊 Data Models

### Player
```kotlin
data class Player(
    val name: String,
    val number: String,
    val position: String,
    val team: String,
    val imageUri: String,
    // Statistics
    var kicks: Int = 0,
    var handballs: Int = 0,
    var marks: Int = 0,
    var tackles: Int = 0,
    var goals: Int = 0,
    var behinds: Int = 0
)
```

### Match Record
```kotlin
data class MatchRecord(
    val team1: String,
    val team2: String,
    val timestamp: Timestamp,
    val matchId: String
)
```

## 🔥 Firebase Structure

```
matches/
├── {matchId}/
│   ├── team1: String
│   ├── team2: String
│   ├── timestamp: Timestamp
│   ├── quarters: Array<QuarterStats>
│   ├── playerStats: Array<PlayerStats>
│   └── actions/
│       └── {actionId}/
│           ├── playerId: String
│           ├── action: String
│           └── timestamp: Timestamp
```

## 🎯 Key Features

### Match Creation
1. Enter team names and upload logos
2. Add players with details (name, number, position)
3. Start match recording

### Live Statistics
- Select player and record actions
- Real-time score updates
- Quarter management (4 quarters)
- Undo last action

### Match Analysis
- View match summary
- Browse match history
- Analyze player statistics

## 🏗️ Architecture

The app follows MVVM architecture with:
- **Activities**: UI controllers
- **Data Models**: Parcelable data classes
- **Adapters**: RecyclerView data binding
- **Firebase**: Cloud data persistence

## 📝 License

This project is for educational purposes.

## 👨‍💻 Author

*Your Name* - University of Tasmania

## 📚 Documentation

- [Full Technical Documentation](AFL_Stats_Tracker_Documentation.md)
- [Interview Summary](Interview_Summary.md)

---

*Built with ❤️ for AFL enthusiasts*
