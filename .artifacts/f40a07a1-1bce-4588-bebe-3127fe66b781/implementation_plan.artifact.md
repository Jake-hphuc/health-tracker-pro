# Move Project to Clean Path and Create Legacy Link

This plan will physically move your project files to a path without special characters (`D:\health_tracker_pro`) and create a virtual link at your original location so you can still find it where it was.

## User Review Required

> [!CAUTION]
> **Files will be physically moved.**
> While I will create a link at the old location, the actual data will reside in `D:\health_tracker_pro`.
>
> **Important:** Please ensure Android Studio is closed before I begin the move to prevent file locking errors.

## Proposed Changes

### File System Operations

1.  **Move Directory:**
    Move `D:\Lập trình thiết bị di động\health_tracker_pro` to `D:\health_tracker_pro`.
2.  **Create Junction:**
    Create a Directory Junction at `D:\Lập trình thiết bị di động\health_tracker_pro` pointing to the new location `D:\health_tracker_pro`.

### Project Cleanup

1.  **Clean Build:**
    Run `flutter clean` in the new location to ensure all cached paths are reset.

## Verification Plan

### Manual Verification
1.  Verify that `D:\health_tracker_pro` contains all your project files.
2.  Verify that entering `D:\Lập trình thiết bị di động\health_tracker_pro` still shows your files (via the link).
3.  Open the project from **`D:\health_tracker_pro`** and run `flutter run`.
