# OpenNutriTracker — Overall Work Plan

**Source of truth:** `erikpt/OpenNutriTracker` — `main`
**Last Updated:** 2026-03-14

All new branches must be cut from `erikpt/main`. PRs target fork `main` first, then upstream.

---

## ✅ COMPLETED (in main)

### Critical Bugs
- ✅ **#154** — Diary navigation after future entry (PR #6)
- ✅ **#182** — Diary kcal display and stale cache self-heal
- ✅ **#212** — Duplicate food warning dialog
- ✅ **#213** — Nutritional consistency validation (macros ≤ base qty, kcal ≤ base×9)
- ✅ **#222** — FDC import validation
- ✅ **#252** — FDC Atwater energy priority: 1008 → 958 → 957
- ✅ **#262/#239/#220** — Keyboard dismissal / IME focus loss
- ✅ **#288/#242** — Weight field showed "invalid height" error
- ✅ **#306** — OFF search crash (null nutriments)

### Input Validation
- ✅ **#199** — Future birth dates blocked
- ✅ **#200/#201** — Zero weight/height prevented
- ✅ **#204** — Max height 15ft/457cm
- ✅ **#207** — Future dates in diary calendar blocked
- ✅ **#208** — Activity indicator stale after deletion
- ✅ **#209/#210** — Quantity > 0 and ≤ 10,000
- ✅ **#211** — Meal name must contain a letter
- ✅ **#214** — Custom food name required
- ✅ **#216/#217** — Negative weight/height prevented
- ✅ **#244** — Decimal weight supported
- ✅ **#253** — Imperial weight minimum 20 lbs

### Features / UX
- ✅ **#118/#143/#151** — Yoga (2.5 MET), HIIT (8.0 MET), calisthenics (8.0 MET)
- ✅ **#174/#267** — Custom meal templates persisted for discoverability
- ✅ **#232** — Total nutrient input mode for custom meals
- ✅ **#235** — Macro display per food item and meal
- ✅ **#277** — Disable activity tracking (settings toggle)
- ✅ **#282** — German l10n for unit system names
- ✅ **#291** — Recent meals list extended to 500
- ✅ **#309** — Exceeded kcal shown in red ("X kcal exceeded")

### Micronutrients (PR #8 / upstream PR #314 — open, pending merge)
- ✅ **#237** — Full micronutrient tracking: 17 fields (lipids, minerals, vitamins), Settings toggle, EN/DE/TR l10n

---

## 🎯 NEXT: OPEN ISSUES

### Low/Medium Effort
| # | Title | Notes |
|---|---|---|
| **#281** | Update weight on landing screen | Home screen shortcut widget |
| **#290** | Update to 2024 Compendium of Physical Activities | MET data update |
| **#292** | Diary overwrites after 1 year | Hive key collision bug |
| **#297** | Manual kcal/macro input in calculations | Text input instead of sliders |

### Medium Effort
| # | Title | Notes |
|---|---|---|
| **#284** | Weekly weight goal | New goal type, affects kcal calc |
| **#298** | Custom food item creation UI | Improve UX for adding custom foods |
| **#312** | Notification reminders | Platform notification API |

### High Effort
| # | Title | Notes |
|---|---|---|
| **#279** | Multi-ingredient meals | Most requested; significant data model work |

---

## 📊 Status Summary

| Category | Done | Remaining |
|:---------|:----:|:---------:|
| Bug fixes | 14 | 1 (#292) |
| Input validation | 11 | 0 |
| Features / UX | 9 | 7 |
| Micronutrients | 1 (PR open) | 0 |
