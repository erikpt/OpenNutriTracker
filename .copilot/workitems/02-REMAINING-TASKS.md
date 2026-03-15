# Remaining Tasks — Prioritized

**Last Updated:** 2026-03-14 (session 4)

---

## Priority 1: Bugs

### ~~#213 — Nonsensical nutritional info~~ ✅ DONE
Validation in `edit_meal_screen.dart` `_onSavePressed`: macros ≤ base qty, total macros ≤ base×1.05, kcal ≤ base×9.

### ~~#182 — Diary shows 0 kcal for some days~~ ✅ DONE
`DayInfoWidget` now computes kcal/macros from actual intake lists (not stale cache).
`CalendarDayBloc` reconciles `TrackedDayDBO` cache on each day load — calendar dot colors self-heal.

---

## Priority 2: High-Value UX

### ~~#235 — Macros per food item and meal~~ ✅ DONE
Macro totals shown per meal section header + compact per-item badge in intake cards.

### ~~#277 — Disable activity tracking option~~ ✅ DONE
Settings `SwitchListTile` toggle; persisted via `ConfigDBO.showActivityTracking` (HiveField 9).
`ActivityVerticalList` conditionally rendered on home page.

### ~~#232 — Direct macro input for custom meals~~ ✅ DONE
`SegmentedButton` toggle (Per Xg/ml | Total) in edit meal screen.
In Total mode, values are converted to per-base-qty on save using meal quantity.

### ~~#267/#174 — Custom meals not findable before first use~~ ✅ DONE
Custom meals saved to `CustomMealBox` (`Box<MealDBO>`) when edit-meal flow completes.
`RecentMealBloc` merges templates + logged intakes, deduplicating by code/name.

---

## Priority 3: Medium Features

### #284 — Weekly weight goal
**Effort:** Medium (3-4 hours)

### #229 — API rate limiting / search failures
**Problem:** OFF/FDC search returns no results intermittently
**Note:** Previously claimed fixed but code is absent — needs investigation
**Effort:** High

---

## Priority 4: Large Features

### #279 — Multi-ingredient meal composition (most requested)
**Effort:** High (1-2 days)

### #222 — FDC import validation (was reverted in PR #5)
**Fix:** Re-implement sanity checks (sugar ≤ carbs, saturatedFat ≤ fat, macros ≤ 100g)
**Effort:** High (4-8 hours)

### #237 — Micronutrient tracking
**Effort:** High (data model + UI)

---

## Technical Debt

- Localize hardcoded validation strings in `set_weight_dialog.dart`, `meal_detail_bottom_sheet.dart`, `edit_meal_screen.dart`
- Lower OFF timeout from 20s (TODO comment in `off_data_source.dart`)
- Re-investigate #229/#125 (rate limiting / search quality — code not present)
