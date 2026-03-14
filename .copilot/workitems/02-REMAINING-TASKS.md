# Remaining Tasks — Prioritized

**Last Updated:** 2026-03-11

---

## Priority 1: Bugs (Fix Next)

### #213 — Nonsensical nutritional info
**Problem:** App accepts sugar > carbs, saturatedFat > fat, total macros > 100g/100g
**File:** `lib/features/add_meal/domain/entity/meal_nutriments_entity.dart`
**Fix:** Validate on save in edit_meal_screen and/or clamp on import
**Effort:** Medium (2-3 hours)

### #182 — Diary shows 0 kcal for some days
**Problem:** Date comparison bug causes some logged days to show zero
**File:** `lib/core/data/data_source/tracked_day_data_source.dart`
**Effort:** Low-Medium (investigate first)

---

## Priority 2: High-Value UX

### #235 — Macros per food item and meal
**Problem:** Home screen only shows kcal per meal item; users want carbs/fat/protein
**Files:** `lib/features/home/presentation/widgets/intake_vertical_list.dart`
**Effort:** Low (1-2 hours — UI only)

### #277 — Disable activity tracking option
**Problem:** Users without activity tracking can't hide the section
**Fix:** Settings toggle → `ConfigEntity.showActivityTracking`
**Effort:** Medium (2-3 hours)

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
