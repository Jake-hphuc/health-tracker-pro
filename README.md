# 🏃‍♂️ Health Tracker Pro

**Smart Health Monitoring Application** - Ứng dụng theo dõi sức khỏe thông minh

Ứng dụng di động giúp người dùng theo dõi và quản lý sức khỏe toàn diện với giao diện hiện đại, lấy cảm hứng từ Apple Health Design Language.

---

## ✨ Tính Năng Chính

### 📊 Theo Dõi Sức Khỏe
- **💧 Nước uống**: Ghi nhận lượng nước uống hàng ngày với biểu đồ theo dõi tuần
- **😴 Giấc ngủ**: Phân tích chất lượng và thời gian ngủ
- **⚖️ Cân nặng & BMI**: Theo dõi cân nặng, tính toán và phân loại chỉ số BMI
- **🏃 Hoạt động thể thao**: Ghi nhận 13+ loại hoạt động (chạy bộ, gym, yoga, bơi lội...)
- **🥗 Dinh dưỡng**: Scanner bữa ăn, tính toán calories, protein, carbs, fat

### 🎮 Gamification
- **🏆 Thử thách hàng ngày**: Hoàn thành mục tiêu để nhận điểm thưởng
- **🎁 Cửa hàng voucher**: Đổi điểm lấy voucher giảm giá từ các thương hiệu (California Fitness, SaladStop, Elite Spa...)
- **⭐ KOL Plans**: Các chương trình tập luyện từ VĐV nổi tiếng

### 📈 Phân Tích & Thống Kê
- Biểu đồ theo dõi tiến độ theo tuần
- Activity Rings (giống Apple Watch)
- Thống kê chi tiết cho từng chỉ số sức khỏe

### 💡 Hỗ Trợ & Hướng Dẫn
- Mẹo sức khỏe (Health Tips)
- Hướng dẫn tập luyện
- Tư vấn dinh dưỡng

### 👨‍💼 Quản Trị
- Admin Dashboard để quản lý người dùng
- Phân quyền admin/user

---

## 🎨 Giao Diện

- **Design Language**: Apple Health & Fitness inspired
- **Color Scheme**: 
  - 🔴 Activity Red (#FF375F)
  - 🟢 Exercise Green (#32D74B)
  - 🔵 Hydration Blue (#0A84FF)
  - 🟣 Sleep Purple (#BF5AF2)
  - 🟠 Weight Orange (#FF9F0A)
- **Dark/Light Mode**: Hỗ trợ cả 2 chế độ
- **Responsive**: Tối ưu cho cả mobile và tablet (side rail navigation)
- **Typography**: Google Fonts - Be Vietnam Pro

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter**: ^3.8.1
- **Dart**: ^3.8.1

### State Management
- **Provider**: ^6.1.2

### Database
- **SQLite** (sqflite): ^2.4.2
- 7 tables: users, water_intakes, sleep_records, weight_records, activity_records, user_goals, meal_records

### UI Libraries
- **fl_chart**: ^0.70.2 - Biểu đồ
- **google_fonts**: ^6.2.1 - Typography
- **cupertino_icons**: ^1.0.8

### Utilities
- **shared_preferences**: ^2.5.3 - Local storage
- **crypto**: ^3.0.6 - Password hashing (SHA-256)
- **intl**: ^0.20.2 - Date/time formatting, localization
- **flutter_local_notifications**: ^18.0.1 - Notifications

---

## 🚀 Cài Đặt & Chạy Ứng Dụng

### Yêu Cầu Hệ Thống
- Flutter SDK: >=3.8.1
- Dart SDK: >=3.8.1
- Android Studio / VS Code
- Android Emulator hoặc iOS Simulator

### Các Bước Cài Đặt

1. **Clone repository**
```bash
git clone [repository-url]
cd health_tracker_pro
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Chạy ứng dụng**
```bash
flutter run
```

Hoặc chạy trên emulator cụ thể:
```bash
flutter run -d emulator-5554    # Android
flutter run -d iPhone-14        # iOS
```

---

## 🔐 Tài Khoản Demo

### Admin Account
- **Email**: `admin@healthtracker.app`
- **Password**: `Admin@123`

### User Accounts
- **Email**: `minh.nguyen@email.com`
- **Password**: `Password123`

- **Email**: `thuthao.le@email.com`
- **Password**: `Password123`

### Guest Mode
- Có thể sử dụng chế độ "Khách" để trải nghiệm mà không cần đăng ký

---

## 📱 Các Màn Hình Chính

1. **Splash Screen** - Màn hình khởi động
2. **Onboarding** - Giới thiệu app
3. **Login/Register** - Đăng nhập/Đăng ký
4. **Home Dashboard** - Tổng quan sức khỏe
5. **Water Tracking** - Theo dõi nước uống
6. **Sleep Tracking** - Theo dõi giấc ngủ
7. **Weight Management** - Quản lý cân nặng
8. **Activity Recording** - Ghi nhận hoạt động
9. **Meal Scanner** - Scanner bữa ăn
10. **Challenges** - Thử thách & điểm thưởng
11. **Rewards Store** - Cửa hàng voucher
12. **KOL Plans** - Chương trình VĐV
13. **Health Tips** - Mẹo sức khỏe
14. **Statistics** - Thống kê chi tiết
15. **Settings** - Cài đặt
16. **Admin Dashboard** - Quản trị (chỉ admin)

---

## 🔒 Bảo Mật

- **Password Hashing**: Tất cả mật khẩu được hash bằng SHA-256 trước khi lưu vào database
- **Input Validation**: Validate tất cả inputs từ người dùng
- **Error Handling**: Xử lý lỗi toàn diện với thông báo thân thiện

---

## 📊 Cấu Trúc Database

### Users Table
- id, name, email, password (hashed), height, is_admin

### Water Intakes Table
- id, user_id, amount, time, date

### Sleep Records Table
- id, user_id, sleep_time, wake_time, duration, quality, date

### Weight Records Table
- id, user_id, weight, bmi, date

### Activity Records Table
- id, user_id, type, duration, calories, date

### User Goals Table
- id, user_id, water_goal, sleep_goal, activity_goal

### Meal Records Table
- id, user_id, name, calories, protein, carbs, fat, meal_type, photo_emoji, time, date

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                   # Entry point
├── database/
│   └── database_helper.dart    # SQLite operations
├── models/                     # Data models
│   ├── user.dart
│   ├── water_intake.dart
│   ├── sleep_record.dart
│   ├── weight_record.dart
│   ├── activity_record.dart
│   ├── meal_record.dart
│   ├── user_goal.dart
│   ├── challenge.dart
│   ├── reward_voucher.dart
│   ├── athlete_plan.dart
│   └── health_tip.dart
├── providers/                  # State management
│   ├── auth_provider.dart
│   ├── health_provider.dart
│   ├── challenge_provider.dart
│   └── theme_provider.dart
├── screens/                    # UI screens (19 screens)
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── ...
├── widgets/                    # Reusable widgets
│   ├── activity_ring.dart
│   ├── metric_card.dart
│   └── bottom_nav.dart
└── utils/                      # Utilities & helpers
    ├── constants.dart
    ├── bmi_calculator.dart
    ├── security_helper.dart    # Password hashing
    └── validators.dart         # Input validation
```

---

## 🎯 Các Tính Năng Nổi Bật

### 1. Password Security
- Sử dụng SHA-256 để hash password
- Không lưu plain text password
- Verify password khi login

### 2. Input Validation
- Email format validation
- Password strength check (min 6 chars, 1 uppercase, 1 number)
- Height/weight range validation
- User-friendly error messages

### 3. Responsive Design
- Mobile-first design
- Tablet support với side rail navigation
- Adaptive layouts

### 4. Data Visualization
- Line charts cho xu hướng tuần
- Activity rings như Apple Watch
- Progress bars & indicators

---

## 👨‍💻 Phát Triển & Đóng Góp

### Run Tests
```bash
flutter test
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

---

## 📝 Ghi Chú

- **Mục đích**: Đồ án môn Lập Trình Thiết Bị Di Động
- **Platform**: Android & iOS
- **License**: MIT
- **Version**: 1.0.0+1

---

## 📞 Liên Hệ

- **Developer**: [Tên của bạn]
- **Email**: [Email của bạn]
- **GitHub**: [GitHub profile]

---

## 🙏 Cảm Ơn

Cảm ơn giảng viên và các bạn đã quan tâm đến dự án!

---

**Made with ❤️ using Flutter**
