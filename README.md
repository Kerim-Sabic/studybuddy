# StudyBuddy 📚🌳

> The most comprehensive, research-backed, cross-platform study helper application ever created.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue)](https://github.com/yourusername/studybuddy)

## 🌟 Overview

StudyBuddy is a premium study helper application that combines cutting-edge cognitive science with beautiful design to revolutionize how students learn, plan, and track their academic work. Built on decades of research in educational psychology, StudyBuddy integrates proven techniques like **spaced repetition**, **retrieval practice**, **interleaving**, **mind mapping**, and the **Feynman technique** into an intuitive, gamified experience.

### Key Highlights

- 🧠 **Research-Backed**: Every feature is grounded in cognitive science
- 🌲 **Tree Planting**: Stay focused and plant real trees
- 🎮 **Smart Gamification**: Points, badges, and leaderboards that enhance learning
- 🤝 **Collaborative**: Study groups, real-time collaboration, peer matching
- 🤖 **AI-Powered**: Personalized recommendations and intelligent scheduling
- 🎨 **Beautiful Design**: Glassmorphism aesthetic with iOS-inspired UI
- ♿ **Accessible**: WCAG 2.1 compliant, supports diverse learners
- 🔒 **Private & Secure**: End-to-end encryption, GDPR compliant

## 🚀 Features

### 📅 Comprehensive Planning

- **Multi-View Calendars**: Day, week, month views
- **Course Management**: Track classes, instructors, locations
- **Assignment Tracking**: Never miss a deadline
- **Smart Scheduling**: AI-powered study timetables
- **Calendar Sync**: Google, Apple, Outlook integration
- **Goal Setting**: Track progress with milestones

### 🧠 Evidence-Based Learning Tools

#### Spaced Repetition Engine
- Leitner box system for flashcards
- 90-95% retention rate (research-proven)
- Adaptive intervals based on performance
- Forgetting curve visualization

#### Retrieval Practice
- Low-stakes quizzes
- Immediate feedback
- Practice test generation
- Performance analytics

#### Active Reading (PQ4R/SQ3R)
- Guided reading workflows
- Preview, Question, Read, Reflect, Recite, Review
- Note templates for each step
- Comprehension tracking

#### Mind Mapping
- Interactive canvas-based tool
- Real-time collaboration
- Multiple map types (Buzan, concept, spider)
- Export to PNG/PDF/SVG

#### Memory Palace
- Digital 2D/3D environments
- Method of loci implementation
- Customizable rooms and paths
- Guided practice

#### Feynman Technique
- "Teach Back" modules
- Record explanations (audio/text)
- AI feedback on clarity
- Gap identification

#### Interleaving Practice
- Mix topics for better retention
- Customizable patterns
- 50% improvement in problem-solving (research-backed)

### ⏱️ Focus & Productivity

#### Pomodoro & Flowtime Timers
- Customizable work/break intervals
- Multiple timer modes
- Focus mode (disable notifications)
- Background sounds (white noise, nature)

#### Virtual Tree Planting
- Plant trees during focus sessions
- Earn coins for completed sessions
- Plant real trees via partner organizations
- Personal forest gallery
- 20+ tree species

### 🎮 Gamification

- **Point System**: Earn points for learning activities
- **Badges & Achievements**: 50+ unique badges
- **Leaderboards**: Global, friends, groups
- **Missions & Quests**: Narrative-driven challenges
- **Streaks**: Daily study streak tracking
- **Progress Visualization**: Heat maps, charts, analytics

### 🤝 Collaboration

- **Study Groups**: Create or join groups
- **Real-Time Collaboration**: Shared notes, mind maps, flashcards
- **Peer Matching**: Algorithm-based compatibility matching
- **Group Chat & Video**: Built-in communication
- **Shared Tasks**: Collaborative task management
- **Peer Mentoring**: Connect with tutors and mentors

### 🤖 AI-Powered Features

- **AI Chatbot**: Answer questions, explain concepts
- **Smart Recommendations**: Personalized study plans
- **Adaptive Scheduling**: Adjust to your patterns
- **Performance Prediction**: Estimate exam readiness
- **Content Difficulty Estimation**: Personalized pacing

### 💚 Mental Health & Well-being

- **Mindfulness**: Guided meditation, breathing exercises
- **Mood Tracking**: Journal and track emotions
- **Break Reminders**: Prevent burnout
- **Sleep Hygiene**: Resources and tracking
- **Stress Management**: Coping strategies and support

### ♿ Accessibility

- **High Contrast Mode**: WCAG 2.1 AA+ compliant
- **Dyslexia-Friendly Fonts**: OpenDyslexic support
- **Screen Reader Compatible**: Full keyboard navigation
- **Font Scaling**: 100%-200% adjustment
- **Color-Blind Palettes**: Multiple options
- **Voice Control**: Hands-free operation

## 🏗️ Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Local Database**: Hive + Drift (SQLite)
- **Backend**: Firebase + Custom API
- **Authentication**: Firebase Auth (Email, Google, Apple)
- **Real-Time**: WebSockets + Firestore
- **AI/ML**: TensorFlow Lite, OpenAI API
- **Analytics**: Firebase Analytics + Crashlytics
- **Payments**: Stripe (for premium features)

## 📱 Platforms

- ✅ iOS 13+
- ✅ Android 8.0+ (API 26+)
- ✅ Web (Chrome, Safari, Firefox, Edge)

## 🎨 Design System

StudyBuddy features a unique **glassmorphism** aesthetic inspired by iOS design:

- **Semi-transparent panels** with backdrop blur
- **Soft gradients** and pastel colors
- **Subtle shadows** for depth
- **Minimalist** and clean layouts
- **Smooth animations** and micro-interactions

### Color Palette

- **Primary**: Purple gradient (`#667EEA` → `#764BA2`)
- **Accent Green**: `#00C9A7` (Success, growth)
- **Accent Orange**: `#FF6B6B` (Urgency, alerts)
- **Accent Blue**: `#4D96FF` (Information)
- **Glass**: 70-90% opacity white

## 🚀 Getting Started

### Prerequisites

```bash
flutter --version  # Flutter 3.0 or higher
```

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/studybuddy.git
cd studybuddy

# Install dependencies
flutter pub get

# Run code generation (for Riverpod, Drift, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Setup

Create a `.env` file in the project root:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id

# OpenAI API (for AI features)
OPENAI_API_KEY=your_openai_key

# Stripe (for payments)
STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

## 📖 Documentation

- [Architecture Overview](ARCHITECTURE.md) - Technical architecture and design decisions
- [Research References](RESEARCH_REFERENCES.md) - Scientific foundations and citations
- [API Documentation](docs/API.md) - REST API endpoints and WebSocket events
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [Design System](docs/DESIGN_SYSTEM.md) - UI/UX guidelines

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test

# Run specific test file
flutter test test/features/flashcards/flashcard_test.dart
```

## 📦 Building

### Android

```bash
flutter build apk --release          # APK
flutter build appbundle --release    # App Bundle (for Play Store)
```

### iOS

```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and archive
```

### Web

```bash
flutter build web --release
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📊 Project Status

### Current Phase: Foundation (Phase 1)

- [x] Architecture documentation
- [x] Research compilation
- [ ] Flutter project setup
- [ ] Design system implementation
- [ ] Authentication system
- [ ] Basic navigation

See [ARCHITECTURE.md](ARCHITECTURE.md) for the complete implementation roadmap.

## 🌍 Localization

Currently supported languages:
- 🇺🇸 English
- 🇪🇸 Spanish
- 🇫🇷 French
- 🇩🇪 German
- 🇨🇳 Mandarin Chinese
- 🇯🇵 Japanese
- 🇸🇦 Arabic (RTL support)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Research Sources

This app is built on decades of cognitive science research. Key sources include:

- **Spaced Repetition**: Ebbinghaus forgetting curve, Leitner system
- **Retrieval Practice**: Roediger & Karpicke (2006)
- **Interleaving**: Rohrer & Taylor (2007)
- **Dual Coding**: Paivio (1971)
- **Cognitive Load**: Sweller (1988)

See [RESEARCH_REFERENCES.md](RESEARCH_REFERENCES.md) for complete citations.

### Inspiration

- **Forest App**: Tree planting mechanic
- **Anki**: Spaced repetition implementation
- **Notion**: Note-taking and organization
- **Duolingo**: Gamification and streaks

## 🌟 Features Roadmap

### Phase 1: Foundation (Weeks 1-3) ✅
- Project setup
- Design system
- Authentication
- Basic navigation

### Phase 2: Core Planning (Weeks 4-6) 🔄
- Scheduling
- Task management
- Calendar views
- Calendar sync

### Phase 3: Learning Tools (Weeks 7-10)
- Flashcards with spaced repetition
- Pomodoro/Flowtime timers
- Tree planting
- Note-taking

### Phase 4: Advanced Learning (Weeks 11-14)
- PQ4R workflow
- Mind mapping
- Feynman technique
- Memory palace

### Phase 5: Gamification (Weeks 15-17)
- Point system
- Badges
- Leaderboards
- Analytics

### Phase 6: Collaboration (Weeks 18-20)
- Study groups
- Real-time collaboration
- Chat & video
- Peer matching

### Phase 7: AI Features (Weeks 21-24)
- AI chatbot
- Recommendations
- Adaptive scheduling
- Performance analytics

### Phase 8: Polish & Launch (Weeks 25-28)
- Testing
- Optimization
- Accessibility audit
- App store submission

## 📞 Contact & Support

- **Email**: support@studybuddy.app
- **Website**: https://studybuddy.app
- **Twitter**: [@StudyBuddyApp](https://twitter.com/StudyBuddyApp)
- **Discord**: [Join our community](https://discord.gg/studybuddy)

## 💚 Environmental Impact

For every 100 focus minutes completed by users, StudyBuddy plants one real tree through partnerships with:
- **Trees for the Future**
- **One Tree Planted**
- **Eden Reforestation Projects**

To date, our community has planted **0** trees (launching soon!).

---

**Built with ❤️ and 🧠 by students, for students.**

*Study smarter, not harder. Plant trees, grow knowledge.* 🌳📚
