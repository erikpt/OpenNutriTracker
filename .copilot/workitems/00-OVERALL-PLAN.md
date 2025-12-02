# OpenNutriTracker - Overall Work Plan

## Priority 1: Critical Bugs (Data Integrity & Calculations) - ✅ COMPLETED

### 1.1 Data Loss Bug (#292)
- ~~Fix date key format to prevent year-based collisions~~
- ~~Add backward-compatible migration~~
- ~~Test data persistence across years~~
- ~~Verify no data loss occurs~~

### 1.2 Calculation Errors (#236, #259)
- ~~Investigate negative protein values~~
- ~~Fix calendar showing values without food added~~
- ~~Fix inaccurate past day calculations~~
- ~~Ensure proper increment/decrement logic~~

### 1.3 Custom Meals Search (#267)
- ~~Require name for custom meals (validation)~~
- ~~Improve search to include code field~~
- ~~Verify custom meals are findable~~

### 1.4 Keyboard Focus Issues (#220, #262, #239)
- ~~Fix base quantity field losing focus~~
- ~~Fix keyboard dismissing on each keystroke~~
- ~~Fix IME disappearing while inputting~~

## Priority 2: Input Validation Suite (IN PROGRESS)

### 2.1 Height/Weight Validation
- Prevent negative height values (#217)
- Prevent negative weight values (#216)
- Fix Imperial weights not setting correctly (#253)
- Add decimal value support for weight (#244)

### 2.2 Meal Input Validation
- ~~Require food name (#214) - DONE in #267~~
- Prevent zero quantity meals (#209)
- Add daily quantity limits (#210)
- Prevent nonsensical nutritional info (#213)
- Require at least one letter in food names (#211)
- Warn on duplicate food additions (#212)
- Block food items missing required info (#215)

### 2.3 Temporal Validation
- Prevent data entry on future dates (#207)
- Fix activity indicator remaining after removal (#208)

### 2.4 Data Quality
- Fix FoodData Central import issues (#222)

## Current Status
- ✅ Completed: Priority 1 - Critical Bugs (4 issues fixed)
- 🔄 Working on: Priority 2 - Input Validation Suite
- Last updated: 2025-12-02 23:26 UTC

## Recent Commits
- 11650bb - Fix #267: Custom meals search
- c7308f2 - Migration for backward compatibility (#292)
- 252df53 - Refactor: extract helper method
- 0c6a0a7 - Fix keyboard focus issue
- 0fa2ba2 - Fix data loss and negative values
- abb2ebd - Initial plan
