# Quick Reference — OpenNutriTracker

**Branch:** `erikpt/fix-issue-263-keyboard-dismissal`
**PR:** #313 → simonoppowa/OpenNutriTracker
**Last Updated:** 2026-03-11

---

## ✅ Completed Issues (this branch)

### Keyboard / Focus
- **#262/#239/#220** — Keyboard dismissal (GestureDetector + keyboardDismissBehavior in add_meal_screen.dart)

### Input Validation
- **#199** — Future birth dates blocked (`lastDate: DateTime.now()` in onboarding + profile)
- **#200/#201** — Zero weight/height prevented (minWeight 10kg/20lbs, minHeight 50cm/1ft)
- **#204** — Height > 15ft/457cm blocked (cap in set_height_dialog.dart)
- **#207** — Future dates blocked in diary calendar (`lastDay: widget.currentDate`)
- **#208** — Activity indicator removed after deletion (`LoadItemsEvent()` in home_bloc.dart)
- **#209/#210** — Zero/excessive quantity blocked in meal_detail_bottom_sheet (> 0, ≤ 10000)
- **#211** — Meal name must contain a letter (edit_meal_screen.dart)
- **#212** — Duplicate meal warning dialog (meal_detail_bottom_sheet.dart)
- **#214** — Custom food name required (edit_meal_screen.dart)
- **#216/#217** — Negative weight/height prevented (minValue clamped)
- **#244** — Decimal weight supported (divisions: 1000 in set_weight_dialog.dart)
- **#253** — Imperial weight min set (20 lbs)

### Data Quality
- **#252** — FDC Atwater energy fallback order: 1008 → 958 (Specific) → 957 (General)
- **#306** — OFF search crash fixed (nullable nutriments in OFFProductDTO)

### Features / UX
- **#118/#143/#151** — Yoga (2.5 MET), HIIT (8.0 MET), calisthenics/squats (8.0 MET) added
- **#282** — German l10n for unit system names
- **#291** — Recent meals list extended to 500
- **#309** — Exceeded kcal shown in red on dashboard ("X kcal exceeded")

### Bug Fixes
- **assert→null guard** — home_bloc.dart updateIntakeItem (crash fix)
- **use_build_context_synchronously** — meal_detail_bottom_sheet.dart (crash fix)

---

## 🔄 Remaining High-Priority Items

| # | Title | Effort |
|---|-------|--------|
| #213 | Nonsensical nutritional info accepted (sugar > carbs, etc.) | Medium |
| #182 | Diary shows 0 kcal for some days (date range bug) | Medium |
| #235 | Display macros per food item/meal | Low |
| #267/#174 | Custom meals searchable without prior add | Medium |
| #277 | Option to disable activity tracking | Medium |
| #232 | Direct macro input for custom meals | Medium |
| #279 | Multi-ingredient meal composition | High |
| #222 | FDC import validation (reverted in PR #5) | High |

---

## ⚠️ l10n Procedure (cannot run generator)

New l10n keys must be manually added to **5 files**:
1. `lib/l10n/intl_en.arb`
2. `lib/l10n/intl_de.arb`
3. `lib/l10n/intl_tr.arb`
4. `lib/generated/l10n.dart` (add getter method)
5. `lib/generated/intl/messages_en.dart`, `messages_de.dart`, `messages_tr.dart` (add to map)

**Why:** `flutter gen-l10n` requires `flutter: generate: true` in pubspec (not set). `intl_utils:generate` fails due to `intl` version conflict between app (`^0.19.0`) and flutter_localizations SDK (`0.20.2`).
