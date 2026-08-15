import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6C47FF)),
            SizedBox(width: 8),
            Text(
              'Bảng Điều Khiển Quản Trị',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C47FF),
          unselectedLabelColor: AppColors.label2,
          indicatorColor: const Color(0xFF6C47FF),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Người Dùng'),
            Tab(icon: Icon(Icons.monetization_on_rounded), text: 'Doanh Thu QC'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Chỉ Số KPI'),
          ],
        ),
      ),
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _UsersTab(users: authProvider.allRegisteredUsers),
                    const _RevenueTab(),
                    const _KpiTab(),
                  ],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _UsersTab(users: authProvider.allRegisteredUsers),
                const _RevenueTab(),
                const _KpiTab(),
              ],
            ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final List<User> users;
  const _UsersTab({required this.users});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng số tài khoản: ${users.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C47FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      size: 14, color: Color(0xFF6C47FF)),
                  SizedBox(width: 4),
                  Text('Đã xác thực',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C47FF))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...users.map((u) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: u.isAdmin
                  ? Border.all(
                      color: const Color(0xFF6C47FF).withValues(alpha: 0.4),
                      width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: u.isAdmin
                        ? const Color(0xFF6C47FF).withValues(alpha: 0.15)
                        : AppColors.appleBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: u.isAdmin
                          ? const Color(0xFF6C47FF)
                          : AppColors.appleBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            u.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          if (u.isAdmin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C47FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.label2),
                      ),
                      Text(
                        'Chiều cao: ${u.height.toInt()} cm',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.label3),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.appleGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hoạt động',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appleGreen),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _StatBox(
              title: 'Doanh Thu Tháng',
              value: '14.850.000 đ',
              delta: '+18.4%',
              color: AppColors.appleGreen,
              cardBg: cardBg,
            ),
            const SizedBox(width: 12),
            _StatBox(
              title: 'Lượt Xem QC',
              value: '124.500',
              delta: '+24.1%',
              color: AppColors.appleBlue,
              cardBg: cardBg,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatBox(
              title: 'eCPM Trung Bình',
              value: '119.200 đ',
              delta: '+5.2%',
              color: AppColors.applePurple,
              cardBg: cardBg,
            ),
            const SizedBox(width: 12),
            _StatBox(
              title: 'Tỉ Lệ Click (CTR)',
              value: '3.42%',
              delta: '+0.8%',
              color: AppColors.appleOrange,
              cardBg: cardBg,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Biểu Đồ Doanh Thu Quảng Cáo (Triệu VNĐ)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, m) => Text(
                            '${v.toInt()}tr',
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.label3),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, m) {
                            const months = [
                              'T3',
                              'T4',
                              'T5',
                              'T6',
                              'T7',
                              'T8'
                            ];
                            final idx = v.toInt();
                            if (idx >= 0 && idx < months.length) {
                              return Text(months[idx],
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.label2));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBar(0, 6.2, const Color(0xFF6C47FF)),
                      _makeBar(1, 8.4, const Color(0xFF6C47FF)),
                      _makeBar(2, 9.8, const Color(0xFF6C47FF)),
                      _makeBar(3, 11.5, const Color(0xFF6C47FF)),
                      _makeBar(4, 13.2, const Color(0xFF6C47FF)),
                      _makeBar(5, 14.85, AppColors.appleGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}

class _KpiTab extends StatelessWidget {
  const _KpiTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chỉ Số Tăng Trưởng Ứng Dụng (KPI)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _KpiRow(
                label: 'Tỷ Lệ Giữ Chân Ngày 7 (Retention D7)',
                value: '68.5%',
                progress: 0.685,
                color: AppColors.appleGreen,
              ),
              const SizedBox(height: 14),
              _KpiRow(
                label: 'Người Dùng Hoạt Động Hàng Ngày (DAU)',
                value: '4.280',
                progress: 0.82,
                color: AppColors.appleBlue,
              ),
              const SizedBox(height: 14),
              _KpiRow(
                label: 'Thời Gian Sử Dụng Trung Bình / Phiên',
                value: '14.5 phút',
                progress: 0.72,
                color: AppColors.applePurple,
              ),
              const SizedBox(height: 14),
              _KpiRow(
                label: 'Tỉ Lệ Đăng Ký Tài Khoản Mới',
                value: '91.2%',
                progress: 0.912,
                color: AppColors.appleOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final Color color;
  final Color cardBg;

  const _StatBox({
    required this.title,
    required this.value,
    required this.delta,
    required this.color,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 11, color: AppColors.label2)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.arrow_upward_rounded, size: 12, color: color),
                const SizedBox(width: 2),
                Text(delta,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _KpiRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.label2)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.separator.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
