# Calorie Calculator App - Complete Project Documentation

A comprehensive Flutter application for tracking daily calories and water intake with a modern dark theme and neon aesthetic.

## 📋 Project Overview

This is a **calorie tracking mobile application** built with Flutter that allows users to:
- Track daily calorie intake with a visual progress indicator
- Monitor water consumption
- View historical data with immutable past records
- Manage user profile (weight, height, calorie limit)
- Add/edit/delete food entries
- Search through a built-in food database

---

## 🏗️ Architecture & Design Principles

### 1. **Clean Architecture Pattern**
- **Separation of Concerns**: Clear boundaries between data, business logic, and UI
  - **Models** (`lib/models/`) - Pure data structures
  - **Services** (`lib/services/`) - Business logic and data persistence
  - **Screens** (`lib/screens/`) - UI components
  - **Main** (`lib/main.dart`) - Navigation and app structure

### 2. **State Management**
- Uses Flutter's built-in `StatefulWidget` with local state management
- `GlobalKey<State>` for cross-screen communication
- `IndexedStack` for navigation (preserves screen state)

### 3. **Data Persistence**
- **SharedPreferences** for local storage
- JSON serialization/deserialization
- Immutable past-day logs (locked after day ends)

---

## 📦 Data Models

### 1. **UserProfile** (`lib/models/user_profile.dart`)
```dart
- weight: double? (in kg)
- height: double? (in cm)
- calorieLimit: double (daily calorie limit)
```
- JSON serialization support
- `copyWith` method for immutable updates

### 2. **DailyLog** (`lib/models/daily_log.dart`)
```dart
- date: DateTime
- foodEntries: List<FoodEntry>
- waterIntake: double (in liters)
- calorieLimit: double (snapshot of limit for that day)
```
- `totalCalories` getter (calculated from entries)
- **Critical**: Stores the calorie limit that was active on that day (immutable after day ends)

### 3. **FoodEntry** (`lib/models/food_entry.dart`)
```dart
- id: String (unique identifier)
- name: String
- calories: double
- quantity: double (in grams)
- timestamp: DateTime
```
- Unique ID per entry
- Timestamp for chronological ordering

---

## 🔧 Services Layer

### **DataService** (`lib/services/data_service.dart`)

#### Core Responsibilities:

1. **User Profile Management**
   - `getUserProfile()` / `saveUserProfile()`
   - JSON storage in SharedPreferences

2. **Daily Log Management**
   - `getTodayLog()` - Returns today's log, creates if missing
   - `getAllDailyLogs()` - Returns all historical logs
   - `saveDailyLog()` - Saves log with date-based key

3. **Food Entry Operations**
   - `addFoodEntry()` - Adds to today's log
   - `updateFoodEntry()` - Updates existing entry
   - `deleteFoodEntry()` - Removes entry

4. **Water Intake**
   - `addWater()` - Adds to current total
   - `setWater()` - Sets absolute value

5. **Food Database**
   - Built-in food database (23 items)
   - Calories per 100g format
   - Stored in SharedPreferences

#### **Date Key System**
```dart
_getDateKey(DateTime date) → "YYYY-MM-DD"
```
- Creates unique key per day
- Enables day-based retrieval and locking

#### **Immutability Protection**
- **Today's log**: Always uses current calorie limit
- **Past logs**: Preserves original calorie limit
- Logic in `saveDailyLog()` checks if date is today

---

## 🎨 UI/UX Design

### **Design System**
- **Dark Theme**: Black background, grey cards
- **Neon Accents**: Green (#39FF14), Red (#FF073A)
- **Material Design 3**: Modern Flutter design system

### **Navigation System** (`lib/main.dart`)

#### **IndexedStack Navigation**
- All screens kept in memory
- State preserved when switching
- No rebuilds on navigation

#### **Bottom Navigation Bar**
- 3 buttons: **Me** | **+** (neon) | **History**
- Active state highlighting
- Neon + button with permanent glow

#### **Screen Structure**
```
Index 0: HomeScreen (default)
Index 1: AddScreen
Index 2: HistoryScreen
Index 3: ProfileScreen
```

---

## 📱 Screen Details

### 1. **HomeScreen** (`lib/screens/home_screen.dart`)

#### **Features:**
- **Pulsating Neon Calorie Circle**
  - AnimationController with 1.5s cycle
  - Green when under limit, red when exceeded
  - BoxShadow for glow effect
  - Tap to open food entries sheet
- **Three Info Cards**
  - Water Intake (blue)
  - Calorie Limit (orange)
  - Body Stats (green)
- **Food Entries Bottom Sheet**
  - DraggableScrollableSheet
  - Water intake section (editable)
  - Food list with edit/delete options

#### **Animation System**
```dart
SingleTickerProviderStateMixin
AnimationController (1500ms, repeat reverse)
Tween<double>(0.3 → 1.0)
CurvedAnimation (easeInOut)
```

### 2. **AddScreen** (`lib/screens/add_screen.dart`)

#### **Features:**
- **Tab System** (Food / Water)
- **Food Tab**
  - Searchable food database
  - Quantity input (grams)
  - Auto-calculation: `(caloriesPer100g × quantity) / 100`
- **Water Tab**
  - Liter input
  - Validation

### 3. **HistoryScreen** (`lib/screens/history_screen.dart`)

#### **Features:**
- **Chronological List** (newest first)
- **Visual Indicators**
  - Today: Green edit icon + "Active" badge
  - Past days: Grey lock icon
- **Expansion Tiles**
  - Expandable entries
  - Food list inside
- **Auto-refresh** on navigation
- **Uses stored calorie limit** per day

### 4. **ProfileScreen** (`lib/screens/profile_screen.dart`)

#### **Features:**
- Weight input (kg)
- Height input (cm)
- Calorie limit input
- Validation
- Save with feedback

---

## ✨ Key Features

### 1. **Immutable History**
- Past days lock their calorie limit
- Today's log uses current limit
- Historical accuracy preserved

### 2. **Real-time Updates**
- Home screen refreshes on return
- History refreshes on navigation
- GlobalKeys for cross-screen refresh

### 3. **Neon Visual Effects**
- Pulsating circle glow
- Neon navigation button
- Color-coded states (green/red)

### 4. **Interactive Calorie Circle**
- Tap to view/edit entries
- Visual progress indicator
- Exceeded state (red, capped at 100%)

### 5. **Water Tracking**
- Editable in food entries sheet
- Separate from food entries
- Persistent storage

---

## 🔄 Data Flow

### **Adding Food**
```
User Input → AddScreen
  ↓
DataService.addFoodEntry()
  ↓
getTodayLog() → Get current log
  ↓
Create FoodEntry with calculated calories
  ↓
Update DailyLog with new entry
  ↓
saveDailyLog() → Save to SharedPreferences
  ↓
HomeScreen.refresh() → Update UI
```

### **Viewing History**
```
HistoryScreen.initState()
  ↓
DataService.getAllDailyLogs()
  ↓
Parse JSON → Map<String, DailyLog>
  ↓
Sort by date (newest first)
  ↓
Display with stored calorieLimit per day
```

### **Day Transition**
```
New Day Starts
  ↓
getTodayLog() called
  ↓
No log exists for today
  ↓
Create new DailyLog with current calorieLimit
  ↓
Yesterday's log remains unchanged (locked)
```

---

## 🛠️ Technical Implementation

### **State Management Pattern**
```dart
StatefulWidget + setState()
GlobalKey<State> for cross-screen communication
IndexedStack for navigation state preservation
```

### **Data Persistence**
```dart
SharedPreferences (key-value storage)
JSON encoding/decoding
Date-based keys for daily logs
```

### **Animation**
```dart
AnimationController with SingleTickerProviderStateMixin
Tween animations for smooth transitions
BoxShadow for neon glow effects
```

### **Error Handling**
- Null safety (Dart null safety)
- Default values (2000 cal limit, 0.0 water)
- Mounted checks before setState
- Input validation

---

## 🎯 Design Patterns

1. **Repository Pattern** - DataService abstracts storage
2. **Factory Pattern** - JSON deserialization
3. **Builder Pattern** - copyWith methods
4. **Singleton-like** - DataService instance per screen
5. **Observer Pattern** - TextEditingController listeners

---

## ⚡ Performance Optimizations

- **IndexedStack**: Keeps screens in memory (fast switching)
- **Lazy Loading**: Load data on screen init
- **Efficient JSON**: Minimal parsing overhead
- **Targeted Rebuilds**: Only update necessary widgets

---

## 🔒 Security & Data Integrity

- **Local Storage Only**: No cloud sync (privacy)
- **Immutable Past Logs**: Cannot be modified after day ends
- **Date-based Validation**: Prevents data corruption
- **Input Sanitization**: FilteringTextInputFormatter

---

## 🚀 Future Extensibility

- **Easy Feature Addition**: Models support copyWith
- **Modular Structure**: Screens/services independent
- **Extensible Database**: Food database can grow
- **Cloud Ready**: JSON structure supports sync

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
```

---

## 🏃 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Illya-Viktorskij/calorie-calculator.git
   cd calorie-calculator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 📝 Summary

This is a **production-ready Flutter calorie tracking app** featuring:
- ✅ Clean architecture (models/services/screens)
- ✅ Immutable historical data
- ✅ Neon-themed UI with animations
- ✅ Local persistence with SharedPreferences
- ✅ Real-time updates and state preservation
- ✅ User-friendly interactions

The app emphasizes **data integrity** (past days are locked), **visual feedback** (neon effects, color coding), and **smooth user experience** (preserved state, instant navigation).

---

## 📄 License

This project is open source and available for personal use.

---

## 👤 Author

**Illya Viktorskij**

GitHub: [@Illya-Viktorskij](https://github.com/Illya-Viktorskij)
