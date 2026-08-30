# SportsBuzz — University Fest Live Scoring & Streaming Platform

**SportsBuzz** is a zero-cost, high-concurrency real-time sports scoring and live-streaming platform tailored for university fests, college tournaments, and athletic meets. Built with a unified **Flutter** cross-platform codebase compiling to both a Progressive Web App (for thousands of live spectators) and mobile apps (for event admins and field scorers).

---

## Key Features

- **Strict Hierarchical Architecture**:
  `Fest / Event` ➔ `Sports` (Indoor / Outdoor) ➔ `Matches / Fixtures` ➔ `Live Scoreboard State`
- **Dynamic Polymorphic Sport Scoring Engine**:
  - **Cricket**: Runs, Wickets, Overs, Striker/Non-Striker stats, Bowler figures, **Free Hit on No Balls**, **Wide Ball extra ball rules**, dismissal constraints on Free Hits (Run Out only), and automatic strike rotation.
  - **Football / Soccer / Hockey**: Match clock timer (Start/Pause), Goals, Half-time/Full-time/Extra-time/Penalties, **2nd Yellow Card auto-red rule**, and foul tracking.
  - **Volleyball / Badminton / Table Tennis / Tennis**: Sets Won, Set Points, Serve indicator, **Automatic Deuce (24-24 / 20-20)**, **Advantage states**, and **2-point clear lead enforcement**.
  - **Basketball**: 1pt (Free Throw), 2pt (Field Goal), 3pt (Beyond Arc), Quarter management (Q1-Q4), and **Team Foul Bonus warning (at 5 fouls)**.
  - **Chess / Carrom**: Dual chess timers, Active turn tracking, move count, checkmate/resignation/draw states, and carrom coin counters.
  - **Tug of War / Athletics**: Round pull tracking, finish timestamps, and sprint placings.
- **Match Fixture Management**:
  - Full-width, single-column scheduling form.
  - Interactive **Date & Time Pickers** (`showDatePicker` & `showTimePicker`).
  - **Edit Match Details**: Modify teams, stage, venue, stream URL, scheduled time, and status anytime.
  - **Delete Match Fixture**: Confirmation modals with complete database cleanup.
- **Live Video Streaming Integration**:
  - YouTube Live / RTMP embedding synced directly with real-time score feeds.
  - Optional **6-second video sync buffer toggle** to match YouTube broadcast lag for viewers.
- **High-Capacity Fanout Architecture**:
  - Handles 100,000+ concurrent spectators at zero server cost using Supabase Realtime Broadcast combined with Cloudflare Edge Workers / Pages proxying.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend & Mobile** | Flutter 3.x (Dart) |
| **State Management** | Flutter Riverpod (`StateNotifier`, `AsyncValue`, Auto-Dispose) |
| **Routing** | GoRouter |
| **Database & Auth** | Supabase (PostgreSQL, JSONB polymorphic storage, Row Level Security) |
| **Real-time Sync** | Supabase Realtime Broadcast Channels (WebSockets) |
| **Edge Scaling** | Cloudflare Workers & Cloudflare Pages (Free Tier) |
| **Icons & Design System**| Lucide Icons (`lucide_icons_flutter`), Modern High-Contrast Palette |

---

## Supabase Database Setup & Deployment

Follow these steps to deploy the database schema and enable Realtime Broadcast:

### 1. Create a Supabase Project
1. Log in to [Supabase Dashboard](https://database.new).
2. Click **New project**, choose a name (e.g. `sportsbuzz-db`), set a strong database password, and choose your preferred region.

### 2. Run the Database Schema Script
1. Navigate to the **SQL Editor** tab in the Supabase Dashboard.
2. Click **New Query**.
3. Copy the entire contents of [`supabase/schema.sql`](supabase/schema.sql) and paste it into the editor.
4. Click **Run** (or press `Ctrl + Enter`).
5. Verify that all 4 tables (`events`, `sports`, `matches`, `match_state`), types, indexes, and triggers were created successfully.

### 3. Verify Realtime Publication
The script automatically adds `match_state` and `matches` to the `supabase_realtime` publication:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE matches;
ALTER PUBLICATION supabase_realtime ADD TABLE match_state;
```
You can verify this under **Database** ➔ **Publications** ➔ `supabase_realtime`.

### 4. Configure App Credentials
Obtain your **Project URL** and **Anon Public Key** from **Project Settings** ➔ **API**.
Pass them to the app at build time or configure them in `lib/core/supabase/supabase_config.dart`:
```dart
const supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
const supabaseAnonKey = 'YOUR_ANON_PUBLIC_KEY';
```

---

## Cloudflare Edge Fanout Proxy (Unlimited Viewers)

To scale live broadcasts from Supabase's free 200 concurrent WebSocket limit to **thousands of simultaneous viewers**:

1. Install Cloudflare Wrangler CLI:
   ```bash
   npm install -g wrangler
   ```
2. In `wrangler.toml`, configure your route and deploy the edge fanout worker:
   ```bash
   wrangler deploy
   ```
3. The worker caches snapshot queries at the edge (with a 1-second TTL) and fans out WebSocket broadcasts to edge nodes globally at zero server cost.

---

## Web & Mobile App Deployment

### 1. Deploying the Web Viewer (Cloudflare Pages / Vercel)
Build the optimized production web bundle:
```bash
flutter build web --release --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```
Deploy the `build/web` directory to **Cloudflare Pages**:
```bash
npx wrangler pages deploy build/web --project-name=sportsbuzz
```
*Alternatively, connect your GitHub repository to Cloudflare Pages or Vercel and set the build output directory to `build/web`.*

### 2. Building and Installing the Android App (Admin & Scorer App)
To compile the production Android APK:
```bash
flutter build apk --release
```
To install directly to a connected Android device via ADB:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Local Development & Testing

### Running the App
```bash
# Run on connected Android device / Emulator
flutter run -d <device-id>

# Run in Chrome (Web Viewer)
flutter run -d chrome
```

### Running Automated Tests
```bash
flutter test
```
All unit tests for sport scoring models, set deuce calculators, and cricket delivery engines will execute and validate.

---

## Directory Structure

```
lib/
├── core/
│   ├── constants/        # AppColors, Typography, AppConstants
│   ├── network/          # WebSocket client & Edge Fanout Service
│   ├── router/           # GoRouter route declarations
│   └── supabase/         # Supabase client initialization & fallback mocks
├── features/
│   ├── events/           # Event DAO, Models, Riverpod Providers
│   ├── matches/          # Match DAO, MatchState DAO, Polymorphic SportScore models
│   │   └── models/       # run_based_score, time_based_score, set_based_score, etc.
│   └── sports/           # Sport DAO, Models, ScoringModel definitions
└── presentation/
    ├── common/           # StatusBadge, EmptyStateView, VideoPlayerEmbed
    ├── screens/
    │   ├── admin/        # AdminDashboard, AdminEventDetail, AdminScoringScreen
    │   │   ├── dialogs/  # CreateEventDialog, CreateSportDialog, CreateMatchDialog, EditMatchDialog
    │   │   └── scorepads/# run_based_scorepad, set_based_scorepad, time_based_scorepad, etc.
    │   ├── event_landing_screen.dart # Public fest landing view
    │   ├── home_screen.dart          # Public home view
    │   └── viewer_match_screen.dart  # Public live match spectator view
    └── widgets/
        └── scoreboards/  # Viewer scoreboards (run_based, set_based, time_based, etc.)
```
