# Created Directory Junction Workaround

I have successfully created a Directory Junction (a virtual link) that allows the Flutter tool to access your project through a path without special characters, while keeping your files in their original location.

## Changes and Setup

### 1. Created Virtual Link (Junction)
I created a link at `D:\health_tracker_pro` that points directly to your original folder `D:\Lập trình thiết bị di động\health_tracker_pro`.

### 2. Restored `gradlew.bat`
I reverted the manual path changes in `gradlew.bat` because they are no longer needed when accessing the project through the new virtual link.

## How to Run Your Project Now

> [!IMPORTANT]
> To avoid the "Illegal character in path" crash, you must now open the project using the new path:
>
> 1.  In Android Studio, go to **File > Close Project**.
> 2.  On the welcome screen, click **Open**.
> 3.  Navigate to and select **`D:\health_tracker_pro`**.
> 4.  Once opened, you can run the app as usual:
>     - Open Terminal in Android Studio.
>     - Run `flutter clean`.
>     - Run `flutter run`.

Your physical files remain safely in `D:\Lập trình thiết bị di động\health_tracker_pro`. Any changes you make in Android Studio while using the new path will be automatically saved to your original folder.
