import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
// import '../models/meal_record.dart';
import '../utils/constants.dart';

class MealScannerScreen extends StatefulWidget {
  const MealScannerScreen({super.key});

  @override
  State<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends State<MealScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.blackBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appleOrange, AppColors.appleYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dinh DÆ°á»¡ng & Calo AI',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text(
                          'QuĂ©t áº£nh mĂ³n Äƒn & Tá»± Ä‘á»™ng tĂ­nh Calo',
                          style: TextStyle(fontSize: 12, color: AppColors.label2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.appleOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.appleOrange, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'AI SCAN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.appleOrange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card2 : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: AppColors.appleOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.label2,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'QuĂ©t MĂ³n Ä‚n AI'),
                    Tab(text: 'Nháº­t KĂ½ & Macro'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  _AiScannerTab(),
                  _NutritionDiaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiScannerTab extends StatefulWidget {
  const _AiScannerTab();

  @override
  State<_AiScannerTab> createState() => _AiScannerTabState();
}

class _AiScannerTabState extends State<_AiScannerTab> with SingleTickerProviderStateMixin {
  late AnimationController _laserCtrl;
  bool _isScanning = false;
  Map<String, dynamic>? _detectedFood;
  double _portion = 1.0;
  String _selectedMealType = 'Bá»¯a trÆ°a';

  static final _foodSamples = [
    {
      'name': 'Phá»Ÿ BĂ² TĂ¡i Náº¡m',
      'calories': 520,
      'protein': 32.0,
      'carbs': 68.0,
      'fat': 12.5,
      'confidence': 98.4,
      'emoji': 'đŸ²',
      'desc': 'NÆ°á»›c dĂ¹ng Ä‘áº­m Ä‘Ă , thá»‹t bĂ² tÆ°Æ¡i & bĂ¡nh phá»Ÿ tráº¯ng',
    },
    {
      'name': 'CÆ¡m Táº¥m SÆ°á»n BĂ¬ Cháº£',
      'calories': 680,
      'protein': 38.0,
      'carbs': 85.0,
      'fat': 22.0,
      'confidence': 97.2,
      'emoji': 'đŸ›',
      'desc': 'SÆ°á»n nÆ°á»›ng máº­t ong, bĂ¬ thÆ¡m & cháº£ trá»©ng háº¥p',
    },
    {
      'name': 'BĂ¡nh MĂ¬ Thá»‹t Nguá»™i',
      'calories': 430,
      'protein': 21.0,
      'carbs': 52.0,
      'fat': 16.0,
      'confidence': 99.1,
      'emoji': 'đŸ¥–',
      'desc': 'BĂ¡nh mĂ¬ giĂ²n rá»¥m káº¹p pate, cháº£ lá»¥a & dÆ°a leo',
    },
    {
      'name': 'Salad á»¨c GĂ  Sá»‘t MĂ¨ Rang',
      'calories': 340,
      'protein': 42.0,
      'carbs': 18.0,
      'fat': 9.5,
      'confidence': 96.8,
      'emoji': 'đŸ¥—',
      'desc': 'á»¨c gĂ  Ă¡p cháº£o, xĂ  lĂ¡ch tÆ°Æ¡i, cĂ  chua bi & mĂ¨ rang',
    },
    {
      'name': 'BĂºn Cháº£ HĂ  Ná»™i',
      'calories': 560,
      'protein': 34.0,
      'carbs': 64.0,
      'fat': 18.0,
      'confidence': 97.9,
      'emoji': 'đŸœ',
      'desc': 'Cháº£ nÆ°á»›ng than hoa, nÆ°á»›c máº¯m chua ngá»t & bĂºn tÆ°Æ¡i',
    },
    {
      'name': 'CĂ¡ Há»“i Ăp Cháº£o & Quinoa',
      'calories': 480,
      'protein': 39.0,
      'carbs': 32.0,
      'fat': 21.0,
      'confidence': 98.9,
      'emoji': 'đŸŸ',
      'desc': 'GiĂ u Omega-3, háº¡t diĂªm máº¡ch & mÄƒng tĂ¢y xĂ o bÆ¡ tá»i',
    },
    {
      'name': 'BÆ¡ Dáº§m Sá»¯a Chua Hy Láº¡p',
      'calories': 280,
      'protein': 14.0,
      'carbs': 24.0,
      'fat': 15.0,
      'confidence': 96.5,
      'emoji': 'đŸ¥‘',
      'desc': 'Cháº¥t bĂ©o tá»‘t tá»« quáº£ bÆ¡, giĂ u probiotics & protein',
    },
  ];

  @override
  void initState() {
    super.initState();
    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserCtrl.dispose();
    super.dispose();
  }

  void _triggerScan(Map<String, dynamic> food) async {
    setState(() {
      _isScanning = true;
      _detectedFood = null;
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _detectedFood = food;
      _portion = 1.0;
    });
  }

  void _saveMeal() {
    if (_detectedFood == null) return;
    final health = Provider.of<HealthProvider>(context, listen: false);
    final cals = ((_detectedFood!['calories'] as int) * _portion).round();
    final p = (_detectedFood!['protein'] as double) * _portion;
    final c = (_detectedFood!['carbs'] as double) * _portion;
    final f = (_detectedFood!['fat'] as double) * _portion;

    health.addMeal(
      name: _detectedFood!['name'] as String,
      mealType: _selectedMealType,
      calories: cals,
      protein: p,
      carbs: c,
      fat: f,
      imagePath: _detectedFood!['emoji'] as String,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ÄĂ£ lÆ°u ${_detectedFood!['name']} (+$cals kcal)! đŸ‰'),
        backgroundColor: AppColors.appleGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    setState(() => _detectedFood = null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141416) : Colors.black87,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.appleOrange.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  top: 24, left: 24,
                  child: Container(width: 28, height: 28, decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.appleOrange, width: 3), left: BorderSide(color: AppColors.appleOrange, width: 3)))),
                ),
                Positioned(
                  top: 24, right: 24,
                  child: Container(width: 28, height: 28, decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.appleOrange, width: 3), right: BorderSide(color: AppColors.appleOrange, width: 3)))),
                ),
                Positioned(
                  bottom: 24, left: 24,
                  child: Container(width: 28, height: 28, decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.appleOrange, width: 3), left: BorderSide(color: AppColors.appleOrange, width: 3)))),
                ),
                Positioned(
                  bottom: 24, right: 24,
                  child: Container(width: 28, height: 28, decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.appleOrange, width: 3), right: BorderSide(color: AppColors.appleOrange, width: 3)))),
                ),
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _laserCtrl,
                    builder: (context, _) {
                      return Positioned(
                        top: 30 + (_laserCtrl.value * 160),
                        left: 28, right: 28,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, AppColors.appleOrange, Colors.white, AppColors.appleOrange, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(color: AppColors.appleOrange.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                Positioned(
                  bottom: 16, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isScanning ? 'AI Äang phĂ¢n tĂ­ch cáº¥u trĂºc mĂ³n Äƒn...' : 'Chá»n mĂ³n Äƒn bĂªn dÆ°á»›i Ä‘á»ƒ quĂ©t máº«u AI',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_detectedFood != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.appleGreen.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.appleGreen.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_detectedFood!['emoji'] as String, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _detectedFood!['name'] as String,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              _detectedFood!['desc'] as String,
                              style: const TextStyle(fontSize: 12, color: AppColors.label2),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.appleGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_detectedFood!['confidence']}% AI',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.appleGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _MacroBadge('Calo', '${((_detectedFood!['calories'] as int) * _portion).round()} kcal', AppColors.appleOrange),
                      const SizedBox(width: 8),
                      _MacroBadge('Protein', '${((_detectedFood!['protein'] as double) * _portion).toStringAsFixed(1)}g', AppColors.appleRed),
                      const SizedBox(width: 8),
                      _MacroBadge('Carbs', '${((_detectedFood!['carbs'] as double) * _portion).toStringAsFixed(1)}g', AppColors.appleBlue),
                      const SizedBox(width: 8),
                      _MacroBadge('Fat', '${((_detectedFood!['fat'] as double) * _portion).toStringAsFixed(1)}g', AppColors.applePurple),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Kháº©u pháº§n:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      ...[0.5, 1.0, 1.5, 2.0].map((p) {
                        final sel = _portion == p;
                        return GestureDetector(
                          onTap: () => setState(() => _portion = p),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.appleOrange : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${p}x',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : null),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedMealType,
                        underline: const SizedBox(),
                        items: ['Bá»¯a sĂ¡ng', 'Bá»¯a trÆ°a', 'Bá»¯a tá»‘i', 'Bá»¯a phá»¥'].map((t) {
                          return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedMealType = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveMeal,
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text('LÆ¯U VĂ€O NHáº¬T KĂ Ä‚N Uá»NG', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appleGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Chá»n mĂ³n Äƒn máº«u Ä‘á»ƒ quĂ©t thá»­ AI:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: _foodSamples.length,
            itemBuilder: (context, i) {
              final food = _foodSamples[i];
              return GestureDetector(
                onTap: () => _triggerScan(food),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card1 : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
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
                          Text(food['emoji'] as String, style: const TextStyle(fontSize: 24)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.appleOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${food['calories']} kcal',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.appleOrange),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'P: ${food['protein']}g â€¢ C: ${food['carbs']}g',
                            style: const TextStyle(fontSize: 10, color: AppColors.label2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.label2)),
          ],
        ),
      ),
    );
  }
}

class _NutritionDiaryTab extends StatelessWidget {
  const _NutritionDiaryTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final health = Provider.of<HealthProvider>(context);

    const targetCals = 2000;
    final consumed = health.todayCaloriesIn;
    final burned = (health.todayActivityMinutes * 6) + 1400;
    final remaining = targetCals - consumed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CĂ¢n Báº±ng NÄƒng LÆ°á»£ng HĂ´m Nay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: remaining >= 0 ? AppColors.appleGreen.withValues(alpha: 0.2) : AppColors.appleRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        remaining >= 0 ? 'ThĂ¢m há»¥t tá»‘t' : 'VÆ°á»£t má»©c',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: remaining >= 0 ? AppColors.appleGreen : AppColors.appleRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CalStat('Má»¥c tiĂªu', '$targetCals', 'kcal', AppColors.label2),
                    const Text('-', style: TextStyle(color: AppColors.label2, fontSize: 18)),
                    _CalStat('Náº¡p vĂ o', '$consumed', 'kcal', AppColors.appleOrange),
                    const Text('+', style: TextStyle(color: AppColors.label2, fontSize: 18)),
                    _CalStat('ÄĂ£ Ä‘á»‘t', '$burned', 'kcal', AppColors.appleRed),
                    const Text('=', style: TextStyle(color: AppColors.label2, fontSize: 18)),
                    _CalStat('CĂ²n láº¡i', '$remaining', 'kcal', remaining >= 0 ? AppColors.appleGreen : AppColors.appleRed),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (consumed / targetCals).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      consumed <= targetCals ? AppColors.appleOrange : AppColors.appleRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MacroCard('Protein', health.todayProtein, 120.0, 'g', AppColors.appleRed, isDark),
              const SizedBox(width: 10),
              _MacroCard('Carbs', health.todayCarbs, 250.0, 'g', AppColors.appleBlue, isDark),
              const SizedBox(width: 10),
              _MacroCard('Fat', health.todayFat, 55.0, 'g', AppColors.applePurple, isDark),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.applePurple.withValues(alpha: 0.15),
                  AppColors.appleBlue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.applePurple.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_mode_rounded, color: AppColors.applePurple, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tá»± Ä‘á»™ng gá»£i Ă½ Giáº¥c Ngá»§ ThĂ´ng Minh',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.applePurple),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dá»±a trĂªn nÄƒng lÆ°á»£ng hĂ´m nay, chu ká»³ ngá»§ lĂ½ tÆ°á»Ÿng lĂ  5 chu ká»³ (7.5 giá») lĂºc 22:45.',
                        style: TextStyle(fontSize: 11, color: AppColors.label2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bá»¯a Äƒn hĂ´m nay (${health.todayMeals.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
              ),
              if (health.todayMeals.isNotEmpty)
                Text('${health.todayCaloriesIn} kcal tá»•ng', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appleOrange)),
            ],
          ),
          const SizedBox(height: 12),
          if (health.todayMeals.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.no_meals_rounded, size: 48, color: AppColors.label3),
                  SizedBox(height: 10),
                  Text('ChÆ°a cĂ³ bá»¯a Äƒn nĂ o Ä‘Æ°á»£c ghi nháº­n hĂ´m nay', style: TextStyle(color: AppColors.label2, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Chuyá»ƒn qua tab "QuĂ©t MĂ³n Ä‚n AI" Ä‘á»ƒ thĂªm nhĂ©!', style: TextStyle(color: AppColors.appleOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            ...health.todayMeals.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card1 : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Text(m.imagePath ?? 'đŸ²', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(m.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.appleOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(m.mealType, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.appleOrange)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${m.time} â€¢ P: ${m.protein.toStringAsFixed(0)}g â€¢ C: ${m.carbs.toStringAsFixed(0)}g â€¢ F: ${m.fat.toStringAsFixed(0)}g',
                            style: const TextStyle(fontSize: 11, color: AppColors.label2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${m.calories} kcal',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.appleOrange),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.label3),
                      onPressed: () => health.deleteMeal(m.id ?? 0),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label, val, unit;
  final Color col;
  const _CalStat(this.label, this.val, this.unit, this.col);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: col)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit;
  final double cur, target;
  final Color color;
  final bool isDark;

  const _MacroCard(this.label, this.cur, this.target, this.unit, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    final pct = (cur / target).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card1 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.label2)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(cur.toStringAsFixed(0), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
                Text('/${target.toStringAsFixed(0)}$unit', style: const TextStyle(fontSize: 10, color: AppColors.label2)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
