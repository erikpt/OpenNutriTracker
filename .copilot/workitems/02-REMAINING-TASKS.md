# Remaining Tasks — Prioritized

**Last Updated:** 2026-03-11 (session 3)

---

## Priority 1: Bugs (Fix Next)

### ~~#213 — Nonsensical nutritional info~~ ✅ DONE
Validation added in `edit_meal_screen.dart` `_onSavePressed`: macros ≤ base qty, total macros ≤ base×1.05, kcal ≤ base×9.

### #182 — Diary shows 0 kcal for some days
**Problem:** Date comparison bug causes some logged days to show zero
**File:** `lib/core/data/data_source/tracked_day_data_source.dart`
**Effort:** Low-Medium (investigate first)

---

## Priority 2: High-Value UX

### ~~#235 — Macros per food item and meal~~ ✅ DONE
Macro totals shown per meal section header + compact per-item badge in intake cards.

### ~~#277 — Disable activity tracking option~~ ✅ DONE
Settings toggle persisted via `ConfigDBO.showActivityTracking` → `HomeLoadedState.showActivityTracking`.
`ActivityVerticalList` conditionally shown on home page based on setting.

### #267/#174 — Custom meals not findable before first use
**Problem:** Custom meals only appear in "Recently Added" after being logged once
**Fix:** Persist custom meal templates in separate Hive box; include in recent search
**Effort:** Medium (3-4 hours)

---

## Priority 3: Medium Features

### #232 — Direct macro input for custom meals
**Problem:** Edit meal screen requires per-100g values; no total macro input option
**Effort:** Medium (3-4 hours)

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
