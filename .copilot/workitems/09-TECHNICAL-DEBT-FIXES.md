# Technical Debt Resolution - December 4, 2025

**Branch:** erikpt/fix-technical-debt  
**Status:** In Progress

---

## 🔴 Critical Issues Fixed

### 1. **LoadCalendarDayEvent Props Bug** ⚠️ CRITICAL
**File:** `lib/features/diary/presentation/bloc/calendar_day_event.dart`

**Problem:** 
```dart
class LoadCalendarDayEvent extends CalendarDayEvent {
  final DateTime day;
  const LoadCalendarDayEvent(this.day);
  
  @override
  List<Object?> get props => [];  // ❌ Empty props - BUG!
}
```

**Impact:** 
- Equatable comparison doesn't work correctly
- Events with different days are considered equal
- Can cause duplicate event processing bugs

**Fix Applied:**
```dart
@override
List<Object?> get props => [day];  // ✅ Include day in props
```

**Status:** ✅ FIXED

---

## 🟠 Medium Issues Identified

### 2. **Remove Dummy Data TODO**
**File:** `lib/core/data/data_source/user_data_source.dart:22`

**Issue:**
```dart
// TODO remove dummy data
Future<UserDBO> getUserData() async {
  return _userBox.get(_userKey) ??
      UserDBO(
        // ... dummy data ...
      );
}
```

**Impact:** Medium - Adds dummy data if no user exists, should likely fail or prompt for onboarding

**Status:** 📋 IDENTIFIED (needs design decision)

---

### 3. **Enum Class for Rating**
**File:** `lib/core/domain/entity/tracked_day_entity.dart:43`

**Issue:**
```dart
// TODO: make enum class for rating
Color getCalendarDayRatingColor(BuildContext context) {
  if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
    return Theme.of(context).colorScheme.primary;
  } else {
    return Theme.of(context).colorScheme.error;
  }
}
```

**Impact:** Medium - Color selection logic could be clearer with an enum

**Status:** ✅ FIXED

**Solution:**
- Created new `DayRating` enum in `lib/core/domain/entity/day_rating.dart`
- Enum has `good` and `poor` values with color methods
- Refactored `TrackedDayEntity` to use `rating` getter that returns `DayRating`
- Existing color methods now delegate to the enum
- Renamed private method to `_isWithinAcceptableCalorieDifference` for clarity

---

### 4. **Edit Meal Screen TODO**
**File:** `lib/features/add_meal/presentation/add_meal_screen.dart:300`

**Issue:**
```dart
void _openEditMealScreen(bool usesImperialUnits) {
  // TODO
  Navigator.of(context).pushNamed(NavigationOptions.editMealRoute,
```

**Impact:** Unknown - Orphaned TODO comment without description

**Status:** ❓ NEEDS CLARIFICATION - Ask original developer about intent

---

## 📊 Technical Debt Summary

| Issue | Severity | Type | Status |
|:---:|:---:|:---|:---|
| LoadCalendarDayEvent props | 🔴 CRITICAL | Bug | ✅ FIXED |
| Dummy user data | 🟠 MEDIUM | Design | 📋 IDENTIFIED |
| Rating enum | 🟠 MEDIUM | Refactor | ✅ FIXED |
| TODO placeholder | 🟡 LOW | Comment | ⏸️ ASK DEV |

---

## 🎯 Recommendations

1. **Immediate:** Merge this PR - fixes critical Equatable bug and implements rating enum
2. **Next Sprint:** Address dummy data handling
3. **Later:** Clarify orphan TODO with original developer

---

**Created:** December 4, 2025  
**Branch:** erikpt/fix-technical-debt  
**PR Status:** Ready for Review
