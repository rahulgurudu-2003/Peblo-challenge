# Peblo AI Story Buddy and Quiz Component

This repository contains the Flutter implementation for Peblo's AI Story Buddy and Quiz assessment. It features a vector-animated AI Buddy character that narrates short stories using Text-to-Speech (TTS), dynamically triggers an interactive quiz, and delivers visual and haptic success responses.

---

## Getting Started

Follow these steps to initialize and run the project locally:

1. **Generate platform-specific project configurations**:
   ```bash
   flutter create --org com.peblo.challenge --project-name peblo_challenge --platforms android,ios .
   ```
2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```
3. **Execute the application on a connected device**:
   ```bash
   flutter run
   ```

---

## Technical Documentation and Challenge Reflections

### 1. Framework Selection
* **Selected Technology:** Flutter (Dart)
* **Rationale:** Choosing Flutter ensures alignment with Peblo's mobile engineering ecosystem. Flutter compiles to native ARM machine code and interfaces with the native graphics pipeline (Impeller/Skia). This permits GPU-accelerated canvas renders (bounces, rotations, particle effects) at a consistent 60fps on resource-constrained devices, such as 3GB RAM Android handsets.

### 2. Audio-to-Quiz State Transitions
* **Architecture:** App state transitions are managed reactively via a central `StoryBuddyProvider` subclassing `ChangeNotifier`.
* **Execution Flow:** 
  1. The Text-to-Speech engine's native completion handler triggers the state transition.
  2. The provider changes the app phase from `AppPhase.ttsPlaying` to `AppPhase.quizReady`.
  3. The UI (`StoryBuddyScreen`) intercepts this phase update and uses an `AnimatedSwitcher` wrapped with a scale-fade transform and an `easeInOutBack` curve to smoothly slide out the story card and slide in the quiz card without layout layout stutters.

### 3. Data-Driven Renderer Layout
* **Dynamic Options:** Quiz components are parsed from dynamic JSON payloads via the `QuizQuestion` model.
* **Layout Adaptability:** The options view utilizes flex-based layout containers that scale automatically to support varying choice counts (3, 4, or 5 options) without hardcoded height values.
* **Theme Styling:** Option borders and markers are mapped using modulo indexes (`index % optionColors.length`) to match a clean, pastel-toned visual system.

### 4. Remote Audio Caching Approach
* **Local TTS:** The engine uses native on-device speech engines, requiring zero network overhead.
* **ElevenLabs Integration Strategy (Future):**
  * **Key Hashing:** Generate a unique MD5/SHA-256 hash representing the story string (e.g., `story_content.mp3`).
  * **File Check:** Verify if a file matching the hash exists in the local caching directory (`ApplicationDocumentsDirectory`).
  * **Network Interceptor:** If the file exists, initialize playback locally. If not, fetch the stream from the endpoint, stream the bytes directly to the file system, and play the file locally to minimize remote API costs.

### 5. Playback Loading and Exception Boundaries
* **Loading UI:** Triggering playback shifts the UI into a loading state. The button displays a progress spinner, and the robot's eye color transitions to a thinking state (teal).
* **Exception Boundaries:** If the TTS engine fails to initialize or throws a system error, the provider transitions to `AppPhase.failure`. This swaps the active widget card to a recovery view displaying a clean connection-error warning and a "Try Again" action button.

### 6. Profiling and Performance Diagnostics
* **Metrics Tracked:** Flutter DevTools was used to measure frame rendering times (FPS), UI thread latency (ms/frame), and GPU thread overhead.
* **Before Optimization:** Redrawing the entire tree during the robot's idle breathing animation caused frame times to spike to **18-20ms**, resulting in stutters on low-end hardware.
* **After Optimization:** Isolated animation ticks inside a standalone custom painter (`BuddyAvatar`) to prevent parent widget rebuilds. Frametimes dropped to **6-9ms** (locked at 60 FPS).

### 7. Resource Constraints and Optimizations
* **Asset-Free Vector Drawing:** Built Pip the Robot entirely using native vector painting code (`CustomPainter`). This eliminates memory footprints and garbage collection sweeps caused by loading Lottie JSON files or PNG assets.
* **GPU-Bound Matrix Transforms:** Breathing, blinking, and card shake transforms are offloaded directly to the hardware GPU using native animation controllers.
* **Zero Leak Lifecycle:** Added automatic teardown logic in the state provider to dispose of audio listener instances when the interface is unmounted.

### 8. Development Reflection and AI Usage
* **AI Assistance:** Utilized AI to generate basic class layouts and calculate bezier math coordinates for the vector eye shapes.
* **Rejected Suggestion:** The AI recommended using Lottie for animations. This was rejected because parsing Lottie JSON strings at runtime creates CPU stutters and garbage collection overhead on 3GB RAM devices. Re-implementing animations directly inside a CustomPainter canvas is more lightweight.
* **Fixes & Refinements:** Lowered the default TTS rate to `0.38` and increased pitch to `1.35 - 1.45` to generate a high-pitched child-like narration. Created a regex-based helper that strips emojis from the text stream before passing it to the TTS engine so the narrator does not read emoji names aloud.
