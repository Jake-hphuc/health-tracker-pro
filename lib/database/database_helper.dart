import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';
import '../models/meal_record.dart';

/// Database helper class for managing SQLite database operations.
/// 
/// Implements singleton pattern to ensure single database instance.
/// Handles all CRUD operations for:
/// - Users (authentication and profile)
/// - Water intake tracking
/// - Sleep records
/// - Weight records
/// - Activity records
/// - User goals
/// - Meal records
/// 
/// On web platform, uses in-memory data storage as fallback.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory web fallback
  final List<User> _webUsers = [
    User(
      id: 1,
      name: 'Quản Trị Viên (Admin)',
      email: 'admin@healthtracker.app',
      password: 'admin',
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
    }
  }

  Future _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE water_intakes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        bmi REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        water_goal INTEGER NOT NULL,
        sleep_goal REAL NOT NULL,
        activity_goal INTEGER NOT NULL
      )
    ''');

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
  }

  // === User CRUD ===
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
    if (kIsWeb) {
      try {
        return _webUsers.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final maps = await db!.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    if (kIsWeb) {
      return List.from(_webUsers);
    }
    final db = await database;
    final maps = await db!.query('users');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  // === Water Intake ===
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

  // === Sleep ===
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

  // === Weight ===
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
      return newId;
    }
    final db = await database;
    return await db!.insert('weight_records', weight.toMap());
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

  // === Activity ===
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

  // === Meal Records ===
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
        mealType: mealTypeToString(meal.mealType),
        photoEmoji: meal.photoEmoji,
        time: meal.time,
        date: meal.date,
      ));
      return newId;
    }
    final db = await database;
    return await db!.insert('meal_records', meal.toMap());
  }

  static String mealTypeToString(String t) => t;

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

  // === User Goals ===
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
