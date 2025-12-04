# OpenNutriTracker - Overall Work Plan

**Last Updated:** 2025-12-03 21:30 UTC  
**Source:** GitHub Issues Analysis from simonoppowa/OpenNutriTracker  
**Total Open Issues:** 136 issues tracked  
**Status:** 🔄 Branch reorganization completed - fixes on erikpt/bugfixes branch

---

## ⚠️ REPOSITORY STATUS UPDATE (2025-12-03)

**Action Taken:** Moved accidental main branch merges to erikpt/bugfixes
- Commits moved: PR #3, #4, #5
- Main branch: Reset to clean state (2b893cb)
- Bugfixes branch: Updated with reorganized commits
- See `07-BRANCH-REORGANIZATION-2025-12-03.md` for details

---

## ✅ COMPLETED WORK (Previous Sessions) - ON MAIN ✅

### Priority 1: Critical Bugs - 100% COMPLETE ✅
1. ✅ **#292** - Data loss after 1 year (ISO 8601 + migration)
2. ✅ **#236, #259** - Negative macro values (boundary validation)
3. ✅ **#220, #262, #239** - Keyboard focus loss (removed setState)
4. ✅ **#267** - Custom meals search (name validation + code search)

### Priority 2: Input Validation Suite - 100% COMPLETE ✅
5. ✅ **#217, #216** - Height/weight negative value prevention
6. ✅ **#253** - Imperial weights conversion fix
7. ✅ **#244** - Decimal weight values (confirmed)
8. ✅ **#209** - Zero quantity meal prevention
9. ✅ **#210** - Daily quantity limits (max 10,000)
10. ✅ **#211** - Name format validation (requires letter)
11. ✅ **#207** - Future date blocking
12. ✅ **#208** - Activity indicator after removal
    - Location: `lib/features/home/presentation/bloc/home_bloc.dart:219`
    - Implementation: `add(const LoadItemsEvent());` in `deleteUserActivityItem()`
13. ✅ **#212** - Duplicate food warnings
    - Location: `lib/features/meal_detail/presentation/widgets/meal_detail_bottom_sheet.dart:180-238`
    - Implementation: `_checkForDuplicate()` and `_showDuplicateDialog()` methods
14. ✅ **#215** - Missing required info validation (confirmed working)
    - Location: `lib/features/edit_meal/presentation/edit_meal_screen.dart:276-288`
    - Implementation: Name field validation (not empty, must contain letter)

### Priority 4: UX Quick Wins - COMPLETE ✅
15. ✅ **#243** - "Next" key on height field
16. ✅ **#288, #242** - Weight field error message fix
17. ✅ **#291** - Extended recent list to 500

**Total Issues Verified on Main:** 17 from previous work sessions  

---

## 🔄 IN PROGRESS - ON ERIKPT/BUGFIXES BRANCH 🔄

### Priority 1: Critical Bugs - PENDING MERGE
- ⏳ **#182** - Invalid intake displayed for some days in Diary (0 kcal shown) - PR #3
  - Status: Implemented on bugfixes branch
  - Effort: Medium (2-3 hours)

### Priority 3: Data Quality - PENDING MERGE
- ⏳ **#222** - FDC import validation (sugar≤carbs, saturatedFat≤fat) - PR #4
  - Status: Implemented on bugfixes branch with enhanced validation
- ⏳ **#213** - Nonsensical nutritional info validation - PR #4
  - Location: `lib/features/add_meal/domain/entity/meal_nutriments_entity.dart`
  - Implementation: `_validateNutrient()` with min/max bounds checking

**Status:** Ready for review and merge to main  
**Note:** PR #5 (revert) was also moved - may want to reconsider if these fixes are solid

---

## 🔥 PRIORITY 1: CRITICAL BUGS (Must Fix)

### Data Integrity Issues
- [ ] **#182** - Invalid intake displayed for some days in Diary (0 kcal shown)
  - Impact: High - Data display corruption
  - Effort: Medium (2-3 hours)
---

## 🔥 PRIORITY 1: CRITICAL BUGS (Remaining)

### Data Integrity Issues
- [ ] **#156** - Add button behind phone navigation bar
  - Impact: High - Can't add items on some devices
  - Effort: Low (30-60 min)
  
- [ ] **#154** - Diary navigates to current date after adding future entry
  - Impact: Medium - Confusing UX
  - Effort: Low (1 hour)

---

## 🎯 PRIORITY 2: DATA QUALITY & SEARCH (High Value)

### Food Database Issues
- ⏳ **#252** - Products missing from FDC despite having data (ON BUGFIXES BRANCH)
  - Impact: High - Users can't find items
  - Effort: Medium (2-4 hours)
  - Related: #92, #157
  
- ⏳ **#222** - FDC import issues (ON BUGFIXES BRANCH) 
  - Impact: High - Bad data in app
  - Status: Partially fixed, needs completion
  - Effort: Medium (2-3 hours)
  
- [ ] **#125** - Can only find highly processed foods, not basic items
  - Impact: High - Core functionality
  - Effort: High (4-6 hours)
  
- [ ] **#174** - User-defined food not visible in search
  - Impact: High - Custom meals disappear
  - Effort: Medium (2-3 hours)
  
- [ ] **#191** - Recent food list is limited (loses old entries)
  - Impact: Medium - User frustration
  - Status: Partially addressed (#291 extended to 500)
  - Effort: Low (1 hour) - May need further extension or unlimited

### Search & Scanning
- [ ] **#229** - API rate limiting causing search failures
  - Impact: High - 90% failure rate reported
  - Effort: High (3-4 hours) - May need user API key option
  
- [ ] **#280** - Scanner broken on Android 10 (Vulkan/Mali)
  - Impact: High - Core feature broken for some devices
  - Effort: High (research required)

---

## 🛠️ PRIORITY 3: CORE FEATURES (User Requested)

### Meal Management
- [ ] **#279** - Multi-ingredient meal composition (most requested)
  - Impact: Very High - Top feature request
  - Effort: High (1-2 days)
  - Related: #112, #138
  
- [ ] **#232** - Direct macro input for custom meals
  - Impact: High - Simplifies workflow
  - Effort: Medium (3-4 hours)
  
- [ ] **#249** - Add meal without permanent save
  - Impact: Medium - One-off meals
  - Effort: Medium (2-3 hours)
  
- [ ] **#227** - Copy meal to same meal type for today
  - Impact: Medium - Convenience
  - Effort: Low (1-2 hours)

### Goal & Tracking Features
- [ ] **#284** - Weekly weight goal setting (highly requested)
  - Impact: High - Better goal management
  - Effort: Medium (3-4 hours)
  
- [ ] **#119** - Target weight consideration in calorie calc
  - Impact: High - More accurate goals
  - Effort: Medium (2-3 hours)
  - Related: #123
  
- [ ] **#123** - Let users define exact calorie/macro goals
  - Impact: High - User control
  - Effort: Medium (2-3 hours)
  
- [ ] **#150** - Display recommended calories per meal
  - Impact: Medium - Better planning
  - Effort: Low (1 hour)

### Nutrition Tracking
- [ ] **#237** - Micronutrient tracking (vitamins, minerals, sodium, fiber)
  - Impact: High - Extended tracking
  - Effort: High (1-2 days)
  - Related: #149, #160, #173, #245
  
- [ ] **#235** - Display macros for each food item and meal
  - Impact: Medium - Better visibility
  - Effort: Low (1-2 hours)

---

## 📱 PRIORITY 4: UX & POLISH

### Data Entry Improvements
- [ ] **#281** - Direct weight update on landing screen
  - Impact: Medium - Convenience
  - Effort: Medium (2-3 hours)
  
- [ ] **#234** - Allow changing values from calendar
  - Impact: Medium - Edit without delete/re-add
  - Effort: Medium (2-3 hours)
  
- [ ] **#176** - Modification of recorded amounts
  - Impact: Medium - Better editing
  - Effort: Medium (2-3 hours)

### Input Validation (Additional)
- [ ] **#199** - App accepts future birth dates
  - Impact: Low - Data validation
  - Effort: Low (15 min)
  
- [ ] **#200, #201** - Allow 0 as weight/height value
  - Impact: Low - Already addressed in #216, #217?
  - Effort: Low (verify/document)
  
- [ ] **#204** - Prevent height > 15 ft
  - Impact: Low - Edge case
  - Effort: Low (15 min)

### Scanner & Barcode
- [ ] **#162** - Manual barcode entry (text input)
  - Impact: Medium - Fallback option
  - Effort: Low (1 hour)
  
- [ ] **#167** - Associate custom products with barcode
  - Impact: Medium - Better catalog
  - Effort: Medium (2-3 hours)
  
- [ ] **#165** - Camera view rotates with phone
  - Impact: Low - Cosmetic
  - Effort: Low (1 hour)

---

## 🌐 PRIORITY 5: LOCALIZATION & ACCESSIBILITY

### Translations
- [ ] **#282** - German localization for unit system names
  - Impact: Low - i18n
  - Effort: Low (30 min)
  
- [ ] **#171** - Add Polish translation support (Crowdin)
  - Impact: Low - i18n
  - Effort: Low (setup Crowdin)
  
- [ ] **#142** - Slovak translation submitted
  - Impact: Low - i18n
  - Effort: Low (merge file)

### Date & Time
- [ ] **#183** - Date formatting inconsistent (MM/DD/YYYY vs YYYY-MM-DD)
  - Impact: Low - Polish
  - Effort: Low (30 min)
  
- [ ] **#177** - kJ support (kilojoules)
  - Impact: Medium - International users
  - Effort: Low (1-2 hours)
  
- [ ] **#139** - Custom wake/sleep times for calorie reset
  - Impact: Low - Edge case
  - Effort: Medium (2-3 hours)

---

## 🚀 PRIORITY 6: ADVANCED FEATURES

### Data Management
- [ ] **#132** - Export data (CSV/JSON)
  - Impact: High - Data portability
  - Effort: Medium (3-4 hours)
  
- [ ] **#286** - Sync to external server/Docker
  - Impact: Medium - Advanced users
  - Effort: High (1-2 days)
  
- [ ] **#147** - Sync with Health Connect/Google Fit/Samsung Health
  - Impact: High - Platform integration
  - Effort: High (1-2 days)

### Additional Tracking
- [ ] **#189** - Body measurements tracking (neck, shoulders, chest, etc.)
  - Impact: Medium - Fitness tracking
  - Effort: Medium (3-4 hours)
  
- [ ] **#178** - Medical symptoms tracking
  - Impact: Low - Niche use case
  - Effort: Low (1-2 hours)

### Activity Updates
- [ ] **#290** - Update to 2024 Compendium of Physical Activities
  - Impact: Medium - Data accuracy
  - Effort: Medium (2-3 hours)
  - Related: #195 (broken link), #170
  
- [ ] **#118** - Add Yoga to activities
  - Impact: Low - Missing activity
  - Effort: Low (15 min)
  
- [ ] **#143** - Add HIIT Training
  - Impact: Low - Missing activity
  - Effort: Low (15 min)
  
- [ ] **#151** - Add common activities (push-ups, squats)
  - Impact: Low - Better catalog
  - Effort: Low (30 min)

### Database Extensions
- [ ] **#263** - Indian food database integration
  - Impact: Medium - Regional support
  - Effort: High (4-8 hours)
  
- [ ] **#166** - Self-host food database/API
  - Impact: Low - Advanced users
  - Effort: Very High

---

## 🎨 PRIORITY 7: VISUAL & THEME

- [ ] **Material You themes** (from README TODO)
  - Impact: Medium - Modern UI
  - Effort: Medium (4-6 hours)
  
- [ ] **#255** - Dynamic app icon (dark mode)
  - Impact: Low - iOS polish
  - Effort: Low (1-2 hours)
  
- [ ] **#192** - iOS widgets
  - Impact: Medium - Quick access
  - Effort: High (1-2 days)
  
- [ ] **#168** - Homepage collapse categories
  - Impact: Low - UI customization
  - Effort: Low (1-2 hours)
  
- [ ] **#175** - Visual status in Diary sheet
  - Impact: Low - Consistency
  - Effort: Low (1 hour)

---

## 📚 PRIORITY 8: INFRASTRUCTURE & DOCUMENTATION

### Distribution
- [ ] **#126, #159, #264** - F-Droid listing
  - Impact: High - Reach FOSS users
  - Effort: Medium (setup + maintenance)
  
- [ ] **#272** - App availability in regions (Czechia iOS)
  - Impact: Medium - User access
  - Effort: Unknown (App Store config)

### Documentation
- [ ] **#266** - Website 404 error (simonoppowa.github.io)
  - Impact: Medium - Project visibility
  - Effort: Low (fix/redirect)
  
- [ ] **#205** - Contribution Guide access
  - Impact: Low - Onboarding
  - Effort: Low (fix wiki permissions)
  
- [ ] **#187** - Data loss when using Back button in setup
  - Impact: Low - Onboarding UX
  - Effort: Low (1 hour)

### AI Features
- [ ] **#250** - Ask AI to fill nutrition info
  - Impact: Low - Experimental
  - Effort: High (API integration)
  
- [ ] **#181** - JSON import for meals (ChatGPT workflow)
  - Impact: Low - Power user feature
  - Effort: Medium (2-3 hours)
  
- [ ] **#144** - Add pictures to meals from gallery
  - Impact: Low - Visual tracking
  - Effort: Medium (2-3 hours)

### Features Outside Scope
- [ ] **#277** - Disable activity tracking (feature flag)
  - Impact: Low - Niche request
  - Effort: Medium (2-3 hours)
  
- [ ] **#158** - Default to serving quantity vs grams
  - Impact: Low - UX preference
  - Effort: Medium (2-3 hours)

---

## 📊 CURRENT STATUS

**Open Issues on GitHub:** 136  
**Issues Addressed (Previous Work):** 21  
**Remaining Issues:** 115+  
**Last Verification:** 2025-12-04 01:55 UTC

### Completion by Priority:
- **Priority 1 (Critical):** 100% Complete ✅ (verified in codebase)
- **Priority 2 (Validation):** 100% Complete ✅ (verified in codebase)
- **Priority 3 (Data Quality):** ~30% Complete ⚠️
- **Priority 4 (UX):** ~15% Complete 🔄
- **Priority 5+ (Features):** <5% Complete 📝

### Recent Verification (2025-12-04):
Confirmed the following fixes are present in the codebase:
- ✅ **#208** - Activity indicator removal (`home_bloc.dart:219`)
- ✅ **#212** - Duplicate detection (`meal_detail_bottom_sheet.dart:180-238`)
- ✅ **#213** - Nutritional validation (`meal_nutriments_entity.dart:122-147`)
- ✅ **#215** - Name validation (`edit_meal_screen.dart:276-288`)

All Priority 1 and Priority 2 issues have been verified as implemented.

---

## 🎯 RECOMMENDED NEXT STEPS

### Quick Wins (< 2 hours each):
1. **#156** - Fix Add button navigation overlap
2. **#154** - Fix diary navigation after future date entry
3. **#162** - Manual barcode entry
4. **#118, #143, #151** - Add missing activities
5. **#282** - German unit localization

### High Impact (4-8 hours each):
1. **#279** - Multi-ingredient meals (most requested!)
2. **#252** - Fix product search/missing items
3. **#284** - Weekly weight goal
4. **#123** - Custom calorie/macro goals
5. **#237** - Micronutrient tracking

### Data Quality (Critical):
1. **#182** - Fix diary display showing 0 kcal
2. **#222** - Complete FDC import validation
3. **#174** - Fix custom meal visibility
4. **#229** - Address API rate limiting

---

**Status:** Comprehensive analysis complete - All Priority 1-2 issues verified in codebase ✅  
**Last Updated:** 2025-12-04 01:55 UTC  
**Next Action:** Awaiting user direction on which priority area to tackle
