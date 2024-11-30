# Cleanup Duration Usage in aw-watcher-lastfm

## Overview
There are pending changes in aw-watcher-lastfm that need to be reviewed, cleaned up, and committed. The changes primarily involve:
- Consolidating Duration imports
- Updating deprecated timestamp handling
- Code formatting improvements

## Current Status
Changes are currently uncommitted in the working directory.

## Objectives
1. Review and commit pending changes
   - [ ] Review Duration usage consolidation
   - [ ] Check timestamp handling updates
   - [ ] Verify code formatting changes
   - [ ] Add/update tests if needed
   - [ ] Commit changes with clear message

2. Update deprecated timestamp handling
   - [ ] Remove TODO about deprecated from_utc
   - [ ] Implement modern timestamp handling
   - [ ] Test with various time zones

3. Add tests for time parsing
   - [ ] Add unit tests for parse_time_string
   - [ ] Test edge cases and invalid inputs
   - [ ] Verify Duration handling in tests

## Implementation Plan
1. First pass:
   - Review existing changes
   - Create test cases for current functionality
   - Commit current cleanup

2. Second pass:
   - Update deprecated timestamp handling
   - Add new tests
   - Document changes

## Success Criteria
- All Duration usage is consistent
- No deprecated timestamp handling remains
- Code passes all tests
- Changes are committed with clear documentation
