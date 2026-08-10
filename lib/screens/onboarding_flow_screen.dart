import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final bool isEditMode;
  const OnboardingFlowScreen({super.key, this.isEditMode = false});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0;

  // Step 1 Data
  late TextEditingController _nameController;
  DateTime _dateOfBirth = DateTime(2000, 1, 1);
  String _gender = 'Nam';

  // Step 2 Data
  double _height = 170.0;
  double _weight = 65.0;

  // Step 3 Data
  int _stepGoal = 10000;
  int _waterGoal = 2000;
  double _sleepGoal = 8.0;
  int _exerciseGoal = 30;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final health = Provider.of<HealthProvider>(context, listen: false);

    _nameController = TextEditingController(
      text: auth.currentUser?.name ?? 'Người dùng Pro',
    );

    if (auth.currentUser != null) {
      _height = auth.currentUser!.height;
    }
    if (health.goal.waterGoal > 0) {
      _waterGoal = health.goal.waterGoal;
      _sleepGoal = health.goal.sleepGoal;
      _exerciseGoal = health.goal.activityGoal;
    }
    if (health.latestWeight != null) {
      _weight = health.latestWeight!.weight;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập họ và tên của bạn'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _finishSetup() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final health = Provider.of<HealthProvider>(context, listen: false);

    // Save goals to HealthProvider
    health.updateGoal(
      waterGoal: _waterGoal,
      sleepGoal: _sleepGoal,
      activityGoal: _exerciseGoal,
    );

    // Save weight if updated
    if (auth.currentUser?.id != null) {
      health.addWeight(_weight, _height);
    }

    if (widget.isEditMode) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final progress = (_currentStep + 1) / 4.0;

    Widget currentStepWidget;
    switch (_currentStep) {
      case 0:
        currentStepWidget = _buildStep1PersonalDetails(isDark);
        break;
      case 1:
        currentStepWidget = _buildStep2BodyMetrics(isDark);
        break;
      case 2:
        currentStepWidget = _buildStep3HealthGoals(isDark);
        break;
      case 3:
      default:
        currentStepWidget = _buildStep4Summary(isDark);
        break;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _prevStep,
              )
            : (widget.isEditMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  )
                : null),
        title: Text(
          'Thiết lập Hồ sơ (${_currentStep + 1}/4)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Smooth Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.card2 : Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.appleGreen),
                ),
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isWide
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: currentStepWidget,
                        ),
                      )
                    : currentStepWidget,
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: isWide
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _buildBottomButtons(),
                      ),
                    )
                  : _buildBottomButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (_currentStep == 3) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _finishSetup,
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text(
            'Start Tracking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appleGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.label2.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Quay lại', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tiếp tục', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Personal Details
  // ---------------------------------------------------------------------------
  Widget _buildStep1PersonalDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hồ sơ cá nhân 👤',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hãy cho chúng tôi biết một chút về bản thân bạn',
          style: TextStyle(fontSize: 14, color: AppColors.label2),
        ),
        const SizedBox(height: 32),

        // Full Name Field
        const Text('1. Họ và tên', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Nhập họ tên đầy đủ',
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.appleBlue),
          ),
        ),
        const SizedBox(height: 24),

        // Date of Birth Field
        const Text('2. Ngày sinh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth,
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
              builder: (ctx, child) {
                return Theme(
                  data: isDark ? ThemeData.dark() : ThemeData.light(),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _dateOfBirth = picked);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.applePurple, size: 20),
                const SizedBox(width: 14),
                Text(
                  DateFormat('dd/MM/yyyy').format(_dateOfBirth),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Text('Thay đổi', style: TextStyle(fontSize: 12, color: AppColors.appleBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Gender Selection Cards
        const Text('3. Giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _GenderCard(
              label: 'Nam 👨',
              isSelected: _gender == 'Nam',
              onTap: () => setState(() => _gender = 'Nam'),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _GenderCard(
              label: 'Nữ 👩',
              isSelected: _gender == 'Nữ',
              onTap: () => setState(() => _gender = 'Nữ'),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _GenderCard(
              label: 'Khác ⚧',
              isSelected: _gender == 'Khác',
              onTap: () => setState(() => _gender = 'Khác'),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Body Metrics
  // ---------------------------------------------------------------------------
  Widget _buildStep2BodyMetrics(bool isDark) {
    final bmi = _weight / ((_height / 100) * (_height / 100));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chỉ số cơ thể 📏',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Để ứng dụng tính toán chỉ số BMI và năng lượng chuẩn xác',
          style: TextStyle(fontSize: 14, color: AppColors.label2),
        ),
        const SizedBox(height: 28),

        // Height Card & Slider
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card1 : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chiều cao', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '${_height.round()} cm',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.appleBlue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _height,
                min: 120,
                max: 220,
                activeColor: AppColors.appleBlue,
                inactiveColor: isDark ? AppColors.card2 : Colors.grey.shade300,
                onChanged: (val) => setState(() => _height = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Weight Card & Slider
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card1 : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cân nặng hiện tại', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '${_weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.appleOrange),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _weight,
                min: 30,
                max: 180,
                activeColor: AppColors.appleOrange,
                inactiveColor: isDark ? AppColors.card2 : Colors.grey.shade300,
                onChanged: (val) => setState(() => _weight = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Calculated BMI Preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.getBMIColor(bmi).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants.getBMIColor(bmi).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chỉ số BMI dự kiến', style: TextStyle(fontSize: 12, color: AppColors.label2)),
                  const SizedBox(height: 2),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppConstants.getBMIColor(bmi)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.getBMIColor(bmi),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppConstants.getBMICategory(bmi),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Daily Health Goals
  // ---------------------------------------------------------------------------
  Widget _buildStep3HealthGoals(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mục tiêu hàng ngày 🎯',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tùy chỉnh các chỉ số bạn muốn hoàn thành mỗi ngày',
          style: TextStyle(fontSize: 14, color: AppColors.label2),
        ),
        const SizedBox(height: 24),

        // Step Goal Slider
        _GoalSliderCard(
          title: 'Daily Step Goal (Bước chân)',
          valueText: '$_stepGoal bước',
          value: _stepGoal.toDouble(),
          min: 3000,
          max: 25000,
          divisions: 44,
          color: AppColors.appleGreen,
          isDark: isDark,
          onChanged: (val) => setState(() => _stepGoal = val.round()),
        ),
        const SizedBox(height: 14),

        // Water Goal Slider
        _GoalSliderCard(
          title: 'Daily Water Goal (Nước uống)',
          valueText: '$_waterGoal ml',
          value: _waterGoal.toDouble(),
          min: 1000,
          max: 4000,
          divisions: 30,
          color: AppColors.appleBlue,
          isDark: isDark,
          onChanged: (val) => setState(() => _waterGoal = val.round()),
        ),
        const SizedBox(height: 14),

        // Sleep Goal Slider
        _GoalSliderCard(
          title: 'Sleep Goal (Giấc ngủ)',
          valueText: '${_sleepGoal.toStringAsFixed(1)} giờ',
          value: _sleepGoal,
          min: 5.0,
          max: 12.0,
          divisions: 14,
          color: AppColors.applePurple,
          isDark: isDark,
          onChanged: (val) => setState(() => _sleepGoal = val),
        ),
        const SizedBox(height: 14),

        // Exercise Goal Slider
        _GoalSliderCard(
          title: 'Daily Exercise Goal (Vận động)',
          valueText: '$_exerciseGoal phút',
          value: _exerciseGoal.toDouble(),
          min: 10,
          max: 120,
          divisions: 22,
          color: AppColors.appleRed,
          isDark: isDark,
          onChanged: (val) => setState(() => _exerciseGoal = val.round()),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: Summary & Ready
  // ---------------------------------------------------------------------------
  Widget _buildStep4Summary(bool isDark) {
    final cardBg = isDark ? AppColors.card1 : Colors.white;
    final bmi = _weight / ((_height / 100) * (_height / 100));

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.appleGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.appleGreen, size: 54),
        ),
        const SizedBox(height: 20),

        const Text(
          'Your health profile is ready',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hồ sơ sức khỏe của bạn đã sẵn sàng hoạt động!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.label2),
        ),
        const SizedBox(height: 28),

        // Summary Card: Personal & Body Metrics
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📋 Thông tin cá nhân', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              _SummaryRow(label: 'Họ và tên', value: _nameController.text.trim()),
              _SummaryRow(label: 'Ngày sinh', value: DateFormat('dd/MM/yyyy').format(_dateOfBirth)),
              _SummaryRow(label: 'Giới tính', value: _gender),
              _SummaryRow(label: 'Chiều cao', value: '${_height.round()} cm'),
              _SummaryRow(label: 'Cân nặng', value: '${_weight.toStringAsFixed(1)} kg'),
              _SummaryRow(
                label: 'Chỉ số BMI',
                value: '${bmi.toStringAsFixed(1)} (${AppConstants.getBMICategory(bmi)})',
                valueColor: AppConstants.getBMIColor(bmi),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Summary Card: Goals
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎯 Mục tiêu hàng ngày', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              _SummaryRow(label: 'Mục tiêu bước chân', value: '$_stepGoal bước', valueColor: AppColors.appleGreen),
              _SummaryRow(label: 'Mục tiêu nước uống', value: '$_waterGoal ml', valueColor: AppColors.appleBlue),
              _SummaryRow(label: 'Mục tiêu giấc ngủ', value: '${_sleepGoal.toStringAsFixed(1)} giờ', valueColor: AppColors.applePurple),
              _SummaryRow(label: 'Mục tiêu vận động', value: '$_exerciseGoal phút', valueColor: AppColors.appleRed),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _GenderCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.appleBlue.withValues(alpha: 0.2)
                : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.appleBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.appleBlue : AppColors.label2,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalSliderCard extends StatelessWidget {
  final String title;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _GoalSliderCard({
    required this.title,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card1 : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.label2)),
              Text(
                valueText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: isDark ? AppColors.card2 : Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.label2)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
