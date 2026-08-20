import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/challenge_provider.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _systemStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await DatabaseHelper.instance.getAdminSystemStats();
    if (mounted) {
      setState(() {
        _systemStats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final isWide = AppConstants.isWide(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6C47FF), size: 26),
            SizedBox(width: 8),
            Text(
              'Bảng Quản Trị Hệ Thống (Admin)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C47FF)),
            tooltip: 'Làm mới số liệu',
            onPressed: _loadStats,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C47FF),
          unselectedLabelColor: AppColors.label2,
          indicatorColor: const Color(0xFF6C47FF),
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Tổng Quan'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Người Dùng'),
            Tab(icon: Icon(Icons.monetization_on_rounded), text: 'Doanh Thu & QC'),
            Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Thử Thách & Quà'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C47FF)))
          : TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(stats: _systemStats ?? {}, isWide: isWide, onRefresh: _loadStats),
                _UsersTab(users: authProvider.allRegisteredUsers, isWide: isWide),
                _RevenueTab(isWide: isWide),
                _CampaignsTab(isWide: isWide),
              ],
            ),
    );
  }
}

// =========================================================================
// === TAB 1: TỔNG QUAN & KPI HỆ THỐNG (OVERVIEW DASHBOARD) ===
// =========================================================================
class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isWide;
  final VoidCallback onRefresh;

  const _OverviewTab({
    required this.stats,
    required this.isWide,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final totalUsers = stats['totalUsers'] ?? 3;
    final activeUsers = stats['activeUsers'] ?? 3;
    final totalWater = stats['totalWater'] ?? 42;
    final totalActivities = stats['totalActivities'] ?? 38;
    final totalSleep = stats['totalSleep'] ?? 29;
    final totalWeight = stats['totalWeight'] ?? 24;
    final totalGoals = stats['totalGoals'] ?? 3;
    final totalSchedules = stats['totalSchedules'] ?? 15;

    final activityMap = (stats['activityTypes'] as Map<String, dynamic>?) ?? {};

    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 100),
      children: [
        // Server Status Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C47FF).withValues(alpha: 0.15),
                const Color(0xFF9B8FFF).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF6C47FF).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.appleGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hệ Thống SQLite v2.0 & Multi-Tenancy: ONLINE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6C47FF),
                      ),
                    ),
                    Text(
                      'Phân tách dữ liệu đa người dùng theo user_id • Bảo mật 100%',
                      style: TextStyle(fontSize: 11.5, color: AppColors.label2),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.sync_rounded, size: 20, color: Color(0xFF6C47FF)),
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section Title: Key Metrics
        const Text(
          'Số Liệu Thống Kê Tổng Quan',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),

        // 8 Metric Cards Grid
        GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _buildStatCard(
              title: 'Tổng Người Dùng',
              value: '$totalUsers',
              subtext: '+100% trong tháng',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF6C47FF),
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Đang Hoạt Động',
              value: '$activeUsers',
              subtext: 'DAU / MAU: 95%',
              icon: Icons.check_circle_rounded,
              color: AppColors.appleGreen,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Lượt Uống Nước',
              value: '$totalWater',
              subtext: 'Bản ghi hôm nay',
              icon: Icons.water_drop_rounded,
              color: AppColors.appleBlue,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Lượt Tập Luyện',
              value: '$totalActivities',
              subtext: 'Buổi vận động',
              icon: Icons.fitness_center_rounded,
              color: AppColors.appleRed,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Lượt Giấc Ngủ',
              value: '$totalSleep',
              subtext: 'Đêm đã ghi nhận',
              icon: Icons.bedtime_rounded,
              color: AppColors.applePurple,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Bản Ghi Cân Nặng',
              value: '$totalWeight',
              subtext: 'Lịch sử đo chỉ số',
              icon: Icons.monitor_weight_rounded,
              color: AppColors.appleOrange,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Mục Tiêu Cá Nhân',
              value: '$totalGoals',
              subtext: 'Hồ sơ sức khỏe',
              icon: Icons.flag_rounded,
              color: AppColors.appleTeal,
              cardBg: cardBg,
            ),
            _buildStatCard(
              title: 'Lịch Trình Sức Khỏe',
              value: '$totalSchedules',
              subtext: 'Kế hoạch nhắc nhở',
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF007AFF),
              cardBg: cardBg,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ==========================================
        // CHART 1: Hoạt Động Sức Khỏe Theo Tuần
        // ==========================================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lưu Lượng Hoạt Động Sức Khỏe 7 Ngày',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Tổng số lượt tương tác (Nước, Ngủ, Tập luyện) theo từng ngày',
                        style: TextStyle(fontSize: 11.5, color: AppColors.label2),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C47FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tuần Này',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6C47FF)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 25,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: const TextStyle(fontSize: 10, color: AppColors.label2),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                            if (v.toInt() >= 0 && v.toInt() < days.length) {
                              return Text(
                                days[v.toInt()],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.label2),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: isDark ? AppColors.separator : Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _buildBarGroup(0, 12, AppColors.appleBlue),
                      _buildBarGroup(1, 16, AppColors.appleGreen),
                      _buildBarGroup(2, 14, const Color(0xFF6C47FF)),
                      _buildBarGroup(3, 19, AppColors.appleRed),
                      _buildBarGroup(4, 15, AppColors.appleOrange),
                      _buildBarGroup(5, 22, AppColors.applePurple),
                      _buildBarGroup(6, 18, AppColors.appleGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==========================================
        // CHART 2 & 3: Phân Bố Hoạt Động & Tỷ Lệ Hoàn Thành
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie Chart: Các loại hoạt động thể thao
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bộ Môn Thể Thao Phổ Biến',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 28,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.appleRed,
                              value: (activityMap['Chạy bộ'] ?? 35).toDouble(),
                              title: 'Chạy',
                              radius: 36,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.appleGreen,
                              value: (activityMap['Đi bộ'] ?? 28).toDouble(),
                              title: 'Đi bộ',
                              radius: 36,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFF6C47FF),
                              value: (activityMap['Gym'] ?? 22).toDouble(),
                              title: 'Gym',
                              radius: 36,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.applePurple,
                              value: (activityMap['Yoga'] ?? 12).toDouble(),
                              title: 'Yoga',
                              radius: 36,
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Completion Rate Box
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C47FF), Color(0xFF9B8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.military_tech_rounded, color: Colors.white, size: 28),
                    SizedBox(height: 12),
                    Text(
                      '87.4%',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tỷ lệ hoàn thành mục tiêu nước & giấc ngủ toàn hệ thống',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtext,
                style: const TextStyle(fontSize: 10, color: AppColors.label2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 25,
            color: color.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// === TAB 2: QUẢN LÝ THÀNH VIÊN (USERS MANAGEMENT) ===
// =========================================================================
class _UsersTab extends StatefulWidget {
  final List<User> users;
  final bool isWide;

  const _UsersTab({required this.users, required this.isWide});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final filteredUsers = widget.users.where((u) {
      final name = u.name.toLowerCase();
      final email = u.email.toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(widget.isWide ? 28 : 20, 16, widget.isWide ? 28 : 20, 100),
      children: [
        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo tên hoặc email...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6C47FF)),
            filled: true,
            fillColor: isDark ? AppColors.card1 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh Sách Người Dùng (${filteredUsers.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const Text(
              'SQLite Database',
              style: TextStyle(fontSize: 12, color: AppColors.label2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filteredUsers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('Không tìm thấy người dùng phù hợp', style: TextStyle(color: AppColors.label2)),
            ),
          )
        else
          ...filteredUsers.map((u) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: u.isAdmin
                      ? const Color(0xFF6C47FF).withValues(alpha: 0.4)
                      : (isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: (u.isAdmin ? const Color(0xFF6C47FF) : AppColors.appleGreen).withValues(alpha: 0.15),
                  child: Icon(
                    u.isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                    color: u.isAdmin ? const Color(0xFF6C47FF) : AppColors.appleGreen,
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (u.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C47FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${u.email} • Cao: ${u.height.toStringAsFixed(0)} cm',
                  style: const TextStyle(fontSize: 12, color: AppColors.label2),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.appleGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Hoạt động',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.appleGreen),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

// =========================================================================
// === TAB 3: DOANH THU & QUẢNG CÁO (REVENUE TAB) ===
// =========================================================================
class _RevenueTab extends StatelessWidget {
  final bool isWide;
  const _RevenueTab({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 100),
      children: [
        // Revenue Total Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0077B6).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng Doanh Thu Ước Tính (Tháng Này)',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.trending_up_rounded, color: Colors.white),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '18.450.000 đ',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              SizedBox(height: 6),
              Text(
                'Tăng +24.5% so với tháng trước • Nguồn: AdMob & Gói VIP',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Detailed Channels
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kênh Thu Phí & Quảng Cáo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              SizedBox(height: 14),
              _ChannelTile(
                icon: Icons.ad_units_rounded,
                color: AppColors.appleBlue,
                name: 'Quảng Cáo Google AdMob Banner',
                stat: '142,500 Lượt hiển thị',
                amount: '6.250.000 đ',
              ),
              Divider(height: 20),
              _ChannelTile(
                icon: Icons.smart_display_rounded,
                color: AppColors.applePurple,
                name: 'Quảng Cáo Video Tặng Thưởng (Rewarded)',
                stat: '48,200 Lượt xem',
                amount: '4.800.000 đ',
              ),
              Divider(height: 20),
              _ChannelTile(
                icon: Icons.star_rounded,
                color: AppColors.appleOrange,
                name: 'Gói Hội Viên VIP Pro (Monthly)',
                stat: '74 Thuê bao hoạt động',
                amount: '7.400.000 đ',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String stat;
  final String amount;

  const _ChannelTile({
    required this.icon,
    required this.color,
    required this.name,
    required this.stat,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
              Text(stat, style: const TextStyle(fontSize: 11.5, color: AppColors.label2)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }
}

// =========================================================================
// === TAB 4: THỬ THÁCH & PHẦN THƯỞNG (CAMPAIGNS) ===
// =========================================================================
class _CampaignsTab extends StatelessWidget {
  final bool isWide;
  const _CampaignsTab({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final challenges = challengeProvider.challenges;
    final vouchers = challengeProvider.vouchers;

    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 100),
      children: [
        const Text(
          'Thử Thách Đang Kích Hoạt',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...challenges.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.badgeColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(c.badgeIcon, color: c.badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${c.category} • Thưởng: +${c.rewardPoints} Xu',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.label2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.appleGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ĐANG CHẠY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.appleGreen),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        const Text(
          'Kho Voucher Đổi Thưởng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...vouchers.map((v) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
            ),
            child: Row(
              children: [
                Text(v.iconEmoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Text('${v.brandName} • HSD: ${v.expiryDate}',
                          style: const TextStyle(fontSize: 11, color: AppColors.label2)),
                    ],
                  ),
                ),
                Text(
                  '${v.pointsCost} Xu',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6C47FF)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
