import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _users = [];
  bool _loading = true;

  static const _adData = [
    {'month': 'Tháng 3', 'revenue': 4200000, 'impressions': 128000, 'ctr': 3.2},
    {'month': 'Tháng 4', 'revenue': 5800000, 'impressions': 176000, 'ctr': 3.8},
    {'month': 'Tháng 5', 'revenue': 6100000, 'impressions': 195000, 'ctr': 4.1},
    {'month': 'Tháng 6', 'revenue': 7400000, 'impressions': 220000, 'ctr': 4.5},
    {'month': 'Tháng 7', 'revenue': 9200000, 'impressions': 265000, 'ctr': 4.9},
    {'month': 'Tháng 8', 'revenue': 11500000, 'impressions': 312000, 'ctr': 5.3},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await Provider.of<AuthProvider>(context, listen: false)
        .getAllRegisteredUsers();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = dark ? AppColors.blackBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Bảng Quản Trị Hệ Thống',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KPI Summary Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _Kpi(
                    'Người dùng',
                    '${_users.length + 1}',
                    Icons.people_rounded,
                    AppColors.appleBlue,
                    '+${_users.length} mới',
                  ),
                  const SizedBox(width: 10),
                  const _Kpi(
                    'Hoạt động hôm nay',
                    '847',
                    Icons.trending_up_rounded,
                    AppColors.appleGreen,
                    '+12% tuần này',
                  ),
                  const SizedBox(width: 10),
                  const _Kpi(
                    'Doanh thu Tháng 8',
                    '11.5M',
                    Icons.attach_money_rounded,
                    AppColors.appleOrange,
                    '+25% so với T7',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? AppColors.card2 : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: const Color(0xFF6C47FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.label2,
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Người dùng'),
                    Tab(text: 'Doanh thu & QC'),
                    Tab(text: 'Chỉ số KPI'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _UsersTab(_users, _loading, _load),
                  const _AdsTab(_adData),
                  _StatsTab(_users.length + 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color, this.sub);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dark ? AppColors.card1 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.label2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.appleGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final List<dynamic> users;
  final bool loading;
  final VoidCallback refresh;
  const _UsersTab(this.users, this.loading, this.refresh);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C47FF)));
    }

    final rows = <Map<String, dynamic>>[
      {
        'n': 'Quản Trị Viên (Admin)',
        'e': 'admin@healthtracker.app',
        'admin': true,
        'role': 'Toàn quyền',
      },
      for (final u in users)
        {
          'n': (u as dynamic).name as String,
          'e': u.email as String,
          'admin': false,
          'role': 'Thành viên',
        },
    ];

    return RefreshIndicator(
      onRefresh: () async => refresh(),
      color: const Color(0xFF6C47FF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: rows.length,
        itemBuilder: (ctx, i) {
          final u = rows[i];
          final isA = u['admin'] as bool;
          final col = isA ? const Color(0xFF6C47FF) : AppColors.appleBlue;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isA
                  ? Border.all(color: col.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: col.withValues(alpha: 0.15),
                  child: Text(
                    (u['n'] as String)[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: col,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            u['n'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: dark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (isA) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: col,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        u['e'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.label2),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isA ? Icons.shield_rounded : Icons.person_rounded,
                  color: isA ? col : AppColors.label3,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdsTab extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _AdsTab(this.data);

  String _f(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(0)}K'
          : '$n';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final maxR = data
        .map((d) => d['revenue'] as int)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _RC('Tổng doanh thu', '44.200.000 đ',
                  AppColors.appleGreen, Icons.attach_money_rounded),
              const SizedBox(width: 10),
              const _RC('Lượt hiển thị', '1.300.000', AppColors.appleBlue,
                  Icons.visibility_rounded),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _RC('CTR trung bình', '4.3%', AppColors.appleOrange,
                  Icons.ads_click_rounded),
              const SizedBox(width: 10),
              const _RC('CPM trung bình', '33.800 đ', AppColors.applePurple,
                  Icons.price_check_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Biểu đồ tăng trưởng doanh thu (VNĐ)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: data.map((d) {
                final pct = (d['revenue'] as int) / maxR;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          d['month'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: dark
                                    ? AppColors.card2
                                    : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C47FF),
                                      Color(0xFF9B8FFF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 62,
                        child: Text(
                          '${_f(d['revenue'] as int)} đ',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6C47FF),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RC extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _RC(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? AppColors.card1 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.label2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final int total;
  const _StatsTab(this.total);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rows = [
      ('Tỷ lệ giữ chân người dùng (30 ngày)', '78.5%', AppColors.appleGreen,
          Icons.people_outline_rounded),
      ('Số phiên trung bình / người / ngày', '4.2 phiên', AppColors.appleBlue,
          Icons.timer_outlined),
      ('Thời gian sử dụng trung bình', '18.4 phút', AppColors.applePurple,
          Icons.access_time_rounded),
      ('Tỷ lệ chuyển đổi thành viên mới', '34.2%', AppColors.appleOrange,
          Icons.person_add_outlined),
      ('Người dùng hoạt động mỗi ngày (DAU)', '847 người', AppColors.appleRed,
          Icons.bar_chart_rounded),
      ('Tổng số phiên luyện tập hoàn thành', '42.810 phiên',
          AppColors.appleTeal, Icons.analytics_outlined),
      ('Điểm đánh giá trung bình từ App Store', '4.8 ★ / 5.0',
          AppColors.appleYellow, Icons.star_outline_rounded),
      ('Số chiến dịch tài trợ & quảng cáo', '6 chiến dịch',
          const Color(0xFF6C47FF), Icons.campaign_outlined),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: rows.length,
      itemBuilder: (ctx, i) {
        final (label, value, color, icon) = rows[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? AppColors.card1 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
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
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
