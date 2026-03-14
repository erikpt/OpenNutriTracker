# 🎯 QUICK REFERENCE - Current State at a Glance

**As of:** March 13, 2026  
**Working Branch:** erikpt/fix-issue-263-keyboard-dismissal (active PR #313)

---

## 📍 CURRENT BRANCH STATUS

### erikpt/fix-issue-263-keyboard-dismissal (ACTIVE PR #313)
```
Status: 🟡 BRANCH EXISTS — NO CODE CHANGES YET
Base: erikpt/bugfixes (all prior fixes included)
```

**What's on this branch (inherited from erikpt/bugfixes):**
- ✅ PR #6: Issue #154 - Diary navigation fix (MERGED)
- ✅ PR #7: Technical debt fixes (MERGED)
- ✅ All validation, critical bugs, UX fixes
- 🔴 **#263 keyboard dismissal — not yet implemented** (this branch's purpose)

### 🔴 ACTIVE BUG: use_build_context_synchronously (5 violations)
```
File: lib/features/meal_detail/presentation/widgets/meal_detail_bottom_sheet.dart
Lines: 183, 190, 205, 206, 207
Risk: Widget unmount crash between async gap and BuildContext use
Fix needed: Add `if (!context.mounted) return;` after await _checkForDuplicate()
```

### erikpt/bugfixes / main branch
```
PR #7 merged. 24+ issues complete. Stable baseline.
```

---

## ✅ WHAT'S COMPLETE

### Critical Bugs & Input Validation (All Done)
| Issue | Title | Status |
|:---:|:---|:---:|
| #292 | Data loss after 1 year | ✅ |
| #236, #259 | Negative macro values | ✅ |
| #220, #262, #239 | Keyboard focus loss | ✅ |
| #267 | Custom meals search | ✅ |
| #217, #216 | Height/weight validation | ✅ |
| #253, #244 | Weight conversion & decimals | ✅ |
| #209, #210 | Quantity validation | ✅ |
| #211, #207 | Name & date validation | ✅ |
| #208 | Activity indicator after removal | ✅ |
| #215 | Missing required info | ✅ |
| #243 | "Next" key on height field | ✅ |
| #288, #242 | Weight error message | ✅ |
| #291 | Recent list extended to 500 | ✅ |

### Recently Completed (Sessions 3-4)
| Issue | Title | Status |
|:---:|:---|:---:|
| #154 | Diary navigation after future entry | ✅ PR #6 Merged |
| #229 | API rate limiting | ⚠️ NOT IN CODE (possibly reverted in PR #5) |
| #125 | Search quality improvements | ⚠️ NOT IN CODE (possibly reverted in PR #5) |
| #212 | Duplicate meal detection | ✅ Implemented |
| — | DayRating enum (tech debt) | ✅ PR #7 |
| — | LoadCalendarDayEvent props bug | ✅ PR #7 |
| — | Analyzer errors reduced (PR #7) | ⚠️ 19 info-level remain |

---

## 🔥 HIGH PRIORITY REMAINING

### Immediate (Active Branch #313)
- [ ] **#263** - Keyboard dismissal — `GestureDetector` + `FocusScope.unfocus()` or `ScrollView.keyboardDismissBehavior`
- [ ] **BUG** - Fix `use_build_context_synchronously` in `meal_detail_bottom_sheet.dart` (5 violations, crash risk)

### Technical Debt
- [ ] Localize hardcoded validation strings in `set_weight_dialog.dart`, `set_height_dialog.dart`, `meal_detail_bottom_sheet.dart`, `edit_meal_screen.dart`
- [ ] Replace `assert(x != null)` with proper null handling in `home_bloc.dart` lines 160/163
- [ ] Investigate/re-implement #229 (rate limiting) and #125 (search quality) — code not present
- [ ] Lower OFF timeout from 20s (`off_data_source.dart` TODO)

### High Impact Features
- [ ] **#279** - Multi-ingredient meals ⭐ MOST REQUESTED
- [ ] **#222** - FoodData Central import issues (reverted in PR #5 — needs re-implementation)
- [ ] **#284** - Weekly weight goals
- [ ] **#280** - Meal templates/favorites
- [ ] **#126** - Search history (Low effort)

---

## 📚 DOCUMENTATION ROADMAP

**START HERE:** `README.md` - Overview of all work items

**Details by Topic:**
- Latest updates → `10-STATUS-UPDATE-2025-12-04.md` ⭐
- Overall strategy → `00-OVERALL-PLAN.md`
- Current hot issues → `06-CURRENT-STATUS-2025-12-03.md`
- Open work items → `02-REMAINING-TASKS.md`
- Technical debt → `09-TECHNICAL-DEBT-FIXES.md`

---

## 💡 QUICK DECISIONS

**Q: What should I work on next?**  
A: First fix the `use_build_context_synchronously` crash bug in `meal_detail_bottom_sheet.dart`, then implement **#263 (Keyboard dismissal)** on this branch.

**Q: How much work is completed?**  
A: ~22+ verified issues done (ALL critical bugs, input validation). #229 and #125 are claimed complete but code is absent — investigation needed.

**Q: Are there any open PRs?**  
A: Yes — PR #313 (this branch, #263 keyboard dismissal — not yet started).

---

## 🔧 QUICK COMMANDS

```bash
# Use FVM for correct Flutter version
fvm flutter analyze    # Run analyzer
fvm flutter test       # Run tests
fvm flutter pub get    # Get dependencies

# Branch operations
git checkout erikpt/bugfixes           # Switch to working branch
git checkout erikpt/fix-technical-debt # Current feature branch

# Create PR with GitHub CLI
gh pr create --base erikpt/bugfixes --head <branch> --title "title"
```

---

**Last Updated:** 2026-03-13  
**Questions?** See detailed docs in `.copilot/workitems/`
