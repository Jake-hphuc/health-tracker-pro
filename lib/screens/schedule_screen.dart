import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../models/health_schedule.dart';
import '../utils/constants.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final isWide = AppConstants.isWide(context);

    final allSchedules = scheduleProvider.todaySchedules;
    final filteredSchedules = _selectedFilter == 'Tất cả'
        ? allSchedules
        : _selectedFilter == 'Chưa xong'
            ? allSchedules.where((s) => !s.isCompleted).toList()
            : allSchedules.where((s) => s.isCompleted).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: AppColors.appleBlue),
            SizedBox(width: 8),
            Text(
              'Lịch Trình Sức Khỏe',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.appleBlue),
            onPressed: () => scheduleProvider.refreshSchedules(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.appleBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm Lịch',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
        onPressed: () => _showAddEditScheduleDialog(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => scheduleProvider.refreshSchedules(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Progress Banner Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 12, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: _buildProgressCard(context, scheduleProvider, isDark),
              ),
            ),

            // 2. Filter Pills Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', allSchedules.length, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Chưa xong', allSchedules.where((s) => !s.isCompleted).length, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã xong', allSchedules.where((s) => s.isCompleted).length, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Section Title
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hôm nay (${DateFormat('dd/MM/yyyy').format(DateTime.now())})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      '${filteredSchedules.length} lịch trình',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.label2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Schedules List
            if (filteredSchedules.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.appleBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            size: 48,
                            color: AppColors.appleBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có lịch trình nào',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bấm "+ Thêm Lịch" để lên kế hoạch rèn luyện cho hôm nay nhé!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.label2),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 28 : 20,
                  0,
                  isWide ? 28 : 20,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredSchedules[index];
                      return _buildScheduleItem(context, item, isDark);
                    },
                    childCount: filteredSchedules.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    ScheduleProvider provider,
    bool isDark,
  ) {
    final completed = provider.completedCount;
    final total = provider.totalCount;
    final progress = provider.progressPercentage;
    final percentInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                ]
              : [
                  const Color(0xFFE0F2FE),
                  const Color(0xFFF0FDF4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.appleBlue.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appleBlue.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.appleBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: AppColors.appleBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tiến Độ Hôm Nay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.appleBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentInt%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? progress : 0,
              minHeight: 10,
              backgroundColor: isDark ? AppColors.card2 : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.appleBlue),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            total > 0
                ? 'Đã hoàn thành $completed trên tổng số $total mục tiêu lịch trình'
                : 'Chưa có lịch trình nào được thiết lập',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.label2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isDark) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appleBlue
              : (isDark ? AppColors.card1 : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.appleBlue
                : (isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? AppColors.white : Colors.black87),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? AppColors.card2 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.label2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    HealthSchedule item,
    bool isDark,
  ) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card1 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isCompleted
              ? AppColors.appleGreen.withValues(alpha: 0.3)
              : (isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => provider.toggleComplete(item.id!),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: item.isCompleted ? 0.12 : 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isCompleted ? AppColors.label2 : item.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.scheduledTime,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: item.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.card2 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.repeatType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.label2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: item.isCompleted ? AppColors.label2 : null,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.label2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions: Checkbox & Menu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: item.isCompleted
                            ? AppColors.appleGreen
                            : AppColors.label3,
                        size: 28,
                      ),
                      onPressed: () => provider.toggleComplete(item.id!),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.label2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddEditScheduleDialog(context, schedule: item);
                        } else if (value == 'delete') {
                          _confirmDelete(context, item.id!);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: AppColors.appleBlue),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.appleRed),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: AppColors.appleRed)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa lịch trình sức khỏe này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.appleRed),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddEditScheduleDialog(BuildContext context, {HealthSchedule? schedule}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = schedule != null;

    final titleController = TextEditingController(text: schedule?.title ?? '');
    final descController = TextEditingController(text: schedule?.description ?? '');
    String selectedType = schedule?.scheduleType ?? 'Uống nước';
    String selectedRepeat = schedule?.repeatType ?? 'Hàng ngày';
    TimeOfDay selectedTime = schedule != null
        ? TimeOfDay(
            hour: int.parse(schedule.scheduledTime.split(':').first),
            minute: int.parse(schedule.scheduledTime.split(':').last),
          )
        : const TimeOfDay(hour: 7, minute: 0);

    final scheduleTypes = [
      'Uống nước',
      'Tập luyện',
      'Ăn uống',
      'Ngủ',
      'Đo cân nặng',
      'Khác',
    ];

    final repeatTypes = ['Một lần', 'Hàng ngày', 'Hàng tuần'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.card1 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final timeStr =
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Chỉnh Sửa Lịch Trình' : 'Thêm Lịch Trình Mới',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tiêu đề
                  const Text('Tiêu đề công việc *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Uống 500ml nước ấm, Chạy bộ 20p...',
                      filled: true,
                      fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Loại lịch trình
                  const Text('Loại hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: scheduleTypes.map((type) {
                      final isSel = selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSel,
                        selectedColor: AppColors.appleBlue,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setModalState(() => selectedType = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Chọn giờ
                  const Text('Giờ thực hiện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: AppColors.appleBlue, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                timeStr,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const Text(
                            'Chạm để đổi',
                            style: TextStyle(color: AppColors.appleBlue, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lặp lại
                  const Text('Chu kỳ lặp lại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: repeatTypes.map((rep) {
                      final isSel = selectedRepeat == rep;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                            label: Center(child: Text(rep, style: const TextStyle(fontSize: 12))),
                            selected: isSel,
                            selectedColor: AppColors.appleBlue,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) => setModalState(() => selectedRepeat = rep),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Ghi chú
                  const Text('Ghi chú / Mô tả chi tiết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập thông tin hướng dẫn nếu cần...',
                      filled: true,
                      fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút Lưu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appleBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập tiêu đề lịch trình!')),
                        );
                        return;
                      }

                      final provider = Provider.of<ScheduleProvider>(context, listen: false);

                      if (isEditing) {
                        final updated = schedule.copyWith(
                          title: title,
                          description: descController.text.trim(),
                          scheduleType: selectedType,
                          scheduledTime: timeStr,
                          repeatType: selectedRepeat,
                        );
                        await provider.updateSchedule(updated);
                      } else {
                        await provider.addSchedule(
                          title: title,
                          description: descController.text.trim(),
                          scheduleType: selectedType,
                          scheduledTime: timeStr,
                          repeatType: selectedRepeat,
                        );
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(
                      isEditing ? 'CẬP NHẬT LỊCH TRÌNH' : 'LƯU LỊCH TRÌNH',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
