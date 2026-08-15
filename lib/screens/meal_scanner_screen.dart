import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class MealScannerScreen extends StatefulWidget {
  const MealScannerScreen({super.key});

  @override
  State<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends State<MealScannerScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  late AnimationController _scannerAnimController;
  late Animation<double> _scannerAnim;

  // Selected food preset for analysis
  _FoodItem? _detectedFood;
  int _servingCount = 1;
  String _selectedMealType = 'Bữa Trưa';

  static const List<_FoodItem> _foodDatabase = [
    _FoodItem(name: 'Phở Bò Tái Nạm', calories: 480, protein: 28, carbs: 62, fat: 12, emoji: '🍜', category: 'Món nước'),
    _FoodItem(name: 'Cơm Tấm Sườn Bì Chả', calories: 650, protein: 32, carbs: 80, fat: 22, emoji: '🍛', category: 'Cơm'),
    _FoodItem(name: 'Bánh Mì Thịt Nguội & Pate', calories: 420, protein: 18, carbs: 54, fat: 14, emoji: '🥖', category: 'Bánh mì'),
    _FoodItem(name: 'Bún Chả Hà Nội', calories: 530, protein: 30, carbs: 65, fat: 16, emoji: '🥗', category: 'Bún'),
    _FoodItem(name: 'Salad Ức Gà Sốt Mè Rang', calories: 310, protein: 38, carbs: 15, fat: 9, emoji: '🥗', category: 'Healthy'),
    _FoodItem(name: 'Trứng Chiên & Bơ Tươi Toast', calories: 340, protein: 16, carbs: 28, fat: 18, emoji: '🍳', category: 'Ăn sáng'),
    _FoodItem(name: 'Cá Hồi Áp Chảo & Khoai Lang', calories: 460, protein: 35, carbs: 42, fat: 15, emoji: '🐟', category: 'Healthy'),
    _FoodItem(name: 'Sinh Tố Bơ Chuối Sữa Hạt', calories: 280, protein: 8, carbs: 36, fat: 12, emoji: '🥑', category: 'Đồ uống'),
  ];

  @override
  void initState() {
    super.initState();
    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerAnimController.dispose();
    super.dispose();
  }

  void _startAiScanSimulation() async {
    setState(() {
      _isScanning = true;
      _detectedFood = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Pick a realistic food item
    final randomFood = (_foodDatabase..shuffle()).first;
    setState(() {
      _isScanning = false;
      _detectedFood = randomFood;
      _servingCount = 1;
    });
  }

  void _saveMeal() {
    if (_detectedFood == null) return;

    final health = Provider.of<HealthProvider>(context, listen: false);
    final totalCalories = _detectedFood!.calories * _servingCount;
    final totalProtein = _detectedFood!.protein * _servingCount.toDouble();
    final totalCarbs = _detectedFood!.carbs * _servingCount.toDouble();
    final totalFat = _detectedFood!.fat * _servingCount.toDouble();

    health.addMeal(
      name: '${_detectedFood!.name} ($_servingCount phần)',
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      mealType: _selectedMealType,
      photoEmoji: _detectedFood!.emoji,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm bữa ăn: ${_detectedFood!.name} (+$totalCalories kcal)! 🍽️'),
        backgroundColor: AppColors.appleOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    setState(() {
      _detectedFood = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final health = Provider.of<HealthProvider>(context);

    final totalCaloriesIn = health.todayCaloriesIn;
    final totalCaloriesBurned = (health.todayActivityMinutes * 6.5).round();
    const dailyCalorieTarget = 2000;
    final calorieBalance = dailyCalorieTarget - totalCaloriesIn + totalCaloriesBurned;

    final content = CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chế Độ Ăn & AI Calo 🥗',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Chụp ảnh món ăn để AI tự động nhận diện và tính toán Calo',
                    style: TextStyle(fontSize: 13, color: AppColors.label2)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // Calorie Energy Balance Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CaloriePill(label: 'Mục Tiêu', value: '$dailyCalorieTarget', unit: 'kcal', color: AppColors.appleBlue),
                      const Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.label2)),
                      _CaloriePill(label: 'Đã Nạp', value: '$totalCaloriesIn', unit: 'kcal', color: AppColors.appleOrange),
                      const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.label2)),
                      _CaloriePill(label: 'Đốt Cháy', value: '$totalCaloriesBurned', unit: 'kcal', color: AppColors.appleRed),
                      const Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.label2)),
                      _CaloriePill(label: 'Còn Lại', value: '$calorieBalance', unit: 'kcal', color: AppColors.appleGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // AI Camera Viewfinder Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: isDark ? AppColors.card2 : const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.appleOrange.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder corners
                  Positioned(
                    top: 20, left: 20,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.appleOrange, width: 3), left: BorderSide(color: AppColors.appleOrange, width: 3)))),
                  ),
                  Positioned(
                    top: 20, right: 20,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.appleOrange, width: 3), right: BorderSide(color: AppColors.appleOrange, width: 3)))),
                  ),
                  Positioned(
                    bottom: 20, left: 20,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.appleOrange, width: 3), left: BorderSide(color: AppColors.appleOrange, width: 3)))),
                  ),
                  Positioned(
                    bottom: 20, right: 20,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.appleOrange, width: 3), right: BorderSide(color: AppColors.appleOrange, width: 3)))),
                  ),

                  // Scanning laser line animation
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scannerAnim,
                      builder: (context, child) {
                        return Positioned(
                          top: 30 + (_scannerAnim.value * 180),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.appleOrange,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.appleOrange.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Center instructions or scanning status
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isScanning ? Icons.auto_awesome_rounded : Icons.camera_alt_rounded,
                        color: Colors.white70,
                        size: 44,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isScanning ? 'Đang phân tích món ăn bằng AI...' : 'Đưa món ăn vào khung hình',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isScanning ? 'Nhận diện nguyên liệu & tính Macro' : 'Hỗ trợ món Việt Nam, Healthy & Quốc tế',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _startAiScanSimulation,
                        icon: const Icon(Icons.camera_rounded, size: 18),
                        label: Text(_isScanning ? 'Đang quét...' : 'CHỤP ẢNH MÓN ĂN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appleOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // AI Detected Food Result Card
        if (_detectedFood != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card1 : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.appleOrange, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_detectedFood!.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.appleOrange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('AI NHẬN DIỆN 98%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.appleOrange)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(_detectedFood!.category, style: const TextStyle(fontSize: 11, color: AppColors.label2)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(_detectedFood!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        Text(
                          '+${_detectedFood!.calories * _servingCount} kcal',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.appleOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Macro breakdown
                    Row(
                      children: [
                        _MacroBadge(label: 'Protein', value: '${(_detectedFood!.protein * _servingCount).toInt()}g', color: AppColors.appleRed),
                        const SizedBox(width: 8),
                        _MacroBadge(label: 'Carbs', value: '${(_detectedFood!.carbs * _servingCount).toInt()}g', color: AppColors.appleBlue),
                        const SizedBox(width: 8),
                        _MacroBadge(label: 'Chất béo', value: '${(_detectedFood!.fat * _servingCount).toInt()}g', color: AppColors.appleYellow),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Serving count & Meal Type Selection
                    Row(
                      children: [
                        const Text('Khẩu phần:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                          onPressed: _servingCount > 1 ? () => setState(() => _servingCount--) : null,
                        ),
                        Text('$_servingCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                          onPressed: () => setState(() => _servingCount++),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _selectedMealType,
                          underline: const SizedBox(),
                          items: ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Ăn Vặt'].map((m) {
                            return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMealType = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appleOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('LƯU VÀO NHẬT KÝ ĂN UỐNG', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Food Quick Select Library
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 12),
            child: const Text('Thực Đơn Mẫu & Chọn Nhanh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
              itemCount: _foodDatabase.length,
              itemBuilder: (context, idx) {
                final item = _foodDatabase[idx];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _detectedFood = item;
                      _servingCount = 1;
                    });
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card1 : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? AppColors.separator : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('${item.calories} kcal', style: const TextStyle(fontSize: 11, color: AppColors.appleOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Today's Meals History
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 12),
            child: const Text('Bữa Ăn Hôm Nay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 100),
          sliver: health.todayMeals.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Chưa ghi nhận bữa ăn nào hôm nay\nHãy chụp ảnh món ăn đầu tiên! 🍲',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.label2, height: 1.5)),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final meal = health.todayMeals[index];
                      return Dismissible(
                        key: Key('meal_${meal.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.appleRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => health.deleteMeal(meal.id!),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.card1 : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Text(meal.photoEmoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meal.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('${meal.mealType} · ${meal.time}', style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('+${meal.calories} kcal', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.appleOrange)),
                                  Text('P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fat.toInt()}g', style: const TextStyle(fontSize: 11, color: AppColors.label3)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: health.todayMeals.length,
                  ),
                ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: content)) : content,
    );
  }
}

class _FoodItem {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String emoji;
  final String category;

  const _FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.emoji,
    required this.category,
  });
}

class _CaloriePill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _CaloriePill({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        Text(unit, style: const TextStyle(fontSize: 9, color: AppColors.label3)),
      ],
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.label2)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
