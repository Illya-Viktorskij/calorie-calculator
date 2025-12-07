# Complete Functions Documentation - Calorie Calculator App

This document provides a comprehensive overview of all functions, methods, and getters in the Calorie Calculator application.

---

## 📁 **lib/main.dart**

### **Entry Point**
- **`main()`**
  - **Purpose**: Application entry point
  - **Parameters**: None
  - **Returns**: void
  - **Description**: Initializes and runs the Flutter app

### **CalorieCalculatorApp Class**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the root MaterialApp widget
  - **Returns**: `Widget`
  - **Description**: Configures app theme (dark mode, green accent), sets home screen, and disables debug banner

### **MainNavigationScreen Class**

#### **State Management**
- **`createState()`**
  - **Purpose**: Creates the state object for MainNavigationScreen
  - **Returns**: `State<MainNavigationScreen>`
  - **Description**: Returns `_MainNavigationScreenState` instance

### **_MainNavigationScreenState Class**

#### **Getters**
- **`_screens`** (getter)
  - **Purpose**: Returns list of all screen widgets
  - **Returns**: `List<Widget>`
  - **Description**: Contains HomeScreen, AddScreen, HistoryScreen, ProfileScreen in order (indices 0-3)

#### **Build Methods**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the main navigation scaffold
  - **Returns**: `Widget`
  - **Description**: Creates IndexedStack for screen management and bottom navigation bar

- **`_buildNavBar()`**
  - **Purpose**: Builds the bottom navigation bar
  - **Returns**: `Widget`
  - **Description**: Creates row with Me, Add (neon), and History buttons

- **`_buildNeonAddButton()`**
  - **Purpose**: Creates the special neon + button
  - **Returns**: `Widget`
  - **Description**: Circular button with neon green glow effect, larger than other nav buttons, always visible

- **`_buildNavButton({required IconData icon, required String label, required int index, required VoidCallback onTap})`**
  - **Purpose**: Builds a standard navigation button
  - **Parameters**:
    - `icon`: Icon to display
    - `label`: Text label below icon
    - `index`: Screen index for selection state
    - `onTap`: Callback when tapped
  - **Returns**: `Widget`
  - **Description**: Creates button with icon, label, and selection highlighting (green when active)

#### **Navigation Methods**
- **`_onIndexChanged(int newIndex)`**
  - **Purpose**: Handles screen navigation
  - **Parameters**: `newIndex` - Index of screen to navigate to
  - **Returns**: void
  - **Description**: Updates current index, refreshes HomeScreen (index 0) or HistoryScreen (index 2) when navigated to

---

## 📁 **lib/services/data_service.dart**

### **DataService Class**

#### **User Profile Methods**
- **`getUserProfile()`**
  - **Purpose**: Retrieves user profile from storage
  - **Returns**: `Future<UserProfile?>`
  - **Description**: Reads JSON from SharedPreferences, deserializes to UserProfile, returns null if not found

- **`saveUserProfile(UserProfile profile)`**
  - **Purpose**: Saves user profile to storage
  - **Parameters**: `profile` - UserProfile to save
  - **Returns**: `Future<void>`
  - **Description**: Serializes profile to JSON and stores in SharedPreferences

#### **Daily Log Methods**
- **`getAllDailyLogs()`**
  - **Purpose**: Retrieves all daily logs from storage
  - **Returns**: `Future<Map<String, DailyLog>>`
  - **Description**: Reads all logs from SharedPreferences, deserializes each, returns map with date keys (YYYY-MM-DD)

- **`getTodayLog()`**
  - **Purpose**: Gets or creates today's daily log
  - **Returns**: `Future<DailyLog>`
  - **Description**: 
    - Checks if today's log exists
    - If exists, updates calorie limit if it changed (only for today)
    - If not exists, creates new log with current calorie limit
    - Always ensures today's log has current limit

- **`_saveAllLogs(Map<String, DailyLog> logs)`** (private)
  - **Purpose**: Saves all daily logs to storage
  - **Parameters**: `logs` - Map of all logs to save
  - **Returns**: `Future<void>`
  - **Description**: Serializes all logs to JSON and writes to SharedPreferences

- **`saveDailyLog(DailyLog log)`**
  - **Purpose**: Saves a single daily log
  - **Parameters**: `log` - DailyLog to save
  - **Returns**: `Future<void>`
  - **Description**: 
    - If saving today's log: updates with current calorie limit
    - If saving past day's log: preserves original calorie limit (immutability)
    - Adds/updates log in map and saves all logs

#### **Food Entry Methods**
- **`addFoodEntry(FoodEntry entry)`**
  - **Purpose**: Adds a food entry to today's log
  - **Parameters**: `entry` - FoodEntry to add
  - **Returns**: `Future<void>`
  - **Description**: Gets today's log, adds entry to list, updates with current calorie limit, saves

- **`updateFoodEntry(FoodEntry updatedEntry)`**
  - **Purpose**: Updates an existing food entry in today's log
  - **Parameters**: `updatedEntry` - FoodEntry with updated values
  - **Returns**: `Future<void>`
  - **Description**: Finds entry by ID, replaces it, updates log with current calorie limit, saves

- **`deleteFoodEntry(String entryId)`**
  - **Purpose**: Removes a food entry from today's log
  - **Parameters**: `entryId` - ID of entry to delete
  - **Returns**: `Future<void>`
  - **Description**: Filters out entry by ID, updates log with current calorie limit, saves

#### **Water Intake Methods**
- **`addWater(double liters)`**
  - **Purpose**: Adds water to today's total intake
  - **Parameters**: `liters` - Amount of water to add
  - **Returns**: `Future<void>`
  - **Description**: Gets today's log, adds liters to current water intake, updates with current calorie limit, saves

- **`setWater(double liters)`**
  - **Purpose**: Sets absolute water intake for today
  - **Parameters**: `liters` - Total water amount to set
  - **Returns**: `Future<void>`
  - **Description**: Gets today's log, sets water intake to specified value, updates with current calorie limit, saves

#### **Food Database Methods**
- **`getFoodDatabase()`**
  - **Purpose**: Retrieves the food database
  - **Returns**: `Future<List<Map<String, dynamic>>>`
  - **Description**: Reads from SharedPreferences, returns default database if not found

- **`initializeFoodDatabase()`**
  - **Purpose**: Initializes food database if it doesn't exist
  - **Returns**: `Future<void>`
  - **Description**: Checks if database exists, if not, saves default 23-item database to SharedPreferences

- **`_getDefaultFoodDatabase()`** (private)
  - **Purpose**: Returns the default food database
  - **Returns**: `List<Map<String, dynamic>>`
  - **Description**: Returns hardcoded list of 23 foods with calories per 100g

#### **Utility Methods**
- **`_getDateKey(DateTime date)`** (private)
  - **Purpose**: Converts DateTime to date key string
  - **Parameters**: `date` - DateTime to convert
  - **Returns**: `String`
  - **Description**: Formats date as "YYYY-MM-DD" for use as map key

---

## 📁 **lib/screens/home_screen.dart**

### **HomeScreen Class**
- **`createState()`**
  - **Purpose**: Creates HomeScreenState
  - **Returns**: `State<HomeScreen>`

### **HomeScreenState Class**

#### **Lifecycle Methods**
- **`initState()`**
  - **Purpose**: Initializes screen state
  - **Returns**: void
  - **Description**: Loads data, initializes pulsating animation controller

- **`dispose()`**
  - **Purpose**: Cleans up resources
  - **Returns**: void
  - **Description**: Disposes animation controller

#### **Data Loading Methods**
- **`_loadData()`**
  - **Purpose**: Loads today's log and user profile
  - **Returns**: `Future<void>`
  - **Description**: Fetches data from DataService, updates state, handles mounted check

- **`refresh()`**
  - **Purpose**: Public method to refresh screen data
  - **Returns**: void
  - **Description**: Calls `_loadData()` - used by navigation system

#### **UI Builder Methods**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the home screen UI
  - **Returns**: `Widget`
  - **Description**: Creates scrollable view with calorie circle, info cards, handles loading state

- **`_buildInfoCard({required IconData icon, required Color iconColor, required String title, required String value, required String subtitle})`**
  - **Purpose**: Builds an info card widget
  - **Parameters**:
    - `icon`: Icon to display
    - `iconColor`: Color for icon
    - `title`: Card title
    - `value`: Main value to display
    - `subtitle`: Subtitle text
  - **Returns**: `Widget`
  - **Description**: Creates styled card with icon, title, value, and subtitle

#### **Dialog/Sheet Methods**
- **`_showFoodEntriesSheet(BuildContext context)`**
  - **Purpose**: Shows bottom sheet with today's food entries
  - **Parameters**: `context` - BuildContext
  - **Returns**: void
  - **Description**: Creates draggable bottom sheet showing water intake section and food entries list

- **`_buildFoodEntryTile(BuildContext context, FoodEntry entry)`**
  - **Purpose**: Builds a single food entry tile
  - **Parameters**:
    - `context` - BuildContext
    - `entry` - FoodEntry to display
  - **Returns**: `Widget`
  - **Description**: Creates list tile with food name, quantity, calories, and edit/delete menu

- **`_showEditFoodDialog(BuildContext context, FoodEntry entry)`**
  - **Purpose**: Shows dialog to edit food entry
  - **Parameters**:
    - `context` - BuildContext
    - `entry` - FoodEntry to edit
  - **Returns**: void
  - **Description**: 
    - Calculates calories per 100g from entry
    - Shows dialog with quantity input
    - Recalculates calories based on new quantity
    - Updates entry via DataService

- **`_showDeleteConfirmation(BuildContext context, FoodEntry entry)`**
  - **Purpose**: Shows confirmation dialog before deleting entry
  - **Parameters**:
    - `context` - BuildContext
    - `entry` - FoodEntry to delete
  - **Returns**: void
  - **Description**: Shows alert dialog, deletes entry on confirmation, shows snackbar feedback

- **`_showEditWaterDialog(BuildContext context, double currentWater)`**
  - **Purpose**: Shows dialog to edit water intake
  - **Parameters**:
    - `context` - BuildContext
    - `currentWater` - Current water amount
  - **Returns**: void
  - **Description**: Shows dialog with water input field, updates via DataService.setWater(), shows feedback

---

## 📁 **lib/screens/add_screen.dart**

### **AddScreen Class**
- **`createState()`**
  - **Purpose**: Creates AddScreenState
  - **Returns**: `State<AddScreen>`

### **_AddScreenState Class**

#### **Lifecycle Methods**
- **`initState()`**
  - **Purpose**: Initializes screen state
  - **Returns**: void
  - **Description**: Loads food database, sets up search controller listener

- **`dispose()`**
  - **Purpose**: Cleans up resources
  - **Returns**: void
  - **Description**: Disposes all text controllers

#### **Data Loading Methods**
- **`_loadFoodDatabase()`**
  - **Purpose**: Loads food database from DataService
  - **Returns**: `Future<void>`
  - **Description**: Initializes database if needed, loads foods, updates filtered list

#### **Food Management Methods**
- **`_filterFoods()`**
  - **Purpose**: Filters food list based on search query
  - **Returns**: void
  - **Description**: Listens to search controller, filters foods by name (case-insensitive), updates filtered list

- **`_addFood(Map<String, dynamic> food)`**
  - **Purpose**: Adds food entry to today's log
  - **Parameters**: `food` - Food data from database
  - **Returns**: `Future<void>`
  - **Description**: 
    - Parses quantity from controller (defaults to 100g)
    - Calculates total calories: `(caloriesPer100g × quantity) / 100`
    - Creates FoodEntry with unique ID
    - Saves via DataService
    - Shows success snackbar

- **`_showAddFoodDialog(Map<String, dynamic> food)`**
  - **Purpose**: Shows dialog to add food with quantity
  - **Parameters**: `food` - Food data from database
  - **Returns**: void
  - **Description**: Shows dialog with quantity input (defaults to 100g), calls `_addFood()` on confirm

#### **Water Management Methods**
- **`_addWater()`**
  - **Purpose**: Adds water to today's intake
  - **Returns**: `Future<void>`
  - **Description**: 
    - Validates input (must be > 0)
    - Adds water via DataService
    - Shows success snackbar or error if invalid

#### **UI Builder Methods**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the add screen UI
  - **Returns**: `Widget`
  - **Description**: Creates scaffold with tab selector (Food/Water) and content based on selected tab

- **`_buildFoodTab()`**
  - **Purpose**: Builds the food tab content
  - **Returns**: `Widget`
  - **Description**: Creates search bar and scrollable list of foods, shows loading indicator or empty state

- **`_buildWaterTab()`**
  - **Purpose**: Builds the water tab content
  - **Returns**: `Widget`
  - **Description**: Creates centered form with water drop icon, input field, and add button

---

## 📁 **lib/screens/history_screen.dart**

### **HistoryScreen Class**
- **`createState()`**
  - **Purpose**: Creates HistoryScreenState
  - **Returns**: `State<HistoryScreen>`

### **HistoryScreenState Class**

#### **Lifecycle Methods**
- **`initState()`**
  - **Purpose**: Initializes screen state
  - **Returns**: void
  - **Description**: Loads history data on screen creation

#### **Data Loading Methods**
- **`refresh()`**
  - **Purpose**: Public method to refresh history data
  - **Returns**: void
  - **Description**: Calls `_loadHistory()` - used by navigation system

- **`_loadHistory()`**
  - **Purpose**: Loads all daily logs and profile
  - **Returns**: `Future<void>`
  - **Description**: Fetches all logs and profile from DataService, updates state

#### **Utility Methods**
- **`_formatDate(DateTime date)`**
  - **Purpose**: Formats date for display
  - **Parameters**: `date` - DateTime to format
  - **Returns**: `String`
  - **Description**: 
    - Returns "Today" if date is today
    - Returns "Yesterday" if date is yesterday
    - Otherwise returns "DD/MM/YYYY" format

#### **UI Builder Methods**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the history screen UI
  - **Returns**: `Widget`
  - **Description**: Creates list of daily logs with expansion tiles, shows loading or empty state, supports pull-to-refresh

---

## 📁 **lib/screens/profile_screen.dart**

### **ProfileScreen Class**
- **`createState()`**
  - **Purpose**: Creates ProfileScreenState
  - **Returns**: `State<ProfileScreen>`

### **_ProfileScreenState Class**

#### **Lifecycle Methods**
- **`initState()`**
  - **Purpose**: Initializes screen state
  - **Returns**: void
  - **Description**: Loads user profile data

- **`dispose()`**
  - **Purpose**: Cleans up resources
  - **Returns**: void
  - **Description**: Disposes all text controllers

#### **Data Loading Methods**
- **`_loadProfile()`**
  - **Purpose**: Loads user profile from DataService
  - **Returns**: `Future<void>`
  - **Description**: Fetches profile, populates text controllers, sets default calorie limit if no profile exists

#### **Data Saving Methods**
- **`_saveProfile()`**
  - **Purpose**: Saves user profile
  - **Returns**: `Future<void>`
  - **Description**: 
    - Parses inputs (weight, height, calorie limit)
    - Validates calorie limit (> 0)
    - Creates UserProfile object
    - Saves via DataService
    - Shows success/error feedback

#### **UI Builder Methods**
- **`build(BuildContext context)`**
  - **Purpose**: Builds the profile screen UI
  - **Returns**: `Widget`
  - **Description**: Creates form with weight, height, and calorie limit inputs, save button with loading state

---

## 📁 **lib/models/user_profile.dart**

### **UserProfile Class**

#### **Serialization Methods**
- **`toJson()`**
  - **Purpose**: Converts UserProfile to JSON map
  - **Returns**: `Map<String, dynamic>`
  - **Description**: Serializes all fields for storage

- **`fromJson(Map<String, dynamic> json)`** (factory)
  - **Purpose**: Creates UserProfile from JSON
  - **Parameters**: `json` - JSON map
  - **Returns**: `UserProfile`
  - **Description**: Deserializes JSON, handles null values, defaults calorie limit to 2000.0

#### **Utility Methods**
- **`copyWith({double? weight, double? height, double? calorieLimit})`**
  - **Purpose**: Creates new UserProfile with updated values
  - **Parameters**: Optional fields to update
  - **Returns**: `UserProfile`
  - **Description**: Creates new instance, keeps existing values for unspecified fields (immutable pattern)

---

## 📁 **lib/models/daily_log.dart**

### **DailyLog Class**

#### **Getters**
- **`totalCalories`** (getter)
  - **Purpose**: Calculates total calories from all food entries
  - **Returns**: `double`
  - **Description**: Uses `fold()` to sum all entry calories

#### **Serialization Methods**
- **`toJson()`**
  - **Purpose**: Converts DailyLog to JSON map
  - **Returns**: `Map<String, dynamic>`
  - **Description**: Serializes date, food entries, water intake, and calorie limit

- **`fromJson(Map<String, dynamic> json)`** (factory)
  - **Purpose**: Creates DailyLog from JSON
  - **Parameters**: `json` - JSON map
  - **Returns**: `DailyLog`
  - **Description**: Deserializes JSON, handles null food entries, defaults water to 0.0, calorie limit to 2000.0

#### **Utility Methods**
- **`copyWith({DateTime? date, List<FoodEntry>? foodEntries, double? waterIntake, double? calorieLimit})`**
  - **Purpose**: Creates new DailyLog with updated values
  - **Parameters**: Optional fields to update
  - **Returns**: `DailyLog`
  - **Description**: Creates new instance, keeps existing values for unspecified fields (immutable pattern)

---

## 📁 **lib/models/food_entry.dart**

### **FoodEntry Class**

#### **Serialization Methods**
- **`toJson()`**
  - **Purpose**: Converts FoodEntry to JSON map
  - **Returns**: `Map<String, dynamic>`
  - **Description**: Serializes all fields including ISO8601 timestamp

- **`fromJson(Map<String, dynamic> json)`** (factory)
  - **Purpose**: Creates FoodEntry from JSON
  - **Parameters**: `json` - JSON map
  - **Returns**: `FoodEntry`
  - **Description**: Deserializes JSON, handles null values with defaults, parses timestamp

#### **Utility Methods**
- **`copyWith({String? id, String? name, double? calories, double? quantity, DateTime? timestamp})`**
  - **Purpose**: Creates new FoodEntry with updated values
  - **Parameters**: Optional fields to update
  - **Returns**: `FoodEntry`
  - **Description**: Creates new instance, keeps existing values for unspecified fields (immutable pattern)

---

## 📊 **Function Summary by Category**

### **Data Operations (DataService)**
- `getUserProfile()` - Read profile
- `saveUserProfile()` - Write profile
- `getAllDailyLogs()` - Read all logs
- `getTodayLog()` - Read/create today's log
- `saveDailyLog()` - Write log
- `addFoodEntry()` - Add food
- `updateFoodEntry()` - Update food
- `deleteFoodEntry()` - Delete food
- `addWater()` - Add water
- `setWater()` - Set water
- `getFoodDatabase()` - Read food database
- `initializeFoodDatabase()` - Initialize database

### **UI Builders**
- `build()` - Main UI builders (all screens)
- `_buildNavBar()` - Navigation bar
- `_buildNeonAddButton()` - Neon + button
- `_buildNavButton()` - Standard nav button
- `_buildInfoCard()` - Info card widget
- `_buildFoodEntryTile()` - Food entry tile
- `_buildFoodTab()` - Food tab content
- `_buildWaterTab()` - Water tab content

### **Dialog/Sheet Methods**
- `_showFoodEntriesSheet()` - Bottom sheet
- `_showEditFoodDialog()` - Edit food dialog
- `_showDeleteConfirmation()` - Delete confirmation
- `_showEditWaterDialog()` - Edit water dialog
- `_showAddFoodDialog()` - Add food dialog

### **Data Loading/Refresh**
- `_loadData()` - Load home screen data
- `refresh()` - Public refresh methods
- `_loadHistory()` - Load history data
- `_loadProfile()` - Load profile data
- `_loadFoodDatabase()` - Load food database

### **Event Handlers**
- `_onIndexChanged()` - Navigation handler
- `_filterFoods()` - Search filter
- `_addFood()` - Add food handler
- `_addWater()` - Add water handler
- `_saveProfile()` - Save profile handler

### **Utility Methods**
- `_formatDate()` - Date formatting
- `_getDateKey()` - Date key generation
- `_getDefaultFoodDatabase()` - Default foods
- `_saveAllLogs()` - Batch save logs

### **Serialization (Models)**
- `toJson()` - Convert to JSON (all models)
- `fromJson()` - Create from JSON (all models)
- `copyWith()` - Immutable updates (all models)

### **Getters**
- `totalCalories` - Calculate total (DailyLog)
- `_screens` - Screen list (Navigation)

---

## 🔄 **Function Call Flow Examples**

### **Adding Food Entry**
```
User taps food → _showAddFoodDialog()
  ↓
User enters quantity → _addFood()
  ↓
DataService.addFoodEntry()
  ↓
getTodayLog() → getTodayLog()
  ↓
saveDailyLog() → _saveAllLogs()
  ↓
HomeScreen.refresh() → _loadData()
```

### **Viewing History**
```
HistoryScreen.initState()
  ↓
_loadHistory()
  ↓
DataService.getAllDailyLogs()
  ↓
_formatDate() for each log
  ↓
build() displays list
```

### **Editing Water**
```
User taps edit → _showEditWaterDialog()
  ↓
User enters amount → DataService.setWater()
  ↓
getTodayLog() → saveDailyLog()
  ↓
_loadData() → UI updates
```

---

## 📝 **Notes**

- All async methods return `Future<void>` or `Future<T>`
- All UI builders return `Widget`
- All serialization methods handle null values gracefully
- All copyWith methods follow immutable pattern
- All data operations go through DataService
- All screens check `mounted` before setState in async operations
- All text controllers are disposed in dispose() methods
- All dialogs use dark theme (Colors.grey[900])
- All snackbars provide user feedback

---

**Total Functions Documented: 60+**

This documentation covers every function, method, getter, and lifecycle hook in the application.


