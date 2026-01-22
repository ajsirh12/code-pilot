---
name: Test-Driven Development
description: This skill should be used when the user asks about "TDD", "test-driven development", "write tests first", "red-green-refactor", "failing test", or needs TDD methodology guidance. Also triggered by "테스트 먼저", "TDD 방식", "레드-그린-리팩터".
version: 1.0.0
---

# Test-Driven Development (TDD)

This skill provides comprehensive guidance for implementing Test-Driven Development practices.

## Core Principle

Write the test first. Watch it fail. Write minimal code to pass.

The fundamental rule: if the test was not observed to fail, there is no confirmation that it validates the correct functionality.

## The Iron Law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST**

There are genuinely no exceptions to this requirement. Any code written before tests must be deleted entirely and reimplemented based on test specifications.

## The Red-Green-Refactor Cycle

### RED Phase

Write a single minimal test demonstrating desired behavior using clear naming and real code rather than mocks.

**Checklist:**
- Define one specific behavior to test
- Use descriptive test names (e.g., `test_user_creation_with_valid_email_succeeds`)
- Prefer real code over mocks where possible

### Verify RED

Run tests to confirm failure occurs for the expected reason (missing feature, not syntax errors).

**This verification step is mandatory—never skip it.**

### GREEN Phase

Implement the simplest possible solution passing the test without:
- Adding extra features
- Refactoring unrelated code
- Optimizing prematurely

### Verify GREEN

Confirm the test passes and all other tests remain passing with clean output.

### REFACTOR Phase

Clean up code only after achieving green:
- Remove duplication
- Improve naming
- Extract helpers
- Maintain all passing tests

## Why This Order Matters

Tests written after implementation pass immediately, proving nothing about correctness. They verify what was built rather than discovering what should be built. Manual testing remains unsystematic and irreproducible.

## Common Rationalizations (All Rejected)

| Rationalization | Response |
|----------------|----------|
| "Too simple to test" | Even simple code breaks; tests take 30 seconds |
| "I'll test after" | Passing immediately means nothing |
| "Already manually tested" | Ad-hoc testing cannot replace systematic verification |
| "Deleting hours of work is wasteful" | Unverified code represents technical debt |
| "Just this once" | There are no exceptions |
| "It's about the spirit, not the ritual" | The ritual IS the discipline |

## Red Flags Requiring Restart

Delete work and begin with TDD when any of these occur:
- Code written before tests
- Tests passing immediately on first run
- Tests added after implementation
- Any rationalization for skipping TDD

## Verification Checklist

Complete work only when:
- [ ] Every function has a failing test that was observed
- [ ] All tests pass
- [ ] Output is clean (no warnings)
- [ ] Real code is tested (minimal mocking)
- [ ] Edge cases are covered

## TDD Workflow Example

```
1. Write test: test_calculate_total_with_discount()
2. Run test → FAIL (calculate_total doesn't exist)
3. Implement minimal calculate_total()
4. Run test → PASS
5. Refactor if needed
6. Repeat for next behavior
```

## When to Mock

Mock only when:
- External services (APIs, databases in unit tests)
- Time-dependent operations
- Non-deterministic operations

Never mock:
- The code under test
- Simple value objects
- Internal implementation details

## Integration with CI/CD

Configure continuous integration to:
- Run all tests on every commit
- Fail builds on test failures
- Report coverage (aim for meaningful coverage, not 100%)

## Additional Resources

### Reference Files

For detailed testing anti-patterns and prevention strategies:
- **`references/testing-anti-patterns.md`** - Common testing anti-patterns and how to avoid them

## Quick Reference

| Phase | Action | Verify |
|-------|--------|--------|
| RED | Write failing test | Test fails for right reason |
| GREEN | Write minimal code | Test passes, others still pass |
| REFACTOR | Clean up code | All tests still pass |

## Best Practices Summary

**DO:**
- Write one test at a time
- Run tests after every change
- Keep tests fast (< 1 second each)
- Name tests descriptively
- Test behavior, not implementation
- Delete and restart if TDD was skipped

**DON'T:**
- Write code without a failing test
- Write multiple tests before implementing
- Mock excessively
- Skip the RED verification
- Rationalize exceptions
