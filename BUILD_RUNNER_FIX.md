# Build Runner Post-Processing Fix

## Issue

When running `flutter pub run build_runner build`, the generated `lib/core/network/api_client.g.dart` file contains incorrect error logger calls due to a version mismatch between `retrofit_generator` and `dio`.

## Error

```
lib/core/network/api_client.g.dart:53:28: Error: Too few positional arguments: 4 required, 3 given.
      errorLogger?.logError(e, s, _options);
                           ^
lib/core/network/api_client.g.dart:86:28: Error: Too few positional arguments: 4 required, 3 given.
      errorLogger?.logError(e, s, _options);
                           ^
```

## Manual Fix (Required After Each build_runner Run)

Edit `lib/core/network/api_client.g.dart` and update TWO lines:

**Line 53:**
```dart
// Before
errorLogger?.logError(e, s, _options);

// After
errorLogger?.logError(e, s, _options, _result);
```

**Line 86:**
```dart
// Before
errorLogger?.logError(e, s, _options);

// After
errorLogger?.logError(e, s, _options, _result);
```

## Automated Fix Script

Create a file `fix_api_client.sh` (or `.bat` for Windows):

```bash
#!/bin/bash
# Fix api_client.g.dart after build_runner

FILE="lib/core/network/api_client.g.dart"

# Replace the incorrect error logger calls
sed -i 's/errorLogger?.logError(e, s, _options);/errorLogger?.logError(e, s, _options, _result);/g' "$FILE"

echo "Fixed $FILE"
```

**Usage:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
./fix_api_client.sh
```

## Permanent Solutions

### Option 1: Update Dependencies (Recommended)
```yaml
# In pubspec.yaml
dev_dependencies:
  analyzer: ^9.0.0  # Update analyzer to match SDK
```

Then run:
```bash
flutter packages upgrade
```

### Option 2: Remove Custom Error Logger

If the error logger isn't critical, remove it from `lib/core/network/api_client.dart`:

```dart
// Remove this class
class _CustomErrorLogger implements ParseErrorLogger {
  @override
  void logError(Object error, StackTrace stackTrace, RequestOptions options,
      [Response? response]) {
    print('API Error: $error');
  }
}

// And update the factory
factory ApiClient(DioClient dioClient) => _ApiClient(
  dioClient.dio,
  // errorLogger: _CustomErrorLogger(),  // Remove this line
);
```

### Option 3: Create Build Runner Hook

Create `build.yaml` in the project root:

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true

post_process_builders:
  fix_api_client:
    import: "tool/fix_api_client.dart"
    builder_factories: ["fixApiClient"]
```

## Current Status

✅ **Manual fix applied** - App compiles successfully
⚠️ **Requires manual fix after each build_runner run**
📝 **Documented for team awareness**

## Notes

- This is a known issue with retrofit_generator 8.x and dio 5.x
- The OAuth2 integration doesn't use the legacy ApiClient (it uses Dio directly)
- The ApiClient is only used for legacy/test endpoints (users, posts, etc.)
- Consider migrating away from Retrofit in future iterations
