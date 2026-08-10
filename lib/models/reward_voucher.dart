import 'package:flutter/material.dart';

class RewardVoucher {
  final String id;
  final String title;
  final String partnerName;
  final String category; // 'Phòng Gym 🏋️', 'Ăn uống Healthy 🥗', 'Spa & Y tế 🩺'
  final int pointsCost;
  final String discountText;
  final String description;
  final IconData icon;
  final Color themeColor;
  final String voucherCode;
  bool isRedeemed;

  RewardVoucher({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.category,
    required this.pointsCost,
    required this.discountText,
    required this.description,
    required this.icon,
    required this.themeColor,
    required this.voucherCode,
    this.isRedeemed = false,
  });
}
