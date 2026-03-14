# OpenNutriTracker — Overall Work Plan

**Branch:** `erikpt/fix-issue-263-keyboard-dismissal`
**PR:** #313 → simonoppowa/OpenNutriTracker
**Last Updated:** 2026-03-11

---

## ✅ COMPLETED

### Critical Bugs
- ✅ **#262/#239/#220** — Keyboard dismissal / IME focus loss (add_meal_screen.dart)
- ✅ **#212** — Duplicate food warning dialog (meal_detail_bottom_sheet.dart)
- ✅ **#182 (partial)** — Diary date range (tracked_day_data_source.dart, from PR #6)
- ✅ **#154** — Diary navigation after future entry (PR #6)

### Input Validation
- ✅ **#199** — Future birth dates (`lastDate: DateTime.now()`)
- ✅ **#200/#201** — Zero weight/height
- ✅ **#204** — Max height 15ft/457cm
- ✅ **#207** — Future dates in diary calendar
- ✅ **#208** — Activity indicator stale after deletion
- ✅ **#209/#210** — Quantity > 0, ≤ 10000
- ✅ **#211** — Meal name must contain a letter
- ✅ **#214** — Custom food name required
- ✅ **#215** — Save blocked: fixed (name is only required field for custom meals)
- ✅ **#216/#217** — Negative weight/height
- ✅ **#244** — Decimal weight
- ✅ **#253** — Imperial weight minimum

### Data Quality
- ✅ **#252** — FDC Atwater energy priority: 1008 → 958 → 957
- ✅ **#288/#242** — Weight field showed "invalid height" error
- ✅ **#306** — OFF search crash (null nutriments)

### UX / Features
- ✅ **#118/#143/#151** — Yoga, HIIT, calisthenics/squats added to activities
- ✅ **#243** — "Next" keyboard action on height picker
- ✅ **#282** — German l10n for unit system names
- ✅ **#291** — Recent meals extended to 500
- ✅ **#309** — Exceeded kcal display (red "X kcal exceeded")

### Technical Debt (PR #7)
- ✅ DayRating enum for calorie goal rating colors
- ✅ assert → null guard in home_bloc.dart
- ✅ use_build_context_synchronously crash in meal_detail_bottom_sheet.dart

---

## 🔥 PRIORITY 1: REMAINING BUGS

### #213 — Nonsensical nutritional info accepted
- **Problem:** App accepts sugar > carbs, saturated fat > total fat, total macros > 100g per 100g
- **File:** `lib/features/add_meal/domain/entity/meal_nutriments_entity.dart`
- **Fix:** Add consistency validation in `fromOff/fromFDC` factories or in edit_meal_screen save

### #182 — Invalid diary display (0 kcal for some days)
- **Problem:** Some days show 0 kcal even though food was logged
- **File:** `lib/core/data/data_source/tracked_day_data_source.dart`
- **Fix:** Inclusive date range comparison (may already be partially fixed)

---

## 🎯 PRIORITY 2: HIGH-VALUE FEATURES

### #235 — Display macros per food item and meal
- **Impact:** High visibility — users want to see carbs/fat/protein per item
- **Files:** `lib/features/home/presentation/widgets/intake_vertical_list.dart`
- **Effort:** Low (UI addition only)

### #267/#174 — Custom/user-created meals not findable before first add
- **Problem:** Custom meals only appear in "Recently Added" after being logged once
- **Fix options:** (a) Store custom meals in a separate Hive box, search it alongside recent; (b) Document as expected behavior
- **Effort:** Medium

### #277 — Option to disable activity tracking
- **Problem:** Users who don't track activity can't hide the activity section
- **Fix:** Settings toggle to show/hide activity on home screen
- **Effort:** Medium

### #232 — Direct macro input for custom meals
- **Problem:** Custom meal creation requires entering per-100g values; no option to input total macros
- **Effort:** Medium

---

## 🚀 PRIORITY 3: LARGER FEATURES

### #279 — Multi-ingredient meal composition (most requested)
- **Problem:** Can't create a meal from multiple food items
- **Effort:** High (1-2 days)

### #222 — FDC import validation
- **Problem:** Bad data from FDC (e.g., fiber 20x too high, sugar > carbs)
- **Note:** Was implemented in PR #4 then reverted in PR #5
- **Fix:** Re-implement validation with sanitisation rules
- **Effort:** High

### #284 — Weekly weight goal
- **Effort:** Medium

### #237 — Micronutrient tracking
- **Effort:** High (data model changes)

---

## 📊 Status by Priority

| Priority | Count Done | Total | % |
|:---------|:----------:|:-----:|:-:|
| Critical bugs | 15+ | ~18 | ~85% |
| Input validation | 12 | 12 | 100% |
| Features | 5 | 20+ | ~25% |
| L10n / i18n | 2 | 5+ | ~40% |
