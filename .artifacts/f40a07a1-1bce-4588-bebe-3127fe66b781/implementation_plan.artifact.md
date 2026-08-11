# Workaround for Unicode Path Crash (Keeping Original Folder)

The crash `Illegal character in path` is a known bug in Flutter's build tool when handling Windows paths with Vietnamese accents. Since you want to keep the physical folder location as it is, we will use a **Directory Junction**.

A Junction is a "virtual link" that creates a second path to the same folder. The physical files stay in `D:\Lập trình thiết bị di động\health_tracker_pro`, but we will access them through a "clean" path like `D:\health_tracker_pro`.

## User Review Required

> [!IMPORTANT]
> **This solution does NOT move your files.** It only creates an "alias" for the folder that the Flutter tools can understand.
>
> I will create a link at `D:\health_tracker_pro`.
> You will then need to **Open the project from D:\health_tracker_pro** in Android Studio.

## Proposed Changes

### Environment Setup

#### [NEW] Directory Junction
I will run a command to link your folder to a clean path:
`cmd /c mklink /J D:\health_tracker_pro "D:\Lập trình thiết bị di động\health_tracker_pro"`

### Project Configuration

#### [MODIFY] `gradlew.bat` (file:///D:/Lập trình thiết bị di động/health_tracker_pro/android/gradlew.bat)
I will revert the manual classpath workaround I added earlier, as it won't be needed once we use the clean path.

## Verification Plan

### Manual Verification
1.  I will create the junction.
2.  **You** must then:
    - Close the current project in Android Studio.
    - Choose **Open** and select `D:\health_tracker_pro`.
    - Run `flutter run`.
