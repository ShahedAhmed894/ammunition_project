# Fix for "dependOnInheritedWidgetOfExactType" Error

## Problem
The app was crashing with:
```
dependOnInheritedWidgetOfExactType<_LocalizationsScope>() or dependOnInheritedElement() was called before _SignInScreenState.initState() completed.
```

## Root Cause
In `lib/auth/login_page.dart`, the `initState()` method was calling `_showErrorDialog()` directly within the try-catch block. However, `_showErrorDialog()` calls `showDialog()`, which needs to access inherited widgets from the widget tree. 

The problem is that `initState()` hasn't fully completed yet when we try to access these inherited widgets, causing the error.

## Solution
Use `WidgetsBinding.instance.addPostFrameCallback()` to defer the dialog call until after the entire frame has been rendered and `initState()` is completely done.

### Before ❌
```dart
@override
void initState() {
  super.initState();
  try {
    _auth = FirebaseAuth.instance;
    print('✅ FirebaseAuth instance obtained in SignInScreen');
  } catch (e) {
    print('❌ Error getting FirebaseAuth instance: $e');
    _showErrorDialog('Firebase not initialized. Please restart the app.');  // ❌ Too early!
  }
}
```

### After ✅
```dart
@override
void initState() {
  super.initState();
  try {
    _auth = FirebaseAuth.instance;
    print('✅ FirebaseAuth instance obtained in SignInScreen');
  } catch (e) {
    print('❌ Error getting FirebaseAuth instance: $e');
    // Defer dialog to after frame is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {  // ✅ Deferred!
      _showErrorDialog('Firebase not initialized. Please restart the app.');
    });
  }
}
```

## Why This Works
1. `initState()` completes immediately
2. Flutter finishes rendering the current frame
3. THEN the callback is executed
4. By this time, all inherited widgets are available
5. `showDialog()` can safely access them

## File Modified
- **File:** `lib/auth/login_page.dart`
- **Lines:** 18-33
- **Change:** Wrapped error dialog call in `addPostFrameCallback()`

## Testing
```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

## Expected Behavior
- ✅ No "dependOnInheritedWidgetOfExactType" error
- ✅ App builds and runs
- ✅ Splash screen displays
- ✅ Navigates to Sign-In screen
- ✅ If Firebase error occurs, dialog shows safely

## Status: ✅ FIXED
The widget initialization order issue has been resolved by deferring the error dialog to after the frame completes.
