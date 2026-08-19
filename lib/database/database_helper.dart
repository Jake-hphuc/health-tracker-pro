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
    ),
    User(
      id: 2,
      name: 'Nguyễn Văn Minh',
      email: 'minh.nguyen@email.com',
      password: 'password123',
      height: 172.0,
      isAdmin: false,
    ),
    User(
      id: 3,
      name: 'Lê Thu Thảo',
      email: 'thuthao.le@email.com',
      password: 'password123',
      height: 162.0,
      isAdmin: false,
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
      currentWeight: 68.0,
      targetWeight: 65.0,
      healthGoal: 'Tăng cường sức bền',
      activityLevel: 'Cao',
      waterGoal: 2000,
      sleepGoal: 7.5,
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
  };

  final List<HealthSchedule> _webSchedules = [];
  final List<WaterIntake> _webWater = [];
  final List<SleepRecord> _webSleep = [];
  final List<WeightRecord> _webWeight = [];
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
      // Create meal_records if not exist
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

      // Create health_profiles if not exist
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

      // Create health_schedules if not exist
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

      // Add indexes
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
        is_admin INTEGER NOT NULL DEFAULT 0
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
      INSERT INTO users (name, email, password, height, is_admin)
      VALUES 
        ('Quản Trị Viên', 'admin@healthtracker.app', 'Admin@123', 175.0, 1),
        ('Nguyễn Văn Minh', 'minh.nguyen@email.com', 'password123', 172.0, 0),
        ('Lê Thu Thảo', 'thuthao.le@email.com', 'password123', 162.0, 0)
    ''');

    await db.execute('''
      INSERT INTO health_profiles (user_id, full_name, height, current_weight, target_weight, health_goal, activity_level, water_goal, sleep_goal, created_at, updated_at)
      VALUES
        (1, 'Quản Trị Viên', 175.0, 70.0, 68.0, 'Duy trì vóc dáng', 'Vừa phải', 2500, 8.0, '$now', '$now'),
        (2, 'Nguyễn Văn Minh', 172.0, 68.0, 65.0, 'Tăng cường sức bền', 'Cao', 2000, 7.5, '$now', '$now'),
        (3, 'Lê Thu Thảo', 162.0, 52.0, 50.0, 'Giữ dáng và dẻo dai', 'Vừa phải', 2000, 8.0, '$now', '$now')
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
}
