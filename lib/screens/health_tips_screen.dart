import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../models/health_tip.dart';
import '../utils/constants.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = ['Tất cả', 'Dinh dưỡng', 'Vận động', 'Giấc ngủ'];

  void _showTipDetail(BuildContext context, HealthTip tip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.card1 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.separator : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tip.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(tip.icon, color: tip.themeColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.category.toUpperCase(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tip.themeColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tác giả: ${tip.author}',
                              style: const TextStyle(fontSize: 12, color: AppColors.label2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    tip.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tip.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tip.summary,
                      style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('💡 Lời khuyên thực hành:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...tip.bulletPoints.map((bp) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appleGreen)),
                        Expanded(
                          child: Text(bp, style: const TextStyle(fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final challengeProv = Provider.of<ChallengeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final filteredTips = _selectedCategory == 'Tất cả'
        ? challengeProv.healthTips
        : challengeProv.healthTips.where((t) => t.category == _selectedCategory).toList();

    Widget body = CustomScrollView(
      slivers: [
        // App Bar Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mẹo Sức Khỏe 💡',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lời khuyên khoa học về dinh dưỡng, vận động & giấc ngủ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.label2 : AppColors.subtitleLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Filter Category Chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.appleGreen.withValues(alpha: 0.2),
                    backgroundColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                    checkmarkColor: AppColors.appleGreen,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.appleGreen : AppColors.label2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? AppColors.appleGreen : Colors.transparent),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Tips List
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tip = filteredTips[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: tip.themeColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showTipDetail(context, tip),
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: tip.themeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(tip.icon, color: tip.themeColor, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tip.category,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tip.themeColor),
                              ),
                              const Spacer(),
                              Text(
                                tip.readTime,
                                style: const TextStyle(fontSize: 11, color: AppColors.label2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Text(
                            tip.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            tip.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.label2, height: 1.4),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tác giả: ${tip.author}',
                                style: const TextStyle(fontSize: 11, color: AppColors.label3, fontWeight: FontWeight.w500),
                              ),
                              const Row(
                                children: [
                                  Text('Đọc ngay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appleGreen)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.appleGreen),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredTips.length,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: body,
              ),
            )
          : body,
    );
  }
}
