# Issue #154 - Fix Diary Navigation After Adding Future Entry

**Branch:** erikpt/fix-issue-154  
**Created:** December 3, 2025  
**Status:** In Development

---

## Problem Statement

When a user adds a meal for a future date in the diary, the app navigates back to today's date instead of staying on the date where the entry was added.

**Scenario:**
1. User is viewing diary on December 10 (future date)
2. User adds a meal for December 10
3. Meal is saved successfully
4. **BUG:** App navigates back to today (December 3) instead of staying on December 10

---

## Root Cause Analysis

The issue is in the refresh flow after adding a meal:

**File:** `lib/features/meal_detail/presentation/widgets/meal_detail_bottom_sheet.dart`

When adding a meal:
```dart
// Refresh Diary Page
locator<DiaryBloc>().add(const LoadDiaryYearEvent());
locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
```

**Problem:** `RefreshCalendarDayEvent()` refreshes using `_currentDay` (which is `DateTime.now()`), not the currently selected date.

**File:** `lib/features/diary/presentation/bloc/calendar_day_bloc.dart`

```dart
on<RefreshCalendarDayEvent>((event, emit) async {
  if (_currentDay != null) {
    emit(CalendarDayLoading());
    await _loadCalendarDay(_currentDay!, emit);  // Uses _currentDay (today)
  }
});
```

---

## Solution

Create a new event type that can preserve the selected date during refresh, OR modify the existing refresh to use the UI state's selected date.

**Approach:** Modify `RefreshCalendarDayEvent` to optionally accept a date parameter, allowing the diary page to pass the currently selected date.

### Files to Modify

1. **calendar_day_event.dart** - Add optional date parameter to RefreshCalendarDayEvent
2. **calendar_day_bloc.dart** - Use provided date or fall back to _currentDay
3. **meal_detail_bottom_sheet.dart** - Pass the selected date when refreshing

---

## Implementation Steps

1. ✅ Create feature branch
2. [ ] Modify calendar_day_event.dart
3. [ ] Modify calendar_day_bloc.dart
4. [ ] Modify meal_detail_bottom_sheet.dart
5. [ ] Test the fix
6. [ ] Create PR to erikpt/bugfixes

---

**Expected Outcome:**
After adding a meal for a future date, the diary stays on that date instead of navigating to today.
