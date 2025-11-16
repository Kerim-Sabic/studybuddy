# StudyBuddy - Complete Features Documentation

## 🎯 Overview

StudyBuddy is a comprehensive study companion app that combines evidence-based learning science, AI-powered coaching, gamification, and social features to create the ultimate learning experience.

---

## 📚 Phase 1: Deep Learning Science

### 1. Spaced Repetition Flashcards (SuperMemo 2)

**Location:** `lib/features/flashcards/`

**Features:**
- SuperMemo 2 algorithm implementation
- Adaptive scheduling based on performance
- Ease factor calculation (1.3 - 3.5 range)
- Interval progression for optimal retention
- Card flip animations
- Progress tracking

**Files:**
- `domain/entities/flashcard.dart` - Core flashcard entity
- `domain/services/flashcard_scheduler_service.dart` - SuperMemo 2 algorithm
- `presentation/screens/flashcard_review_screen.dart` - Review interface

**How It Works:**
```dart
// SuperMemo 2 algorithm calculates next review interval
final updatedCard = card.calculateNextReview(difficulty);
// Intervals: 1 day → 6 days → 2 weeks → 1 month → ...
```

### 2. Cornell Note-Taking System

**Location:** `lib/features/notes/presentation/screens/cornell_notes_screen.dart`

**Features:**
- 3-section layout: Cues (30%), Notes (70%), Summary (bottom)
- Interactive cue management (add/delete)
- Swipe-to-dismiss functionality
- Auto-save support
- Export capabilities

**Layout:**
- **Left Column (Cues):** Key questions and keywords
- **Right Column (Notes):** Main content and detailed notes
- **Bottom Section (Summary):** Concise summary of entire page

### 3. SQ3R/PQ4R Reading Method

**Location:** `lib/features/notes/presentation/screens/reading_workflow_screen.dart`

**Features:**
- Guided step-by-step workflow
- Two methods: SQ3R (5 steps) and PQ4R (6 steps)
- Progress tracking with stepper visualization
- Data persistence across stages
- Question generation assistance

**Stages:**
- **Survey/Preview:** Overview of content
- **Question:** Generate key questions
- **Read:** Active reading with note-taking
- **Reflect:** (PQ4R only) Deep thinking about content
- **Recite:** Test understanding without looking
- **Review:** Final consolidation

### 4. Feynman Technique

**Location:** `lib/features/notes/presentation/screens/feynman_technique_screen.dart`

**Features:**
- 5-step learning process
- Self-assessment slider (1-10 understanding scale)
- Analogy creation
- Gap identification
- Progress stepper with completion tracking

**Steps:**
1. Choose a concept to learn
2. Explain in simple terms
3. Identify knowledge gaps
4. Simplify with analogies
5. Review and refine

### 5. Mind Mapping

**Location:** `lib/features/notes/presentation/screens/mind_map_editor_screen.dart`

**Features:**
- Drag-and-drop node positioning
- Interactive canvas with grid background
- Connection drawing with arrows
- Node editing, coloring, and deletion
- Zoom controls
- Custom painters for visual rendering

**Capabilities:**
- Create unlimited nodes
- Connect nodes with directional arrows
- Color-code nodes by topic
- Pan and zoom canvas
- Save and load mind maps

---

## 🤖 Phase 2: AI-Powered Study Coach

### AI API Integration

**Location:** `lib/features/ai_coach/data/ai_api_service.dart`

**Supported Providers:**
- OpenAI (GPT-4 Turbo, GPT-3.5)
- Anthropic (Claude 3.5 Sonnet, Claude 3 Opus)

**Features:**
1. **Study Recommendations**
   - Personalized advice based on student profile
   - Time management strategies
   - Burnout prevention tips

2. **Quiz Generation**
   - Auto-generate quizzes from content
   - Multiple difficulty levels
   - JSON-formatted questions with explanations

3. **Concept Explanation (Feynman-style)**
   - Simplify complex topics
   - Use analogies and examples
   - Adjustable simplification levels

4. **Text Summarization**
   - Condense long texts
   - Customizable target length
   - Key points extraction

5. **Flashcard Generation**
   - Create flashcards from content
   - Spaced repetition compatible
   - Auto-generate hints

6. **Exam Difficulty Prediction**
   - Analyze course content
   - Predict difficulty level
   - Provide preparation strategies

**Configuration:**
```dart
AIAPIService().initialize(
  openAIKey: 'your-key',
  anthropicKey: 'your-key',
  preferredProvider: AIProvider.anthropic,
);
```

---

## 🎮 Phase 3: Gamification & Social

### Gamification System

**Location:** `lib/features/gamification/`

**Features:**

1. **XP & Leveling**
   - Exponential level progression: `100 * (level^1.5)`
   - XP from various activities
   - Level-based rewards

2. **Badges & Achievements**
   - 10+ badge types
   - Unlock conditions
   - Premium badge themes

3. **Streaks**
   - Daily study streaks
   - Streak freeze items
   - Milestone rewards

4. **Focus Mode (Forest-style)**
   **Location:** `lib/features/gamification/presentation/screens/focus_mode_screen.dart`

   - Plant trees while studying
   - Tree dies if you leave early
   - Growth stages: Seed → Sprout → Sapling → Tree → Giant
   - Duration options: 25, 50, 90 minutes
   - XP rewards for completion
   - Distraction tracking

### Social Features

**1. Leaderboards**
**Location:** `lib/features/social/presentation/screens/leaderboard_screen.dart`

**Features:**
- Global and friends rankings
- Multiple categories: XP, Streak, Study Time, Flashcards, Quizzes
- Top 3 medal display (🥇🥈🥉)
- Rank change tracking
- Current user highlight

**2. Study Groups**
**Location:** `lib/features/social/presentation/screens/study_groups_screen.dart`

**Features:**
- Create/join study groups
- Real-time group chat
- Member management
- Resource sharing (PDFs, links, notes)
- Public and private groups
- Category-based discovery

**Tabs:**
- **Chat:** Real-time messaging
- **Members:** View online status, admin badges
- **Resources:** Shared study materials

**3. Peer Challenges**
**Location:** `lib/features/social/presentation/screens/peer_challenges_screen.dart`

**Features:**
- 1v1 competitive challenges
- Challenge templates: Flashcard Sprint, Study Marathon, XP Race, Quiz Master
- Real-time progress tracking
- Custom challenge creation
- XP rewards for winners
- Challenge history

**Challenge Types:**
- Flashcards reviewed
- Study time
- XP earned
- Quizzes completed
- Focus sessions

---

## 💎 Phase 4: Premium Features

### Advanced Analytics Dashboard

**Location:** `lib/features/premium/presentation/screens/analytics_dashboard_screen.dart`

**Features:**

1. **Key Metrics**
   - Study time tracking
   - Retention rate
   - Cards reviewed
   - Focus sessions

2. **Study Time Charts**
   - Daily/weekly/monthly views
   - Bar chart visualizations
   - Trend analysis

3. **Subject Performance**
   - Per-subject breakdown
   - Progress bars
   - Score tracking

4. **Memory Retention Analysis**
   - Immediate, 1-day, 1-week, 1-month retention
   - Forgetting curve visualization
   - Personalized tips

5. **Productivity Heatmap**
   - Study activity by day and hour
   - Color-coded intensity
   - Pattern identification

6. **Learning Velocity**
   - Concepts mastered per week
   - Velocity trends
   - Performance comparisons

7. **Goal Progress**
   - Visual goal tracking
   - Progress percentages
   - Multiple goal support

### Premium Features Management

**Location:** `lib/features/premium/presentation/screens/premium_features_screen.dart`

**Subscription Tiers:**
- **Free:** Limited features
- **Monthly:** $9.99/month
- **Yearly:** $79.99/year (Save 33%)

**Premium Benefits:**
- Unlimited flashcard decks
- Unlimited AI queries
- Advanced analytics
- Export to PDF/CSV/JSON
- Cloud sync (unlimited devices)
- Custom badge themes
- Priority support
- Offline mode
- Unlimited study groups

**Export Capabilities:**
- PDF: Comprehensive study reports
- CSV: Raw data for analysis
- JSON: Complete data backup

**Custom Themes:**
- Classic 🎯
- Galaxy 🌌
- Sunset 🌅
- Forest 🌲
- Ocean 🌊
- Fire 🔥

---

## 💾 Cloud Sync

**Location:** `lib/core/services/cloud_sync_service.dart`

**Features:**
- Firebase/Firestore integration
- Bidirectional synchronization
- Conflict resolution (last-write-wins)
- Offline queue for pending operations
- Real-time listeners
- Multi-device support

**Sync Operations:**
```dart
// Full sync with conflict resolution
final result = await CloudSyncService().performFullSync(
  localData: myLocalData,
);

// Queue operation for offline sync
CloudSyncService().queueOperation(
  SyncOperation(type: 'create', entity: 'flashcard', data: card),
);
```

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── core/
│   ├── services/
│   │   └── cloud_sync_service.dart
│   └── widgets/
│       └── glass_card.dart
├── features/
│   ├── flashcards/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── services/
│   │   └── presentation/
│   ├── notes/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── cornell_notes_screen.dart
│   │           ├── reading_workflow_screen.dart
│   │           ├── feynman_technique_screen.dart
│   │           └── mind_map_editor_screen.dart
│   ├── ai_coach/
│   │   ├── data/
│   │   │   └── ai_api_service.dart
│   │   └── domain/
│   ├── gamification/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── screens/
│   │           └── focus_mode_screen.dart
│   ├── social/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── leaderboard_screen.dart
│   │           ├── study_groups_screen.dart
│   │           └── peer_challenges_screen.dart
│   └── premium/
│       └── presentation/
│           └── screens/
│               ├── analytics_dashboard_screen.dart
│               └── premium_features_screen.dart
```

### Clean Architecture Layers

1. **Domain Layer**
   - Entities: Core business objects
   - Services: Business logic

2. **Data Layer**
   - API integration
   - Data sources

3. **Presentation Layer**
   - Screens
   - Widgets
   - State management

---

## 🎨 Design System

### Glass Card Widget

**Location:** `lib/core/widgets/glass_card.dart`

Provides consistent glassmorphic design across the app.

### Color Scheme

- **Primary:** Blue (#2196F3)
- **Secondary:** Purple (#9C27B0)
- **Success:** Green (#4CAF50)
- **Warning:** Orange (#FF9800)
- **Error:** Red (#F44336)
- **Premium:** Amber (#FFC107)

---

## 📊 Algorithms & Science

### SuperMemo 2 Algorithm

```dart
// Ease factor calculation
if (quality >= 3) {
  easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
}
easeFactor = max(1.3, easeFactor);

// Interval calculation
if (quality < 3) {
  interval = 1;
} else if (repetitions == 0) {
  interval = 1;
} else if (repetitions == 1) {
  interval = 6;
} else {
  interval = (previousInterval * easeFactor).round();
}
```

### XP Leveling Formula

```dart
// Exponential progression for balanced difficulty
int xpForLevel(int level) {
  return (100 * pow(level, 1.5)).round();
}
```

---

## 🔐 Security & Privacy

- API keys stored securely (not in version control)
- User data encrypted in transit
- GDPR compliant data handling
- Option to export all user data
- Account deletion support

---

## 🚀 Performance

- Lazy loading for large datasets
- Efficient state management
- Image caching
- Database indexing
- Optimized animations (60 FPS target)

---

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- 🚧 Web (planned)
- 🚧 Desktop (planned)

---

## 🔮 Future Roadmap

### Planned Features

1. **Voice Notes**
   - Record and transcribe lectures
   - AI-powered summarization

2. **PDF Annotation**
   - Highlight and annotate textbooks
   - OCR for image text extraction

3. **Study Music Integration**
   - Binaural beats
   - Focus playlists
   - Pomodoro timer integration

4. **LMS Integration**
   - Canvas, Blackboard, Moodle
   - Auto-import assignments
   - Grade tracking

5. **Wearable Support**
   - Apple Watch/Wear OS
   - Study session quick start
   - Streak reminders

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👥 Contributors

Built with ❤️ by the StudyBuddy team

---

## 📞 Support

- Email: support@studybuddy.app
- Discord: discord.gg/studybuddy
- Twitter: @studybuddyapp

---

**Last Updated:** 2025-11-16
**Version:** 1.0.0
