# LinguaVoice — Full UI Specification
> A Duolingo-style language learning app with voice-first interaction.
> 12 languages: Spanish, French, Mandarin, Japanese, German, Portuguese, Korean, Arabic, Hindi, Italian, Russian, Hausa.

---

## Design System

### Color Palette
```
Primary:        #5B4FE8   (deep violet — intelligence, focus)
Primary Light:  #7B72F0   (hover/active states)
Primary Dark:   #3D33C4   (pressed states)

Accent:         #F5A623   (warm amber — energy, rewards, streaks)
Accent Light:   #FFD080   (XP fills, progress bars)

Success:        #2ECC71   (correct answers, completions)
Error:          #E74C3C   (wrong answers, mic errors)
Warning:        #F39C12   (partial correct, hints)

Background:     #F7F6FF   (off-white with violet tint)
Surface:        #FFFFFF   (cards, modals)
Surface Alt:    #EDEEFF   (subtle card backgrounds)

Text Primary:   #1A1833   (near-black with violet undertone)
Text Secondary: #6B6882   (subtitles, labels)
Text Disabled:  #B0AEBF   (inactive)
Text On Dark:   #FFFFFF
```

### Typography
```
Display Font:   "Nunito" — rounded, friendly, confident
Body Font:      "Inter" — clean, readable at small sizes
Mono Font:      "JetBrains Mono" — for romanization/transliteration

Scale:
  displayLarge:   32sp, Nunito, weight 800
  displayMedium:  26sp, Nunito, weight 700
  titleLarge:     22sp, Nunito, weight 700
  titleMedium:    18sp, Nunito, weight 600
  bodyLarge:      16sp, Inter, weight 400
  bodyMedium:     14sp, Inter, weight 400
  labelLarge:     14sp, Inter, weight 600
  labelSmall:     11sp, Inter, weight 500
  romanization:   13sp, JetBrains Mono, weight 400, color Text Secondary
```

### Spacing Scale
```
xs:   4dp
sm:   8dp
md:   16dp
lg:   24dp
xl:   32dp
xxl:  48dp
```

### Border Radius
```
sm:   8dp
md:   16dp
lg:   24dp
full: 999dp (pills)
```

### Elevation / Shadows
```
card:   0dp offset, 8dp blur, color #5B4FE8 at 8% opacity
button: 0dp offset, 4dp blur, color #5B4FE8 at 20% opacity
modal:  0dp offset, 24dp blur, color #000 at 16% opacity
```

### Animation Durations
```
micro:    150ms  (button press, toggle)
standard: 300ms  (screen transitions, card flip)
emphasis: 500ms  (correct answer celebration, streak)
```

---

## 1. Splash Screen

**File:** `splash_screen.dart`

**Background:** Solid `#5B4FE8` (Primary)

**Layout (centered column):**
- App logo: 80×80dp rounded square, white background, violet globe icon with speech bubble overlay
- App name: "LinguaVoice" — displayLarge, white, Nunito 800
- Tagline: "Speak. Learn. Belong." — bodyLarge, white at 70% opacity
- Loading indicator: 3 animated dots (pulse animation), amber `#F5A623`, 8dp each, 8dp gap, bottom 48dp from bottom

**Behavior:**
- Auto-navigate after auth check (max 2.5s)
- Fade in logo + name at 300ms
- Tagline fades in at 600ms

---

## 2. Onboarding Screen

**File:** `onboarding_screen.dart`

**3 pages, PageView with dot indicator**

### Page 1 — "Speak from Day One"
- Illustration: animated mic with sound waves radiating (Lottie), 240dp tall, centered
- Title: "Speak from Day One" — displayMedium, Primary, centered
- Body: "Practice real conversations with an AI tutor that listens, corrects, and encourages you." — bodyLarge, Text Secondary, centered, 24dp padding
- Wave bottom decoration: soft violet wave SVG

### Page 2 — "12 Languages, One App"
- Illustration: 4×3 grid of circular language flags (40dp each), animated stagger-in
- Title: "12 Languages, One App"
- Body: "From Spanish to Hausa, pick your language and start learning in minutes."

### Page 3 — "Track Every Win"
- Illustration: Lottie streak fire animation + XP bar filling up
- Title: "Track Every Win"
- Body: "Earn XP, keep your streak alive, and watch your fluency grow day by day."

**Bottom bar (all pages):**
- Dot indicators: 3 dots, active = 24dp wide pill (Primary), inactive = 8dp circle (Text Disabled)
- "Next" button (pages 1–2): full-width, height 56dp, Primary bg, white text, radius full
- "Get Started" button (page 3): full-width, height 56dp, Accent bg, dark text, radius full
- "Skip" text button: top-right corner, labelLarge, Text Secondary

---

## 3. Language Picker Screen

**File:** `language_picker_screen.dart`

**AppBar:**
- Back arrow (if returning user)
- Title: "What do you want to learn?" — titleLarge
- No elevation

**Subtitle:** "Pick a language to get started. You can add more later." — bodyMedium, Text Secondary, 16dp horizontal padding

**Language Grid:**
- 2 columns, GridView
- Each cell: `LanguageCard` widget (see below)
- 16dp padding all sides, 12dp gap between cells

### LanguageCard Widget
```
Container:
  width: full column width
  height: 100dp
  background: Surface (#FFFFFF)
  border-radius: md (16dp)
  shadow: card shadow
  border: 1.5dp solid transparent (selected: Primary)
  padding: 16dp

Layout (Column, centered):
  Row (top):
    - Flag emoji or circular flag image: 32dp
    - Language name: titleMedium, Text Primary
    - Spacer
    - Checkmark icon (visible only when selected): 20dp, Primary color

  Spacer

  Row (bottom):
    - "X million speakers" — labelSmall, Text Secondary
    - Difficulty pill: "Beginner friendly" / "Intermediate" — labelSmall,
      background Surface Alt, radius full, 4dp vertical 8dp horizontal padding
```

**Languages + details:**
```
Spanish     🇪🇸  485M speakers   Beginner friendly
French      🇫🇷  280M speakers   Beginner friendly
Mandarin    🇨🇳  1.1B speakers   Challenging
Japanese    🇯🇵  125M speakers   Challenging
German      🇩🇪  100M speakers   Intermediate
Portuguese  🇧🇷  260M speakers   Beginner friendly
Korean      🇰🇷  77M speakers    Intermediate
Arabic      🇸🇦  310M speakers   Challenging
Hindi       🇮🇳  600M speakers   Intermediate
Italian     🇮🇹  65M speakers    Beginner friendly
Russian     🇷🇺  258M speakers   Intermediate
Hausa       🇳🇬  100M speakers   Beginner friendly
```

**Bottom:**
- "Continue" button: full-width, 56dp, Primary, disabled until selection made
- Disabled state: Primary at 40% opacity, no shadow

---

## 4. Auth Screens

### 4a. Login Screen
**File:** `login_screen.dart`

**Layout (SingleChildScrollView, Column):**

Top section (40% of screen):
- Background: `#5B4FE8` with subtle diagonal pattern (5% white lines)
- Centered logo (48dp) + "LinguaVoice" — titleLarge, white
- Curved bottom clip (ClipPath), 32dp curve

Form section:
- "Welcome back" — displayMedium, Text Primary, 24dp top padding
- "Sign in to continue your streak" — bodyMedium, Text Secondary

Fields (each with 16dp bottom margin):
```
Email field:
  height: 56dp
  border: 1.5dp solid #E0DFEA
  border-radius: md (16dp)
  focused border: Primary
  prefix icon: mail_outline, Text Secondary
  label: "Email address"
  keyboard: emailAddress

Password field:
  Same as above
  prefix icon: lock_outline
  suffix icon: visibility toggle (eye)
  label: "Password"
  obscureText: true
```

- "Forgot password?" — labelLarge, Primary, right-aligned
- "Sign In" button: full-width, 56dp, Primary, "Sign In" white Nunito 600
- Divider: "— or continue with —" — labelSmall, Text Secondary
- Google sign-in button: outlined, 56dp, white bg, Google logo + "Continue with Google"
- Bottom: "Don't have an account? **Sign up**" — bodyMedium, Text Secondary, "Sign up" in Primary

### 4b. Register Screen
**File:** `register_screen.dart`

Same structure as login, fields:
- Full name
- Email address
- Password
- Confirm password

Button: "Create Account"
Bottom: "Already have an account? **Sign in**"

---

## 5. Home / Dashboard Screen

**File:** `home_screen.dart`

**Bottom Navigation Bar:**
```
4 tabs:
  Home     — house icon
  Learn    — book-open icon
  Practice — mic icon
  Progress — bar-chart icon

Active tab: Primary color icon + Primary underline indicator (3dp, radius full)
Inactive: Text Disabled icon
Bar background: white, top shadow
Height: 64dp + safe area
Label: labelSmall, 4dp below icon
```

**Home Tab Layout:**

### Top Section — Greeting Header
```
Background: gradient (Primary → Primary Light), 200dp tall
Shape: bottom rounded corners, radius 32dp

Content (padding 20dp):
  Row:
    Column:
      "Good morning, Lisa 👋" — titleMedium, white
      "You're on a 7-day streak!" — bodyMedium, white 80%
    Spacer
    Avatar circle: 44dp, white border 2dp, user initials or photo

Streak Row (below greeting, inside header):
  🔥 icon (28dp animated)  "7" — displayMedium white  "day streak" — bodyMedium white 70%
  |  divider  |
  ⭐ "1,240 XP" — titleMedium white
  |  divider  |
  🏆 "Level 5" — titleMedium white
```

### Daily Goal Card
```
Margin: 16dp, -32dp top (overlaps header)
Background: white
Border-radius: lg (24dp)
Shadow: card shadow
Padding: 20dp

Title: "Today's Goal" — labelLarge, Text Secondary
Progress: "3 / 5 lessons" — titleMedium, Text Primary

LinearProgressIndicator:
  value: 0.6
  height: 10dp
  border-radius: full
  background: Surface Alt
  valueColor: Accent (#F5A623)

Row (below bar):
  "2 more to hit your daily goal" — bodyMedium, Text Secondary
  Spacer
  "Change goal" — labelLarge, Primary
```

### Continue Learning Card
```
Margin: 16dp horizontal, 12dp vertical
Background: Primary
Border-radius: lg (24dp)
Padding: 20dp

Row:
  Column:
    "Continue" — labelSmall, white 70%
    "Spanish — Lesson 12" — titleMedium, white
    "Restaurant Conversations" — bodyMedium, white 70%
    12dp gap
    "Continue" pill button: white bg, Primary text, 36dp height, radius full, 120dp wide
  Spacer
  Illustration or flag emoji: 64dp, right side
```

### Lesson Categories
```
Section title: "Choose a skill" — titleMedium, Text Primary, 16dp padding

Horizontal ScrollView (no scroll indicator):
  Cards (each 140dp wide, 80dp tall, 12dp gap):
    Card 1: 🗣 "Conversation"   background: #EDE9FE  icon color: Primary
    Card 2: 📖 "Vocabulary"     background: #FEF3C7  icon color: #D97706
    Card 3: 🎭 "Role-play"      background: #DCFCE7  icon color: #16A34A
    Card 4: 🔤 "Grammar"        background: #FFE4E6  icon color: #E11D48
    Card 5: 👂 "Listening"      background: #E0F2FE  icon color: #0284C7

  Each card:
    border-radius: md (16dp)
    padding: 12dp
    Column:
      Icon: 28dp
      8dp gap
      Label: labelLarge, Text Primary
```

### Recent Vocab
```
Section title row:
  "Recent Words" — titleMedium, Text Primary
  "See all" — labelLarge, Primary

ListView (3 items, non-scrollable):
  VocabRow widget (see Vocab section for spec)
```

---

## 6. Lesson Type Screen

**File:** `lesson_type_screen.dart`

**AppBar:**
- Back arrow
- Language flag + name: "Spanish 🇪🇸" — titleMedium
- XP counter badge: amber pill, "1,240 XP ⭐"

**Layout:**

Section: "What do you want to practice?"

Grid (2 columns, 160dp card height):

```
LessonTypeCard:
  background: Surface
  border-radius: lg (24dp)
  shadow: card shadow
  padding: 20dp
  border: 2dp solid transparent (selected = Primary)

  Content (Column):
    Icon container: 48dp circle, colored background, centered icon 24dp
    12dp gap
    Title: titleMedium, Text Primary
    4dp gap
    Description: bodyMedium, Text Secondary, 2 lines max
    Spacer
    "→" arrow: Text Secondary (right aligned)

Cards:
  1. 🗣 Conversation
     icon bg: #EDE9FE, icon color: Primary
     "Chat freely with your AI tutor"

  2. 🎭 Role-play
     icon bg: #DCFCE7, icon color: #16A34A
     "Practice real-world scenarios"

  3. 📖 Vocabulary
     icon bg: #FEF3C7, icon color: #D97706
     "Learn and review new words"

  4. 🔤 Grammar
     icon bg: #FFE4E6, icon color: #E11D48
     "Fix your grammar with guidance"

  5. 👂 Listening
     icon bg: #E0F2FE, icon color: #0284C7
     "Train your ear, improve comprehension"

  6. 🎤 Pronunciation
     icon bg: #F3E8FF, icon color: #9333EA
     "Perfect your accent and tone"
```

**Difficulty Selector (below grid):**
```
Row of 3 pill buttons:
  "Beginner"  "Intermediate"  "Advanced"
  
  Active: Primary bg, white text
  Inactive: Surface Alt bg, Text Secondary
  Height: 36dp, radius full, horizontal padding 16dp
```

**Bottom:**
- "Start Lesson" button: full-width, 56dp, Primary

---

## 7. Conversation Screen

**File:** `conversation_screen.dart`

> This is the core screen — voice-first AI conversation.

**AppBar:**
```
Leading: X close icon (ends session, shows confirmation dialog)
Center:
  Column (centered):
    Language flag + name: "Spanish 🇪🇸" — labelLarge
    "Conversation Practice" — labelSmall, Text Secondary
Trailing:
  XP earned this session: "+45 XP ⭐" amber pill
```

**Chat Area (Expanded, ListView):**
```
Padding: 16dp horizontal, 8dp vertical
Messages scroll from bottom

ChatBubble widget — AI message:
  Alignment: left
  Row:
    Avatar: 32dp circle, Primary bg, robot/star icon white 16dp
    12dp gap
    Column:
      Container:
        max-width: 75% of screen
        background: Surface (#FFFFFF)
        border-radius: 4dp top-left, 16dp top-right, 16dp bottom-right, 16dp bottom-left
        padding: 12dp 16dp
        shadow: card shadow
        
        Text: bodyLarge, Text Primary
        
        [if has romanization]
        4dp gap
        Romanization text: romanization style (JetBrains Mono 13sp, Text Secondary)
        
        [if has translation]
        4dp gap
        Translation: bodyMedium, Text Secondary, italic

      8dp gap
      Row:
        Timestamp: labelSmall, Text Disabled
        8dp gap
        Play audio icon: 16dp, Primary (tapping replays AI audio)

ChatBubble widget — User message:
  Alignment: right
  Container:
    max-width: 75%
    background: Primary (#5B4FE8)
    border-radius: 16dp top-left, 4dp top-right, 16dp bottom-left, 16dp bottom-right
    padding: 12dp 16dp
    
    Text: bodyLarge, white

  Row (below bubble, right-aligned):
    Timestamp: labelSmall, Text Disabled
    8dp gap
    [if corrections exist] "See corrections" — labelSmall, Accent, tappable

CorrectionCard widget (appears below user bubble if corrections):
  background: #FFF8E7
  border-radius: md (16dp)
  border-left: 4dp solid Accent
  padding: 12dp 16dp
  margin: 4dp left (slight indent)

  Row:
    ⚠️ icon: 16dp, Accent
    8dp gap
    Column:
      "Correction" — labelLarge, #D97706
      4dp gap
      "You said: [original]" — bodyMedium, Text Secondary
      "Better: [correction]" — bodyMedium, Text Primary, bold
      "Why: [explanation]" — bodyMedium, Text Secondary, italic
```

**Typing Indicator (AI is thinking):**
```
Same layout as AI bubble
Content: 3 animated dots (bounce stagger), 8dp each, Primary color
Shows when awaiting AI response
```

**Bottom Input Area:**
```
SafeArea bottom
Background: white
Top border: 1dp solid #E0DFEA
Padding: 12dp horizontal, 8dp vertical

Layout (Column):
  [if transcribing / has draft text]
  Transcript preview container:
    background: Surface Alt (#EDEEFF)
    border-radius: md (16dp)
    padding: 12dp
    margin-bottom: 8dp
    
    Row:
      Expanding text: bodyLarge, Text Primary, max 3 lines
      Spacer
      X clear button: 20dp icon, Text Secondary

  Main controls Row:
    [Text input - optional, for typing mode]
    Expanded TextField:
      height: 44dp
      border: 1.5dp solid #E0DFEA
      border-radius: full
      padding: 0dp 16dp
      hint: "Type or speak..." — Text Disabled
      
    12dp gap
    
    RecordButton widget:
      Size: 56dp circle
      States:
        Idle:     Primary bg, white mic icon 28dp, card shadow
        Recording: Error red (#E74C3C) bg, white stop square 20dp,
                   pulsing ring animation (scale 1.0→1.3, opacity 1→0, 1s loop)
        Processing: Primary bg, CircularProgressIndicator white 20dp, no shadow
      
    [if has transcript text]
    12dp gap
    Send button: 44dp circle, Primary bg, white send icon 20dp

[Audio waveform — visible during recording only]
AudioWaveform widget:
  height: 40dp
  width: full
  margin-top: 8dp
  bars: 30 bars, 3dp wide, 4dp gap
  color: Primary
  animation: bars animate to microphone amplitude in real-time
  min-height per bar: 4dp, max: 36dp
```

**Session End / XP Summary Sheet (BottomSheet):**
```
Background: white
Border-radius top: 24dp
Padding: 24dp
Handle bar: 4dp × 40dp, #E0DFEA, centered top

Content:
  🎉 celebration Lottie animation: 120dp, centered
  "Great session!" — displayMedium, Text Primary, centered
  "You earned +85 XP" — titleMedium, Accent, centered
  24dp gap
  
  Stats row (3 items, dividers between):
    Column: "12" titleLarge Primary / "Exchanges" labelSmall TextSecondary
    Column: "3" titleLarge Success / "Corrections" labelSmall TextSecondary
    Column: "94%" titleLarge Accent / "Accuracy" labelSmall TextSecondary
  
  24dp gap
  "See full review" button: outlined, full-width, 52dp, Primary border + text
  12dp gap
  "Done" button: filled, full-width, 52dp, Primary bg, white text
```

---

## 8. Role-play Screen

**File:** `roleplay_screen.dart`

**Scenario Picker (before starting):**
```
AppBar: "Role-play" — titleLarge

Subtitle: "Pick a scenario to practice" — bodyMedium, Text Secondary, 16dp padding

Scenario cards (vertical list, 16dp padding):
  Each card: 80dp tall, Surface bg, radius lg, shadow, padding 16dp

  Row:
    Emoji icon container: 48dp circle, colored bg
    16dp gap
    Column:
      Title: titleMedium, Text Primary
      Subtitle: bodyMedium, Text Secondary
    Spacer
    Chevron right: Text Disabled

Scenarios:
  🍽 "At a Restaurant"     bg: #FEF3C7  "Order food, ask for the bill"
  ✈️ "At the Airport"      bg: #E0F2FE  "Check-in, find your gate"
  🛒 "At the Market"       bg: #DCFCE7  "Buy groceries, ask for prices"
  💼 "Job Interview"       bg: #EDE9FE  "Introduce yourself professionally"
  🏨 "At the Hotel"        bg: #FFE4E6  "Check-in, request room service"
  🚑 "At the Doctor"       bg: #F3E8FF  "Describe symptoms, get advice"
  📞 "Phone Call"          bg: #FEF9C3  "Make and receive a call"
```

**Active Role-play Screen:**
- Same structure as Conversation Screen
- AppBar shows scenario name: "🍽 At a Restaurant"
- AI messages show the character name: "Waiter:" prefix in labelSmall Primary
- Scene context banner at top of chat:
  ```
  Container:
    background: Surface Alt
    border-radius: md
    padding: 12dp 16dp
    margin: 8dp 16dp

    Row:
      📍 icon: 16dp, Text Secondary
      8dp gap
      "You're at a restaurant in Madrid. The waiter greets you." — bodyMedium, Text Secondary italic
  ```

---

## 9. Vocabulary Screen

**File:** `vocab_screen.dart`

**AppBar:**
- "Vocabulary" — titleLarge
- Trailing: filter icon

**Tab Bar (below AppBar):**
```
3 tabs: "All"  "To Review"  "Learned"
Indicator: Primary underline, 3dp
Label: labelLarge
Active: Primary
Inactive: Text Secondary
```

**Search Bar:**
```
Margin: 16dp, below tabs
Height: 44dp
Background: Surface Alt
Border-radius: full
Prefix: search icon, Text Secondary
Hint: "Search words..."
```

**Word List:**

```
VocabRow widget:
  Height: 72dp
  Padding: 16dp horizontal
  Bottom divider: 1dp, #F0EFF8

  Row:
    Language-colored left accent bar: 4dp wide, 40dp tall, radius full, Primary
    16dp gap
    Column (Expanded):
      Row:
        Word: titleMedium, Text Primary
        8dp gap
        Script (if applicable): bodyMedium, Text Secondary
          (e.g. Japanese: 食べる  |  Arabic: أكل  |  Hindi: खाना)
      4dp gap
      Translation: bodyMedium, Text Secondary
      4dp gap
      Romanization (if applicable): romanization style
    
    Column (right):
      Play audio icon: 20dp, Primary, tappable
      8dp gap
      Mastery indicator:
        3 circles, 10dp each, 4dp gap
        Filled (mastered reps): Primary
        Unfilled: Surface Alt border Primary
```

**Flashcard Review Mode:**
```
Card (centered, 80% screen width, 300dp tall):
  Background: white
  Border-radius: xl (32dp)
  Shadow: 0dp 12dp 32dp rgba(91,79,232,0.15)
  
  Front side:
    Center column:
      Word: displayMedium, Text Primary
      12dp gap
      Romanization: titleMedium, Text Secondary, JetBrains Mono
      24dp gap
      "Tap to reveal" — labelSmall, Text Disabled

  Back side (after tap, flip animation 300ms):
    Center column:
      Word: titleMedium, Primary
      8dp gap
      Translation: displayMedium, Text Primary
      12dp gap
      Example sentence: bodyLarge, Text Secondary, italic

Below card:
  Row (3 buttons, equal width):
    "Again" — Error red bg, white, radius md
    "Hard"  — Warning amber bg, white, radius md
    "Easy"  — Success green bg, white, radius md
  Height: 52dp each, 12dp gap
```

---

## 10. Progress Screen

**File:** `progress_screen.dart`

**AppBar:** "My Progress" — titleLarge

**Language selector pills (horizontal scroll):**
```
Margin: 0dp 16dp, 12dp bottom
Pill height: 36dp, radius full, padding 0dp 16dp

Active: Primary bg, white text, flag emoji
Inactive: Surface Alt bg, Text Secondary

Pills: All | 🇪🇸 Spanish | 🇫🇷 French | ... (each language)
```

**Stats Cards Row (horizontal scroll or 2×2 grid):**
```
StatCard widget:
  Width: 150dp
  Height: 100dp
  Background: white
  Border-radius: lg (24dp)
  Shadow: card shadow
  Padding: 16dp

  Column:
    Icon: 24dp, colored
    8dp gap
    Value: displayMedium, Text Primary, Nunito 800
    4dp gap
    Label: labelSmall, Text Secondary

Cards:
  🔥 "7" / "Day streak"        icon: Accent
  ⭐ "1,240" / "Total XP"      icon: Primary
  📚 "48" / "Lessons done"     icon: Success green
  🗣 "3.2h" / "Speaking time"  icon: #0284C7
```

**Weekly Activity Chart:**
```
Section title: "This Week" — titleMedium, 16dp padding

Chart container:
  Background: white
  Border-radius: lg (24dp)
  Padding: 20dp
  Margin: 16dp horizontal

  7 bars (Mon–Sun):
    Bar width: (available width - 6 × 8dp gap) / 7
    Max height: 80dp
    Border-radius: full
    Color: Primary (days with activity), Surface Alt (no activity)
    
    Below each bar:
      Day label: labelSmall, Text Secondary ("Mon", "Tue"...)
    
    Above active bars:
      XP amount: labelSmall, Primary ("120 XP")
  
  Today's bar: slightly wider, Primary Light color
```

**Skill Breakdown:**
```
Section title: "Skill Breakdown" — titleMedium, 16dp padding

Each skill row:
  Padding: 0dp 16dp, 12dp vertical
  
  Row:
    Skill icon: 36dp circle, colored bg, 20dp icon
    12dp gap
    Column (Expanded):
      Row:
        Skill name: labelLarge, Text Primary
        Spacer
        Level badge: "Lv.4" — labelSmall, Primary bg, white, radius full, padding 2dp 8dp
      8dp gap
      LinearProgressIndicator:
        height: 8dp
        border-radius: full
        background: Surface Alt
        value: 0.0 to 1.0
        color: skill-specific (matches icon color)
    16dp gap
    XP value: labelLarge, Text Secondary "840 XP"
```

**Recent Achievements:**
```
Section title row:
  "Achievements" — titleMedium
  "See all" — labelLarge, Primary

Horizontal scroll of AchievementCard:
  Width: 110dp
  Height: 130dp
  Background: white
  Border-radius: lg (24dp)
  Shadow: card shadow
  Padding: 12dp

  Column (centered):
    Badge emoji: 40dp
    8dp gap
    Name: labelSmall, Text Primary, centered, max 2 lines
    4dp gap
    [if unlocked] "Unlocked" — labelSmall, Success, centered
    [if locked] Progress: labelSmall, Text Disabled "3/5"

  Locked state: entire card at 50% opacity, grayscale filter
```

---

## 11. Settings Screen

**File:** `settings_screen.dart`

**AppBar:** "Settings" — titleLarge

**User Card (top):**
```
Background: Primary
Margin: 16dp
Border-radius: lg (24dp)
Padding: 20dp

Row:
  Avatar: 56dp circle, white border 2dp
  16dp gap
  Column:
    Name: titleMedium, white
    Email: bodyMedium, white 70%
  Spacer
  Edit icon: white, 24dp
```

**Settings Groups:**
```
SettingsGroup widget:
  Section header: labelLarge, Text Secondary, UPPERCASE, padding 16dp, top 24dp
  
  Container:
    Background: white
    Border-radius: lg (24dp)
    Margin: 0dp 16dp
    Shadow: card shadow

  SettingsRow widget:
    Height: 56dp
    Padding: 16dp horizontal
    Bottom divider (except last item): 1dp, #F0EFF8
    
    Row:
      Icon: 22dp, colored, 36dp circle bg (10% color)
      16dp gap
      Label: bodyLarge, Text Primary
      Spacer
      [value text if applicable]: bodyMedium, Text Secondary
      ChevronRight or Toggle

Groups:

"Learning"
  🌐 Languages          → (shows count "3 active") →
  🎯 Daily Goal         → "5 lessons/day" →
  🔔 Reminders          → toggle
  🎨 App Language       → "English" →

"Audio"
  🎤 Microphone         → toggle (enable/disable voice)
  🔊 Voice Speed        → "Normal" →
  🌍 TTS Voice          → "Default" →

"Account"
  👤 Edit Profile       →
  🔒 Change Password    →
  📊 Learning Stats     →

"Support"
  ❓ Help & FAQ         →
  📩 Send Feedback      →
  ⭐ Rate the App       →
  📋 Privacy Policy     →

"Danger Zone"
  🗑 Delete Account     → (red text, no icon bg)
  🚪 Sign Out           → (red text, no icon bg)
```

---

## 12. Lesson Result Screen

**File:** `lesson_result_screen.dart`

**Full screen, no AppBar**

**Background:** gradient top-to-bottom: Primary → Primary Light

**Content (centered column, white text):**
```
Top: 60dp padding

Lottie animation: 140dp (confetti or star burst, plays once)

Result title:
  "Perfect! 🎉"  (100%)  — displayLarge, white
  "Great job! 🌟" (80%+) — displayLarge, white
  "Keep going 💪" (<80%) — displayLarge, white

Score: "92%" — 80sp, Nunito 800, white

12dp gap
"You nailed this lesson" — bodyLarge, white 80%

48dp gap

Stats panel:
  White card, radius lg, padding 24dp, mx 24dp
  Row of 3 stats (same structure as conversation summary):
    Questions answered | Correct answers | XP earned

24dp gap

Corrections section (if any):
  Title: "Review Mistakes" — titleMedium, Text Primary
  
  Each mistake:
    background: #FFF8E7
    border-radius: md
    padding: 12dp 16dp
    margin-bottom: 8dp
    
    "✗ You answered:" — labelSmall, Error
    Wrong answer — bodyLarge, Text Primary
    "✓ Correct:" — labelSmall, Success
    Correct answer — bodyLarge, Primary, bold

Bottom buttons:
  "Next Lesson →" — full-width, 56dp, white bg, Primary text, radius full
  16dp gap
  "Back to Home" — text button, white, labelLarge
```

---

## 13. Global Widgets

### AppButton
```
Primary: Primary bg, white text, 56dp height, radius full, body shadow
Secondary: Surface bg, Primary text, 56dp height, radius full, Primary border 1.5dp
Text: no bg, Primary text, no shadow
Danger: Error bg, white text

Loading state: replaces text with 20dp white CircularProgressIndicator
Disabled: 40% opacity, no shadow, no interaction
```

### AppTextField
```
Height: 56dp
Background: white
Border: 1.5dp solid #E0DFEA
Focused border: 1.5dp Primary
Error border: 1.5dp Error
Border-radius: md (16dp)
Padding: 0dp 16dp
Label: floats above on focus (standard Flutter behavior)
Error text: 12sp, Error color, below field
```

### LanguageFlag
```
Sizes: sm (24dp), md (32dp), lg (48dp)
Shape: circle
Content: country flag emoji or custom flag image
```

### XPBadge
```
Height: 28dp
Padding: 0dp 12dp
Background: Accent Light (#FFD080)
Border-radius: full
Row: ⭐ 14dp icon + "1,240 XP" labelLarge Text Primary
```

### StreakBadge
```
Same shape as XPBadge
Background: #FFF0D9
Row: 🔥 14dp icon + "7" labelLarge Text Primary
```

---

## Micro-interactions & Animations

```
Correct answer:   green checkmark scale 0→1.2→1.0 (200ms), success sound
Wrong answer:     card shake (x: -8dp +8dp, 3 cycles, 300ms), error color flash
XP earned:       "+20 XP" floats upward, fades out (600ms), amber color
Streak increment: fire emoji bounces, counter increments with easing
Record button:    pulsing ring when recording (scale 1.0→1.4, opacity 1→0, 1s loop)
Tab switch:       icon bounces slightly on active (scale 1.0→1.2→1.0, 150ms)
Card tap:         scale 0.97 on press, 0.97→1.0 on release (100ms each)
Screen push:      slide from right (standard), pop: slide to right
Bottom sheet:     slide from bottom, backdrop blur 4dp
```

---

## RTL Support (Arabic)

```
All screens must use Directionality widget
Arabic locale: TextDirection.rtl
Affected elements:
  - Chat bubbles swap left/right alignment
  - Icons that imply direction (arrows, chevrons) must be mirrored
  - Padding/margins swap left↔right
  - Text alignment: right for RTL languages
Use Flutter's built-in RTL support: Directionality.of(context)
```

---

## Accessibility

```
All tappable targets: minimum 44×44dp
Color contrast: all text/bg pairs pass WCAG AA (4.5:1 minimum)
Screen reader labels: every icon button has Semantics(label: "...")
Reduced motion: AnimationController respects MediaQuery.disableAnimations
Font scaling: all text uses sp units, layouts tested at 1.5× font scale
```
