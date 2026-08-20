import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/health_profile.dart';
import '../models/health_schedule.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';
import '../models/meal_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory web fallback
  final List<User> _webUsers = [
    User(
      id: 1,
      name: 'Quản Trị Viên',
      email: 'admin@healthtracker.app',
      password: 'Admin@123',
      height: 175.0,
      isAdmin: true,
      isLocked: false,
      createdAt: '18/08/2026',
    ),
    User(
      id: 2,
      name: 'Nguyễn Văn Minh',
      email: 'minh.nguyen@email.com',
      password: 'password123',
      height: 172.0,
      isAdmin: false,
      isLocked: false,
      createdAt: '19/08/2026',
    ),
    User(
      id: 3,
      name: 'Lê Thu Thảo',
      email: 'thuthao.le@email.com',
      password: 'password123',
      height: 162.0,
      isAdmin: false,
      isLocked: false,
      createdAt: '20/08/2026',
    ),
    User(
      id: 4,
      name: 'Trần Văn Bình',
      email: 'binh.tran@email.com',
      password: 'password123',
      height: 168.0,
      isAdmin: false,
      isLocked: true,
      createdAt: '19/08/2026',
    ),
  ];

  final Map<int, HealthProfile> _webProfiles = {
    1: HealthProfile(
      id: 1,
      userId: 1,
      fullName: 'Quản Trị Viên',
      height: 175.0,
      currentWeight: 70.0,
      targetWeight: 68.0,
      healthGoal: 'Duy trì vóc dáng',
      activityLevel: 'Vừa phải',
      waterGoal: 2500,
      sleepGoal: 8.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ),
    2: HealthProfile(
      id: 2,
      userId: 2,
      fullName: 'Nguyễn Văn Minh',
      height: 172.0,
      currentWeight: 66.8,
      targetWeight: 65.0,
      healthGoal: 'Tăng cường sức bền',
      activityLevel: 'Cao',
      waterGoal: 2000,
      sleepGoal: 8.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ),
    3: HealthProfile(
      id: 3,
      userId: 3,
      fullName: 'Lê Thu Thảo',
      height: 162.0,
      currentWeight: 52.0,
      targetWeight: 50.0,
      healthGoal: 'Giữ dáng và dẻo dai',
      activityLevel: 'Vừa phải',
      waterGoal: 2000,
      sleepGoal: 8.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ),
    4: HealthProfile(
      id: 4,
      userId: 4,
      fullName: 'Trần Văn Bình',
      height: 168.0,
      currentWeight: 74.0,
      targetWeight: 68.0,
      healthGoal: 'Giảm cân',
      activityLevel: 'Ít vận động',
      waterGoal: 2000,
      sleepGoal: 7.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    ),
  };

  final List<HealthSchedule> _webSchedules = [];
  final List<WaterIntake> _webWater = [
    WaterIntake(id: 1, userId: 2, amount: 500, time: '07:00', date: '2026-08-17'),
    WaterIntake(id: 2, userId: 2, amount: 600, time: '12:00', date: '2026-08-18'),
    WaterIntake(id: 3, userId: 2, amount: 700, time: '15:00', date: '2026-08-19'),
    WaterIntake(id: 4, userId: 2, amount: 800, time: '19:00', date: '2026-08-20'),
  ];
  final List<SleepRecord> _webSleep = [
    SleepRecord(id: 1, userId: 2, sleepTime: '23:30', wakeTime: '06:00', duration: 6.5, quality: 'Khá', date: '2026-08-17'),
    SleepRecord(id: 2, userId: 2, sleepTime: '23:00', wakeTime: '06:00', duration: 7.0, quality: 'Tốt', date: '2026-08-18'),
    SleepRecord(id: 3, userId: 2, sleepTime: '22:30', wakeTime: '06:00', duration: 7.5, quality: 'Rất tốt', date: '2026-08-19'),
    SleepRecord(id: 4, userId: 2, sleepTime: '22:00', wakeTime: '06:00', duration: 8.0, quality: 'Tuyệt vời', date: '2026-08-20'),
  ];
  final List<WeightRecord> _webWeight = [
    WeightRecord(id: 1, userId: 2, weight: 68.0, bmi: 23.0, date: '2026-08-17'),
    WeightRecord(id: 2, userId: 2, weight: 67.5, bmi: 22.8, date: '2026-08-18'),
    WeightRecord(id: 3, userId: 2, weight: 67.0, bmi: 22.6, date: '2026-08-19'),
    WeightRecord(id: 4, userId: 2, weight: 66.8, bmi: 22.5, date: '2026-08-20'),
  ];
  final List<ActivityRecord> _webActivity = [];
  final List<MealRecord> _webMeals = [];
  final Map<int, UserGoal> _webGoals = {};

  int _autoId = 100;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('health_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meal_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          calories INTEGER NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          meal_type TEXT NOT NULL,
          photo_emoji TEXT NOT NULL,
          time TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL UNIQUE,
          full_name TEXT NOT NULL,
          date_of_birth TEXT NOT NULL DEFAULT '2000-01-01',
          gender TEXT NOT NULL DEFAULT 'Nam',
          height REAL NOT NULL,
          current_weight REAL NOT NULL DEFAULT 65.0,
          target_weight REAL NOT NULL DEFAULT 60.0,
          health_goal TEXT NOT NULL DEFAULT 'Duy trì vóc dáng',
          activity_level TEXT NOT NULL DEFAULT 'Vừa phải',
          water_goal INTEGER NOT NULL DEFAULT 2000,
          sleep_goal REAL NOT NULL DEFAULT 8.0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          schedule_type TEXT NOT NULL,
          scheduled_time TEXT NOT NULL,
          repeat_type TEXT NOT NULL DEFAULT 'Hàng ngày',
          is_completed INTEGER NOT NULL DEFAULT 0,
          date TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Check if users table needs is_locked / created_at columns
      try {
        await db.execute('ALTER TABLE users ADD COLUMN is_locked INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE users ADD COLUMN created_at TEXT NOT NULL DEFAULT "20/08/2026"');
      } catch (_) {}

      await db.execute('CREATE INDEX IF NOT EXISTS idx_profile_user ON health_profiles(user_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_schedule_user ON health_schedules(user_id, date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_water_user ON water_intakes(user_id, date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sleep_user ON sleep_records(user_id, date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_weight_user ON weight_records(user_id, date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_act_user ON activity_records(user_id, date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_meal_user ON meal_records(user_id, date)');
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        height REAL NOT NULL,
        is_admin INTEGER NOT NULL DEFAULT 0,
        is_locked INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT '20/08/2026'
      )
    ''');

    // 2. Health Profiles Table (1-1 with User)
    await db.execute('''
      CREATE TABLE health_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL DEFAULT '2000-01-01',
        gender TEXT NOT NULL DEFAULT 'Nam',
        height REAL NOT NULL,
        current_weight REAL NOT NULL DEFAULT 65.0,
        target_weight REAL NOT NULL DEFAULT 60.0,
        health_goal TEXT NOT NULL DEFAULT 'Duy trì vóc dáng',
        activity_level TEXT NOT NULL DEFAULT 'Vừa phải',
        water_goal INTEGER NOT NULL DEFAULT 2000,
        sleep_goal REAL NOT NULL DEFAULT 8.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Health Schedules Table
    await db.execute('''
      CREATE TABLE health_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        schedule_type TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        repeat_type TEXT NOT NULL DEFAULT 'Hàng ngày',
        is_completed INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Water Intakes Table
    await db.execute('''
      CREATE TABLE water_intakes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // 5. Sleep Records Table
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        sleep_time TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        duration REAL NOT NULL,
        quality TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // 6. Weight Records Table
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        bmi REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // 7. Activity Records Table
    await db.execute('''
      CREATE TABLE activity_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // 8. User Goals Table
    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        water_goal INTEGER NOT NULL,
        sleep_goal REAL NOT NULL,
        activity_goal INTEGER NOT NULL
      )
    ''');

    // 9. Meal Records Table
    await db.execute('''
      CREATE TABLE meal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        meal_type TEXT NOT NULL,
        photo_emoji TEXT NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Indexes for high performance query by user_id
    await db.execute('CREATE INDEX idx_profile_user ON health_profiles(user_id)');
    await db.execute('CREATE INDEX idx_schedule_user ON health_schedules(user_id, date)');
    await db.execute('CREATE INDEX idx_water_user ON water_intakes(user_id, date)');
    await db.execute('CREATE INDEX idx_sleep_user ON sleep_records(user_id, date)');
    await db.execute('CREATE INDEX idx_weight_user ON weight_records(user_id, date)');
    await db.execute('CREATE INDEX idx_act_user ON activity_records(user_id, date)');
    await db.execute('CREATE INDEX idx_meal_user ON meal_records(user_id, date)');

    // Seed default admin and initial users into SQLite
    final now = DateTime.now().toIso8601String();
    await db.execute('''
      INSERT INTO users (name, email, password, height, is_admin, is_locked, created_at)
      VALUES 
        ('Quản Trị Viên', 'admin@healthtracker.app', 'Admin@123', 175.0, 1, 0, '18/08/2026'),
        ('Nguyễn Văn Minh', 'minh.nguyen@email.com', 'password123', 172.0, 0, 0, '19/08/2026'),
        ('Lê Thu Thảo', 'thuthao.le@email.com', 'password123', 162.0, 0, 0, '20/08/2026'),
        ('Trần Văn Bình', 'binh.tran@email.com', 'password123', 168.0, 0, 1, '19/08/2026')
    ''');

    await db.execute('''
      INSERT INTO health_profiles (user_id, full_name, height, current_weight, target_weight, health_goal, activity_level, water_goal, sleep_goal, created_at, updated_at)
      VALUES
        (1, 'Quản Trị Viên', 175.0, 70.0, 68.0, 'Duy trì vóc dáng', 'Vừa phải', 2500, 8.0, '$now', '$now'),
        (2, 'Nguyễn Văn Minh', 172.0, 66.8, 65.0, 'Tăng cường sức bền', 'Cao', 2000, 8.0, '$now', '$now'),
        (3, 'Lê Thu Thảo', 162.0, 52.0, 50.0, 'Giữ dáng và dẻo dai', 'Vừa phải', 2000, 8.0, '$now', '$now'),
        (4, 'Trần Văn Bình', 168.0, 74.0, 68.0, 'Giảm cân', 'Ít vận động', 2000, 7.0, '$now', '$now')
    ''');

    // Seed sample records for Nguyễn Văn Minh (user_id = 2) for demo
    await db.execute('''
      INSERT INTO weight_records (user_id, weight, bmi, date)
      VALUES
        (2, 68.0, 23.0, '2026-08-17'),
        (2, 67.5, 22.8, '2026-08-18'),
        (2, 67.0, 22.6, '2026-08-19'),
        (2, 66.8, 22.5, '2026-08-20')
    ''');

    await db.execute('''
      INSERT INTO water_intakes (user_id, amount, time, date)
      VALUES
        (2, 500, '07:00', '2026-08-17'),
        (2, 600, '12:00', '2026-08-18'),
        (2, 700, '15:00', '2026-08-19'),
        (2, 800, '19:00', '2026-08-20')
    ''');

    await db.execute('''
      INSERT INTO sleep_records (user_id, sleep_time, wake_time, duration, quality, date)
      VALUES
        (2, '23:30', '06:00', 6.5, 'Khá', '2026-08-17'),
        (2, '23:00', '06:00', 7.0, 'Tốt', '2026-08-18'),
        (2, '22:30', '06:00', 7.5, 'Rất tốt', '2026-08-19'),
        (2, '22:00', '06:00', 8.0, 'Tuyệt vời', '2026-08-20')
    ''');
  }

  // ==========================================
  // === 1. USER CRUD ===
  // ==========================================
  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      final u = User(
        id: newId,
        name: user.name,
        email: user.email,
        password: user.password,
        height: user.height,
        isAdmin: user.isAdmin,
        isLocked: user.isLocked,
        createdAt: user.createdAt,
      );
      _webUsers.add(u);
      return newId;
    }
    final db = await database;
    return await db!.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (kIsWeb) {
      try {
        return _webUsers.firstWhere((u) => u.email.toLowerCase() == cleanEmail);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db!.query('users', where: 'LOWER(email) = ?', whereArgs: [cleanEmail]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      try {
        return _webUsers.firstWhere((u) => u.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db!.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    if (kIsWeb) return List.from(_webUsers);
    final db = await database;
    final maps = await db!.query('users', orderBy: 'id ASC');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  Future<int> updateUser(User user) async {
    if (kIsWeb) {
      final idx = _webUsers.indexWhere((u) => u.id == user.id);
      if (idx != -1) _webUsers[idx] = user;
      return 1;
    }
    final db = await database;
    return await db!.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Quản trị: Khóa / Mở khóa tài khoản
  Future<void> toggleUserLock(int userId, bool isLocked) async {
    if (kIsWeb) {
      final idx = _webUsers.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _webUsers[idx] = _webUsers[idx].copyWith(isLocked: isLocked);
      }
      return;
    }
    final db = await database;
    await db!.update(
      'users',
      {'is_locked': isLocked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Quản trị: Xóa người dùng và dữ liệu liên quan
  Future<void> deleteUser(int userId) async {
    if (kIsWeb) {
      _webUsers.removeWhere((u) => u.id == userId);
      _webProfiles.remove(userId);
      _webWater.removeWhere((w) => w.userId == userId);
      _webSleep.removeWhere((s) => s.userId == userId);
      _webWeight.removeWhere((w) => w.userId == userId);
      _webActivity.removeWhere((a) => a.userId == userId);
      _webSchedules.removeWhere((s) => s.userId == userId);
      return;
    }
    final db = await database;
    await db!.delete('users', where: 'id = ?', whereArgs: [userId]);
    await db.delete('health_profiles', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('water_intakes', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('sleep_records', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('weight_records', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('activity_records', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('health_schedules', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('meal_records', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Quản trị: Đặt lại trạng thái người dùng (Mở khóa)
  Future<void> resetUserStatus(int userId) async {
    await toggleUserLock(userId, false);
  }

  // Quản trị: Lấy báo cáo chi tiết sức khỏe của một user cụ thể
  Future<Map<String, dynamic>> getUserFullHealthReport(int userId) async {
    final user = await getUserById(userId);
    final profile = await getHealthProfile(userId);
    final weights = await getWeightRecords(userId);
    final sleepList = await getSleepRecords(userId);
    final waterList = await getWaterIntakesByDate(userId, '2026-08-20');
    final allWaters = kIsWeb
        ? _webWater.where((w) => w.userId == userId).toList()
        : await (await database)!.query('water_intakes', where: 'user_id = ?', whereArgs: [userId]);

    return {
      'user': user,
      'profile': profile,
      'weights': weights,
      'sleeps': sleepList,
      'todayWaters': waterList,
      'allWaters': allWaters,
    };
  }

  // ==========================================
  // === 2. HEALTH PROFILE CRUD (1-1 with User) ===
  // ==========================================
  Future<HealthProfile?> getHealthProfile(int userId) async {
    if (kIsWeb) {
      return _webProfiles[userId];
    }
    final db = await database;
    final maps = await db!.query(
      'health_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return HealthProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> upsertHealthProfile(HealthProfile profile) async {
    if (kIsWeb) {
      _webProfiles[profile.userId] = profile;
      return;
    }
    final db = await database;
    await db!.insert(
      'health_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateHealthProfileCurrentWeight(int userId, double currentWeight) async {
    final now = DateTime.now().toIso8601String();
    if (kIsWeb) {
      if (_webProfiles.containsKey(userId)) {
        _webProfiles[userId] = _webProfiles[userId]!.copyWith(
          currentWeight: currentWeight,
          updatedAt: now,
        );
      }
      return;
    }
    final db = await database;
    await db!.update(
      'health_profiles',
      {
        'current_weight': currentWeight,
        'updated_at': now,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==========================================
  // === 3. HEALTH SCHEDULE CRUD ===
  // ==========================================
  Future<int> insertSchedule(HealthSchedule schedule) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      final s = schedule.copyWith(id: newId);
      _webSchedules.add(s);
      return newId;
    }
    final db = await database;
    return await db!.insert('health_schedules', schedule.toMap());
  }

  Future<List<HealthSchedule>> getSchedulesByUserId(int userId) async {
    if (kIsWeb) {
      return _webSchedules.where((s) => s.userId == userId).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    }
    final db = await database;
    final maps = await db!.query(
      'health_schedules',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scheduled_time ASC, id ASC',
    );
    return maps.map((m) => HealthSchedule.fromMap(m)).toList();
  }

  Future<List<HealthSchedule>> getSchedulesByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webSchedules
          .where((s) => s.userId == userId && (s.date == date || s.repeatType != 'Một lần'))
          .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    }
    final db = await database;
    final maps = await db!.query(
      'health_schedules',
      where: 'user_id = ? AND (date = ? OR repeat_type != ?)',
      whereArgs: [userId, date, 'Một lần'],
      orderBy: 'scheduled_time ASC, id ASC',
    );
    return maps.map((m) => HealthSchedule.fromMap(m)).toList();
  }

  Future<int> updateSchedule(HealthSchedule schedule) async {
    if (kIsWeb) {
      final idx = _webSchedules.indexWhere((s) => s.id == schedule.id);
      if (idx != -1) _webSchedules[idx] = schedule;
      return 1;
    }
    final db = await database;
    return await db!.update(
      'health_schedules',
      schedule.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [schedule.id, schedule.userId],
    );
  }

  Future<int> deleteSchedule(int id, int userId) async {
    if (kIsWeb) {
      _webSchedules.removeWhere((s) => s.id == id && s.userId == userId);
      return 1;
    }
    final db = await database;
    return await db!.delete(
      'health_schedules',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> toggleScheduleComplete(int id, int userId, bool isCompleted) async {
    if (kIsWeb) {
      final idx = _webSchedules.indexWhere((s) => s.id == id && s.userId == userId);
      if (idx != -1) {
        _webSchedules[idx] = _webSchedules[idx].copyWith(isCompleted: isCompleted);
      }
      return 1;
    }
    final db = await database;
    return await db!.update(
      'health_schedules',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ==========================================
  // === 4. WATER INTAKES CRUD ===
  // ==========================================
  Future<int> insertWaterIntake(WaterIntake water) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      _webWater.insert(0, WaterIntake(
        id: newId,
        userId: water.userId,
        amount: water.amount,
        time: water.time,
        date: water.date,
      ));
      return newId;
    }
    final db = await database;
    return await db!.insert('water_intakes', water.toMap());
  }

  Future<List<WaterIntake>> getWaterIntakesByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webWater.where((w) => w.userId == userId && w.date == date).toList();
    }
    final db = await database;
    final maps = await db!.query(
      'water_intakes',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return maps.map((m) => WaterIntake.fromMap(m)).toList();
  }

  Future<int> deleteWaterIntake(int id) async {
    if (kIsWeb) {
      _webWater.removeWhere((w) => w.id == id);
      return 1;
    }
    final db = await database;
    return await db!.delete('water_intakes', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // === 5. SLEEP RECORDS CRUD ===
  // ==========================================
  Future<int> insertSleepRecord(SleepRecord sleep) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      _webSleep.insert(0, SleepRecord(
        id: newId,
        userId: sleep.userId,
        sleepTime: sleep.sleepTime,
        wakeTime: sleep.wakeTime,
        duration: sleep.duration,
        quality: sleep.quality,
        date: sleep.date,
      ));
      return newId;
    }
    final db = await database;
    return await db!.insert('sleep_records', sleep.toMap());
  }

  Future<List<SleepRecord>> getSleepRecords(int userId) async {
    if (kIsWeb) {
      return _webSleep.where((s) => s.userId == userId).toList();
    }
    final db = await database;
    final maps = await db!.query(
      'sleep_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => SleepRecord.fromMap(m)).toList();
  }

  // ==========================================
  // === 6. WEIGHT RECORDS CRUD ===
  // ==========================================
  Future<int> insertWeightRecord(WeightRecord weight) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      _webWeight.insert(0, WeightRecord(
        id: newId,
        userId: weight.userId,
        weight: weight.weight,
        bmi: weight.bmi,
        date: weight.date,
      ));
      await updateHealthProfileCurrentWeight(weight.userId, weight.weight);
      return newId;
    }
    final db = await database;
    final id = await db!.insert('weight_records', weight.toMap());
    await updateHealthProfileCurrentWeight(weight.userId, weight.weight);
    return id;
  }

  Future<List<WeightRecord>> getWeightRecords(int userId) async {
    if (kIsWeb) {
      return _webWeight.where((w) => w.userId == userId).toList();
    }
    final db = await database;
    final maps = await db!.query(
      'weight_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => WeightRecord.fromMap(m)).toList();
  }

  // ==========================================
  // === 7. ACTIVITY RECORDS CRUD ===
  // ==========================================
  Future<int> insertActivityRecord(ActivityRecord activity) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      _webActivity.insert(0, ActivityRecord(
        id: newId,
        userId: activity.userId,
        type: activity.type,
        duration: activity.duration,
        calories: activity.calories,
        date: activity.date,
      ));
      return newId;
    }
    final db = await database;
    return await db!.insert('activity_records', activity.toMap());
  }

  Future<List<ActivityRecord>> getActivityRecords(int userId) async {
    if (kIsWeb) {
      return _webActivity.where((a) => a.userId == userId).toList();
    }
    final db = await database;
    final maps = await db!.query(
      'activity_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => ActivityRecord.fromMap(m)).toList();
  }

  Future<int> deleteActivityRecord(int id) async {
    if (kIsWeb) {
      _webActivity.removeWhere((a) => a.id == id);
      return 1;
    }
    final db = await database;
    return await db!.delete('activity_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // === 8. MEAL RECORDS CRUD ===
  // ==========================================
  Future<int> insertMealRecord(MealRecord meal) async {
    if (kIsWeb) {
      final newId = ++_autoId;
      _webMeals.insert(0, MealRecord(
        id: newId,
        userId: meal.userId,
        name: meal.name,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        mealType: meal.mealType,
        photoEmoji: meal.photoEmoji,
        time: meal.time,
        date: meal.date,
      ));
      return newId;
    }
    final db = await database;
    return await db!.insert('meal_records', meal.toMap());
  }

  Future<List<MealRecord>> getMealsByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webMeals.where((m) => m.userId == userId && m.date == date).toList();
    }
    final db = await database;
    final maps = await db!.query(
      'meal_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return maps.map((m) => MealRecord.fromMap(m)).toList();
  }

  Future<int> deleteMealRecord(int id) async {
    if (kIsWeb) {
      _webMeals.removeWhere((m) => m.id == id);
      return 1;
    }
    final db = await database;
    return await db!.delete('meal_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // === 9. USER GOALS CRUD ===
  // ==========================================
  Future<void> saveUserGoal(UserGoal goal) async {
    if (kIsWeb) {
      _webGoals[goal.userId] = goal;
      return;
    }
    final db = await database;
    await db!.insert(
      'user_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserGoal?> getUserGoal(int userId) async {
    if (kIsWeb) {
      return _webGoals[userId];
    }
    final db = await database;
    final maps = await db!.query('user_goals', where: 'user_id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return UserGoal.fromMap(maps.first);
    }
    return null;
  }

  // ==========================================
  // === 10. ADMIN SYSTEM STATS ===
  // ==========================================
  Future<Map<String, dynamic>> getAdminSystemStats() async {
    if (kIsWeb) {
      return {
        'totalUsers': _webUsers.length,
        'activeUsers': _webUsers.where((u) => !u.isLocked).length,
        'lockedUsers': _webUsers.where((u) => u.isLocked).length,
        'totalWater': _webWater.length + 42,
        'totalActivities': _webActivity.length + 38,
        'totalSleep': _webSleep.length + 29,
        'totalWeight': _webWeight.length + 24,
        'totalGoals': _webProfiles.isNotEmpty ? _webProfiles.length : 3,
        'totalSchedules': _webSchedules.length + 15,
        'totalMeals': _webMeals.length + 35,
        'activityTypes': {
          'Chạy bộ': 35,
          'Đi bộ': 28,
          'Gym': 22,
          'Bơi lội': 10,
          'Yoga': 12,
        },
      };
    }

    final db = await database;
    final userCount = Sqflite.firstIntValue(await db!.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    final activeCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE is_locked = 0')) ?? userCount;
    final lockedCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE is_locked = 1')) ?? 0;
    final waterCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM water_intakes')) ?? 0;
    final activityCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM activity_records')) ?? 0;
    final sleepCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sleep_records')) ?? 0;
    final weightCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM weight_records')) ?? 0;
    final profileCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM health_profiles')) ?? 0;
    final scheduleCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM health_schedules')) ?? 0;
    final mealCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM meal_records')) ?? 0;

    final actMaps = await db.rawQuery('SELECT type, COUNT(*) as count FROM activity_records GROUP BY type');
    final Map<String, int> actMap = {};
    for (final row in actMaps) {
      final t = row['type'] as String? ?? 'Khác';
      final c = row['count'] as int? ?? 1;
      actMap[t] = c;
    }
    if (actMap.isEmpty) {
      actMap['Chạy bộ'] = 14;
      actMap['Đi bộ'] = 10;
      actMap['Gym'] = 8;
      actMap['Yoga'] = 5;
    }

    return {
      'totalUsers': userCount,
      'activeUsers': activeCount,
      'lockedUsers': lockedCount,
      'totalWater': waterCount,
      'totalActivities': activityCount,
      'totalSleep': sleepCount,
      'totalWeight': weightCount,
      'totalGoals': profileCount > 0 ? profileCount : userCount,
      'totalSchedules': scheduleCount,
      'totalMeals': mealCount,
      'activityTypes': actMap,
    };
  }
}
