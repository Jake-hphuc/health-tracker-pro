import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _users = [];
  bool _loading = true;

  static const _adData = [
    {'month': 'T3', 'revenue': 4200000, 'impressions': 128000, 'ctr': 3.2},
    {'month': 'T4', 'revenue': 5800000, 'impressions': 176000, 'ctr': 3.8},
    {'month': 'T5', 'revenue': 6100000, 'impressions': 195000, 'ctr': 4.1},
    {'month': 'T6', 'revenue': 7400000, 'impressions': 220000, 'ctr': 4.5},
    {'month': 'T7', 'revenue': 9200000, 'impressions': 265000, 'ctr': 4.9},
    {'month': 'T8', 'revenue': 11500000, 'impressions': 312000, 'ctr': 5.3},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await Provider.of<AuthProvider>(context, listen: false).getAllRegisteredUsers();
    setState(() { _users = users; _loading = false; });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.blackBg : AppColors.lightBg,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C47FF), Color(0xFF9B8FFF)]), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('Health Tracker Pro', style: TextStyle(fontSize: 12, color: AppColors.label2)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Color(0x206C47FF), borderRadius: BorderRadius.circular(10)),
            child: const Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6C47FF)))),
        ])),
        // KPI row
        Padding(padding: const EdgeInsets.fromLTRB(16,16,16,0), child: Row(children: [
          _Kpi('Nguoi dung', '${_users.length+1}', Icons.people_rounded, AppColors.appleBlue, '+${_users.length} moi'),
          const SizedBox(width: 10),
          const _Kpi('DAU hom nay', '847', Icons.trending_up_rounded, AppColors.appleGreen, '+12% tuan'),
          const SizedBox(width: 10),
          const _Kpi('Doanh thu T8', '11.5M', Icons.attach_money_rounded, AppColors.appleOrange, '+25% thang'),
        ])),
        const SizedBox(height: 16),
        // TabBar
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child:
          Container(decoration: BoxDecoration(color: dark ? AppColors.card2 : const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(14)),
            child: TabBar(controller: _tabCtrl,
              indicator: BoxDecoration(color: const Color(0xFF6C47FF), borderRadius: BorderRadius.circular(12)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white, unselectedLabelColor: AppColors.label2,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: const [Tab(text: 'Nguoi dung'), Tab(text: 'Quang cao'), Tab(text: 'Thong ke')]))),
        const SizedBox(height: 12),
        Expanded(child: TabBarView(controller: _tabCtrl, children: [
          _UsersTab(_users, _loading, _load),
          _AdsTab(_adData),
          _StatsTab(_users.length + 1),
        ])),
      ])),
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
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: dark ? AppColors.card1 : Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0,4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18), const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.appleGreen, fontWeight: FontWeight.w600)),
      ]),
    ));
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
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6C47FF)));
    final rows = <Map<String, dynamic>>[
      {'n': 'Administrator', 'e': 'admin@healthtracker.app', 'admin': true},
      for (final u in users) {'n': (u as dynamic).name as String, 'e': u.email as String, 'admin': false},
    ];
    return RefreshIndicator(onRefresh: () async => refresh(), color: const Color(0xFF6C47FF),
      child: ListView.builder(padding: const EdgeInsets.fromLTRB(16,0,16,80), itemCount: rows.length, itemBuilder: (ctx, i) {
        final u = rows[i]; final isA = u['admin'] as bool;
        final col = isA ? const Color(0xFF6C47FF) : AppColors.appleBlue;
        return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: dark ? AppColors.card1 : Colors.white, borderRadius: BorderRadius.circular(16),
            border: isA ? Border.all(color: col.withValues(alpha: 0.4)) : null),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: col.withValues(alpha: 0.15),
              child: Text((u['n'] as String)[0].toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: col))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(u['n'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                if (isA) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(6)),
                  child: const Text('ADMIN', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)))],
              ]),
              Text(u['e'] as String, style: const TextStyle(fontSize: 12, color: AppColors.label2)),
            ])),
            Icon(isA ? Icons.shield_rounded : Icons.person_rounded, color: isA ? col : AppColors.label3, size: 18),
          ]));
      }));
  }
}

class _AdsTab extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _AdsTab(this.data);
  String _f(int n) => n >= 1000000 ? '${(n/1000000).toStringAsFixed(1)}M' : n >= 1000 ? '${(n/1000).toStringAsFixed(0)}K' : '$n';
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final maxR = data.map((d) => d['revenue'] as int).reduce((a, b) => a > b ? a : b);
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16,0,16,80), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _RC('Tong doanh thu', '44.2M VND', AppColors.appleGreen, Icons.attach_money_rounded),
        const SizedBox(width: 10),
        _RC('Luot hien thi', '1.3M', AppColors.appleBlue, Icons.visibility_rounded),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _RC('CTR trung binh', '4.3%', AppColors.appleOrange, Icons.ads_click_rounded),
        const SizedBox(width: 10),
        _RC('CPM trung binh', '33.8K VND', AppColors.applePurple, Icons.price_check_rounded),
      ]),
      const SizedBox(height: 20),
      Text('Doanh thu theo thang (VND)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? AppColors.card1 : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: data.map((d) {
          final pct = (d['revenue'] as int) / maxR;
          return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            SizedBox(width: 28, child: Text(d['month'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.label2))),
            const SizedBox(width: 8),
            Expanded(child: Stack(children: [
              Container(height: 28, decoration: BoxDecoration(color: dark ? AppColors.card2 : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8))),
              FractionallySizedBox(widthFactor: pct, child: Container(height: 28, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C47FF), Color(0xFF9B8FFF)]), borderRadius: BorderRadius.circular(8)))),
            ])),
            const SizedBox(width: 8),
            SizedBox(width: 54, child: Text(_f(d['revenue'] as int), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6C47FF)), textAlign: TextAlign.right)),
          ]));
        }).toList())),
    ]));
  }
}

class _RC extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _RC(this.label, this.value, this.color, this.icon);
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: dark ? AppColors.card1 : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ])));
  }
}

class _StatsTab extends StatelessWidget {
  final int total;
  const _StatsTab(this.total);
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rows = [
      ('Ty le giu chan (30 ngay)', '78%', AppColors.appleGreen, Icons.people_outline_rounded),
      ('Phien TB / ngay', '4.2', AppColors.appleBlue, Icons.timer_outlined),
      ('Thoi gian dung TB', '18 phut', AppColors.applePurple, Icons.access_time_rounded),
      ('Ty le dang ky', '34%', AppColors.appleOrange, Icons.person_add_outlined),
      ('DAU (nguoi dung/ngay)', '847', AppColors.appleRed, Icons.bar_chart_rounded),
      ('Tong phien tu dau', '42,810', AppColors.appleTeal, Icons.analytics_outlined),
      ('Rating trung binh', '4.8 sao', AppColors.appleYellow, Icons.star_outline_rounded),
      ('Goi quang cao dang chay', '6 goi', const Color(0xFF6C47FF), Icons.campaign_outlined),
    ];
    return ListView.builder(padding: const EdgeInsets.fromLTRB(16,0,16,80), itemCount: rows.length, itemBuilder: (ctx, i) {
      final (label, value, color, icon) = rows[i];
      return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: dark ? AppColors.card1 : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: dark ? Colors.white : Colors.black87))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ]));
    });
  }
}