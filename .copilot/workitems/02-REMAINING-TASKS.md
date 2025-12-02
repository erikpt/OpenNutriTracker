# 🔄 REMAINING TASKS - Prioritized

## Priority 2B: Remaining Input Validation (Quick Wins)

### #208 - Activity Indicator After Removal
**Problem:** Activity indicator stays visible after removing activity  
**Files:** lib/features/home/presentation/bloc/home_bloc.dart  
**Effort:** Low (1-2 hours)

### #212 - Duplicate Food Additions
**Problem:** Same food can be added multiple times without warning  
**Solution:** Check existing intakes, offer to merge or warn  
**Effort:** Medium (2-4 hours)

### #213 - Nonsensical Nutritional Info
**Problem:** App accepts illogical data (sugar > carbs, etc.)  
**Solution:** Add consistency validation rules  
**Effort:** Medium (2-4 hours)

### #215 - Missing Required Info Blocking
**Problem:** App may block saving with complete info  
**Solution:** Review and fix validation logic  
**Effort:** Low (investigate first)

---

## Priority 3: Data Quality Issues (High Impact)

### #222 - FoodData Central Import Issues ⚠️
**Problem:** 
- Missing energy values
- Fiber weights 20x too high
- Bad data from FDC API

**Solution:**
- Add validation on import (sugar < carbs, saturatedFat < fat)
- Sanity checks (total macros < 100g per 100g)
- Log problematic items
- Handle missing data gracefully

**Files:** 
- lib/features/add_meal/data/data_sources/fdc_data_source.dart
- lib/features/add_meal/data/repository/products_repository.dart

**Effort:** High (4-8 hours)

### #252 - Products Missing from FDC
**Problem:** Some products don't appear in FDC results  
**Solution:** Investigate API query parameters  
**Effort:** Medium (2-4 hours)

### #288, #242 - Weight Field Error Message
**Problem:** Weight field shows "Invalid height" error  
**Solution:** Fix error message mapping  
**Effort:** Low (30 min)

---

## Priority 4: UX Improvements

### #243 - "Next" Key on Height Field
**Problem:** Height field doesn't use "next" keyboard action  
**Solution:** Change TextInputAction to next  
**Effort:** Low (15 min)

### #281 - Direct Weight Update on Landing
**Problem:** Can't update weight from main screen  
**Solution:** Add weight update widget to home  
**Effort:** Medium (2-3 hours)

### #291 - Extend Recent List
**Problem:** Recent list limited to 200 entries  
**Solution:** Increase limit or add pagination  
**Effort:** Low (30 min)

---

## Priority 5: Feature Additions

### #237 - Micronutrient Tracking
**Problem:** Only tracks macros, not vitamins/minerals  
**Solution:** Extend data model and UI  
**Effort:** High (1-2 days)

### #279 - Multi-Ingredient Meals
**Problem:** Can't create meals from multiple foods  
**Solution:** Add meal composition feature  
**Effort:** High (1-2 days)

### #232 - Direct Macro Input
**Problem:** Can't directly input macros for custom meals  
**Solution:** Add macro input fields option  
**Effort:** Medium (3-4 hours)

### #284 - Weekly Weight Goals
**Problem:** Only daily goals, no weekly tracking  
**Solution:** Add weekly goal setting and tracking  
**Effort:** Medium (3-4 hours)

---

## Priority 6: Technical Debt

- Remove dummy data from user_data_source.dart (5 min)
- Make enum class for rating (30 min)
- Group activities by effort (1-2 hours)
- Update default totalQuantity (5 min)
- Translation keys for fdc_const (30 min)
- Extract unit parsing logic (1 hour)

---

## Priority 7: Infrastructure

- #280 - Scanner on Android 10 (research required)
- #282 - German localization (30 min)
- #290 - Update activity compendium (1-2 hours)
- #229 - API rate limiting (2-3 hours)
- #263 - Indian food database (research + 4-8 hours)
- #266, #205, #272 - Documentation/deployment issues

---

## Effort Estimates

**Quick Wins (< 1 hour):** #243, #288, #291, dummy data removal  
**Low Effort (1-2 hours):** #208, #215, technical debt items  
**Medium Effort (2-4 hours):** #212, #213, #252, #281, #232, #284  
**High Effort (4+ hours):** #222, #237, #279, #263  

---

Last updated: 2025-12-02 23:45 UTC
