# Testing Anti-Patterns

This reference documents common testing anti-patterns and provides guidance on avoiding them.

## Core Principle

Test what the code does, not what the mocks do.

Mocks serve to isolate components, not to be tested themselves.

## The Iron Laws

1. Never test mock behavior
2. Never add test-only methods to production classes
3. Never mock without understanding dependencies

## Five Key Anti-Patterns

### Anti-Pattern 1: Testing Mock Behavior

**Problem:** Verifying that mocks exist rather than testing actual component functionality.

**Example of bad test:**
```python
def test_user_service():
    mock_db = Mock()
    mock_db.get_user.return_value = {"id": 1, "name": "Test"}

    service = UserService(mock_db)
    result = service.get_user(1)

    # BAD: Testing mock behavior, not real behavior
    mock_db.get_user.assert_called_once_with(1)
    assert result == {"id": 1, "name": "Test"}  # Just echoing mock
```

**Fix:** Test real components or remove mocks entirely.

```python
def test_user_service():
    db = InMemoryDatabase()
    db.insert_user({"id": 1, "name": "Test"})

    service = UserService(db)
    result = service.get_user(1)

    # GOOD: Testing real behavior
    assert result["name"] == "Test"
```

### Anti-Pattern 2: Test-Only Methods in Production

**Problem:** Adding methods exclusively for test cleanup pollutes production code.

**Example of bad pattern:**
```python
class CacheManager:
    def get(self, key):
        return self._cache.get(key)

    def set(self, key, value):
        self._cache[key] = value

    # BAD: Test-only method in production code
    def _clear_for_testing(self):
        self._cache.clear()
```

**Fix:** Move cleanup logic to test utilities.

```python
# In test utilities, not production code
@pytest.fixture
def cache_manager():
    manager = CacheManager()
    yield manager
    # Cleanup handled by fixture, not production code
```

### Anti-Pattern 3: Mocking Without Understanding

**Problem:** Over-mocking prevents tests from verifying necessary side effects.

**Example of bad test:**
```python
def test_order_processing():
    # BAD: Mocking everything without understanding
    mock_inventory = Mock()
    mock_payment = Mock()
    mock_shipping = Mock()
    mock_notification = Mock()

    processor = OrderProcessor(
        mock_inventory, mock_payment, mock_shipping, mock_notification
    )
    processor.process_order(order)

    # What does this actually verify?
```

**Fix:** First understand what the test requires, then mock at the appropriate level.

```python
def test_order_processing_decrements_inventory():
    # GOOD: Mock only what's necessary
    inventory = InMemoryInventory({"SKU123": 10})
    processor = OrderProcessor(
        inventory=inventory,
        payment=FakePaymentProcessor(),  # Simple fake, not mock
        shipping=FakeShippingService(),
        notification=NullNotifier()
    )

    processor.process_order(Order(sku="SKU123", quantity=2))

    # Verify actual behavior
    assert inventory.get_quantity("SKU123") == 8
```

### Anti-Pattern 4: Incomplete Mocks

**Problem:** Creating partial mock responses that omit fields real systems contain.

**Example of bad mock:**
```python
# BAD: Incomplete mock response
mock_api.get_user.return_value = {"name": "Test"}

# Real API returns: {"id": 1, "name": "Test", "email": "test@example.com", "created_at": "..."}
```

**Fix:** Mirror the complete actual API structure in mocks.

```python
# GOOD: Complete mock response
mock_api.get_user.return_value = {
    "id": 1,
    "name": "Test",
    "email": "test@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
}
```

### Anti-Pattern 5: Integration Tests as Afterthought

**Problem:** Treating testing as optional follow-up work.

**Signs of this anti-pattern:**
- "We'll add tests later"
- "Ship now, test later"
- "Tests are nice to have"
- Integration tests written weeks after code

**Fix:** TDD prevents this by requiring tests before implementation.

## Prevention Through TDD

Writing tests first:
- Forces clarity about what's actually being tested
- Prevents test-only code creep
- Ensures minimal, targeted mocking
- Makes incomplete mocks immediately visible

## Red Flags

Stop and reconsider the testing approach when:

| Red Flag | Indicates |
|----------|-----------|
| Mock setup exceeds 50% of test logic | Over-mocking |
| Tests fail when mocks are removed | Testing mocks, not code |
| Mocking "just to be safe" | Misunderstanding mock purpose |
| Cannot explain why specific mocks exist | Cargo-cult mocking |
| Production code has `_for_testing` methods | Test pollution |
| Tests pass but bugs ship | Tests verify wrong things |

## Mock vs Fake vs Stub

| Type | Purpose | When to Use |
|------|---------|-------------|
| Mock | Verify interactions | Rarely; prefer fakes |
| Fake | Working implementation | Database, API clients |
| Stub | Fixed return values | Simple dependencies |

## Testing Pyramid

```
         /\
        /  \  E2E Tests (few)
       /----\
      /      \  Integration Tests (some)
     /--------\
    /          \  Unit Tests (many)
   --------------
```

- **Unit tests**: Fast, isolated, numerous
- **Integration tests**: Test component interaction
- **E2E tests**: Test full user flows, slow

## Checklist for Healthy Tests

- [ ] Tests document behavior, not implementation
- [ ] Mock setup is minimal and understandable
- [ ] Each mock has a clear reason to exist
- [ ] No test-only code in production classes
- [ ] Tests fail for the right reasons
- [ ] Removing mocks reveals real issues, not test brittleness

## Summary

**Good tests:**
- Test real behavior
- Use fakes over mocks when possible
- Keep production code test-agnostic
- Mock only external dependencies

**Bad tests:**
- Test mock configuration
- Over-mock internal dependencies
- Add test methods to production code
- Exist as afterthought
