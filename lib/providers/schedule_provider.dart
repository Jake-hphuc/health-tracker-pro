import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_schedule.dart';
import '../database/database_helper.dart';

class ScheduleProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _userId;
  List<HealthSchedule> _schedules = [];
  bool _isLoading = false;

  int? get userId => _userId;
  List<HealthSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Lấy danh sách lịch trình hôm nay
  List<HealthSchedule> get todaySchedules {
    final today = _todayStr();
    return _schedules.where((s) => s.date == today || s.repeatType != 'Một lần').toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  int get completedCount => todaySchedules.where((s) => s.isCompleted).length;
  int get totalCount => todaySchedules.length;
  double get progressPercentage => totalCount > 0 ? completedCount / totalCount : 0.0;

  // Khởi tạo theo User ID
  Future<void> init(int userId) async {
    _userId = userId;
    await refreshSchedules();
  }

  // Xóa dữ liệu bộ nhớ khi Logout
  void clear() {
    _userId = null;
    _schedules = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshSchedules() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    _schedules = await _db.getSchedulesByUserId(_userId!);

    // Nếu user mới chưa có lịch trình nào, tự động gợi ý lịch mẫu khoa học
    if (_schedules.isEmpty) {
      await _seedDefaultSchedules();
      _schedules = await _db.getSchedulesByUserId(_userId!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedDefaultSchedules() async {
    if (_userId == null) return;
    final today = _todayStr();
    final now = DateTime.now().toIso8601String();

    final defaultItems = [
      HealthSchedule(
        userId: _userId!,
        title: 'Uống ly nước ấm đầu ngày',
        description: 'Bổ sung 350ml nước lọc đánh thức cơ thể',
        scheduleType: 'Uống nước',
        scheduledTime: '06:30',
        repeatType: 'Hàng ngày',
        isCompleted: false,
        date: today,
        createdAt: now,
      ),
      HealthSchedule(
        userId: _userId!,
        title: 'Vận động buổi sáng / Đi bộ nhẹ',
        description: 'Khởi động ngày mới tràn đầy năng lượng 20 phút',
        scheduleType: 'Tập luyện',
        scheduledTime: '07:00',
        repeatType: 'Hàng ngày',
        isCompleted: false,
        date: today,
        createdAt: now,
      ),
      HealthSchedule(
        userId: _userId!,
        title: 'Bữa trưa đầy đủ dinh dưỡng',
        description: 'Tăng cường rau xanh và đạm lành mạnh',
        scheduleType: 'Ăn uống',
        scheduledTime: '12:00',
        repeatType: 'Hàng ngày',
        isCompleted: false,
        date: today,
        createdAt: now,
      ),
      HealthSchedule(
        userId: _userId!,
        title: 'Tập luyện thể thao / Gym / Chạy bộ',
        description: 'Tập luyện 45 phút tiêu hao calo',
        scheduleType: 'Tập luyện',
        scheduledTime: '17:30',
        repeatType: 'Hàng ngày',
        isCompleted: false,
        date: today,
        createdAt: now,
      ),
      HealthSchedule(
        userId: _userId!,
        title: 'Thư giãn & Đi ngủ đúng giờ',
        description: 'Ngủ đủ 7-8 tiếng để phục hồi năng lượng',
        scheduleType: 'Ngủ',
        scheduledTime: '22:30',
        repeatType: 'Hàng ngày',
        isCompleted: false,
        date: today,
        createdAt: now,
      ),
    ];

    for (final item in defaultItems) {
      await _db.insertSchedule(item);
    }
  }

  Future<void> addSchedule({
    required String title,
    String description = '',
    required String scheduleType,
    required String scheduledTime,
    String repeatType = 'Hàng ngày',
  }) async {
    if (_userId == null) return;
    final now = DateTime.now().toIso8601String();
    final today = _todayStr();

    final schedule = HealthSchedule(
      userId: _userId!,
      title: title,
      description: description,
      scheduleType: scheduleType,
      scheduledTime: scheduledTime,
      repeatType: repeatType,
      isCompleted: false,
      date: today,
      createdAt: now,
    );

    await _db.insertSchedule(schedule);
    await refreshSchedules();
  }

  Future<void> updateSchedule(HealthSchedule schedule) async {
    if (_userId == null) return;
    await _db.updateSchedule(schedule);
    await refreshSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    if (_userId == null) return;
    await _db.deleteSchedule(id, _userId!);
    await refreshSchedules();
  }

  Future<void> toggleComplete(int id) async {
    if (_userId == null) return;
    final schedule = _schedules.firstWhere((s) => s.id == id);
    final nextState = !schedule.isCompleted;

    await _db.toggleScheduleComplete(id, _userId!, nextState);
    
    // Cập nhật optimistic UI ngay lập tức
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(isCompleted: nextState);
      notifyListeners();
    }
  }
}
