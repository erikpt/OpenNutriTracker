# OpenNutriTracker - Overall Work Plan

## ✅ COMPLETED WORK

### Priority 1: Critical Bugs (Data Integrity & Calculations) - COMPLETE
- ✅ #292: Data loss after 1 year (ISO 8601 format + migration)
- ✅ #236, #259: Negative macro values (boundary validation)
- ✅ #220, #262, #239: Keyboard focus issues (removed setState)
- ✅ #267: Custom meals search (name validation + code search)

### Priority 2A: Input Validation Suite - COMPLETE
- ✅ #217, #216: Height/weight negative value prevention
- ✅ #253: Imperial weights conversion fix
- ✅ #244: Decimal weight values (already supported)
- ✅ #209: Zero quantity validation
- ✅ #210: Daily quantity limits (max 10,000)
- ✅ #211: Name format validation (requires letter)
- ✅ #207: Future date blocking

**Total Issues Fixed: 15**
**Commits: 10**

---

## 🔄 REMAINING PRIORITY ISSUES

### Priority 2B: Remaining Input Validation (Medium Priority)
- [ ] #208 - Activity indicator remains after removal
- [ ] #212 - Duplicate food addition warnings
- [ ] #213 - Nonsensical nutritional info validation
- [ ] #215 - Missing required info blocking (may already work)

### Priority 3: Data Quality Issues (High Priority)
- [ ] #222 - FoodData Central import issues (missing energy, 20x fiber)
- [ ] #252 - Products missing from FDC
- [ ] #288, #242 - Weight field shows "Invalid height" error

### Priority 4: UX Improvements (Medium Priority)
- [ ] #243 - Use "next" key on height field
- [ ] #281 - Direct weight update on landing screen
- [ ] #291 - Extend recent list beyond 200 entries

### Priority 5: Feature Additions (Low-Medium Priority)
- [ ] #237 - Micronutrient tracking
- [ ] #232 - Direct macro input for custom meals
- [ ] #279 - Multi-ingredient meal composition
- [ ] #284 - Weekly weight goal setting
- [ ] #249 - Add meal without permanent save
- [ ] #227 - Copy meal to same meal type for today

### Priority 6: Technical Debt (Low Priority)
- [ ] Remove dummy data from user_data_source.dart
- [ ] Make enum class for rating in tracked_day_entity.dart
- [ ] Group activities in effort categories
- [ ] Change default totalQuantity from 0 to 60
- [ ] Make translation keys in fdc_const.dart
- [ ] Extract unit parsing logic
- [ ] Handle user birthday properly

### Priority 7: Infrastructure Issues (Low Priority)
- [ ] #280 - Scanner on Android 10 (Vulkan/Mali)
- [ ] #282 - Localize units system names for German
- [ ] #290 - Update to 2024 Compendium of Physical Activities
- [ ] #229 - API rate limiting
- [ ] #263 - Indian food database
- [ ] #266 - Website 404 error
- [ ] #205 - Contribution Guide access
- [ ] #272 - App availability in regions

---

## 📊 STATISTICS

**Issues Addressed:** 15 / ~50+  
**Completion Rate:** ~30%  
**Critical Bugs:** 100% Complete ✅  
**Input Validation:** 75% Complete  

---

## 🎯 RECOMMENDED NEXT PRIORITIES

1. **Priority 3: Data Quality** (#222, #252, #288) - Affects data integrity
2. **Priority 2B: Remaining Validation** (#208, #212, #213) - Quick wins
3. **Priority 4: UX Improvements** (#243, #281, #291) - User experience
4. **Priority 5: Feature Additions** (#237, #279, #284) - New capabilities

---

## Current Status
- Last updated: 2025-12-02 23:45 UTC
- Working Branch: copilot/list-open-tasks-analysis
- Commits on branch: 10
- Status: Ready for next priority selection
