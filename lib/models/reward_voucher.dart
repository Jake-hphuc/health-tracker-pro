import 'package:flutter/material.dart';

class RewardVoucher {
  final String id;
  final String title;
  final String brandName;
  final String brandCategory; // 'Phòng Gym', 'Ăn uống Healthy', 'Thực phẩm bổ sung'
  final String discount;
  final int pointsCost;
  final String expiryDate;
  final String code;
  final String description;
  final String iconEmoji;
  final Color themeColor;
  final bool isRedeemed;

  const RewardVoucher({
    required this.id,
    required this.title,
    required this.brandName,
    required this.brandCategory,
    required this.discount,
    required this.pointsCost,
    required this.expiryDate,
    required this.code,
    required this.description,
    required this.iconEmoji,
    required this.themeColor,
    this.isRedeemed = false,
  });

  RewardVoucher copyWith({
    String? id,
    String? title,
    String? brandName,
    String? brandCategory,
    String? discount,
    int? pointsCost,
    String? expiryDate,
    String? code,
    String? description,
    String? iconEmoji,
    Color? themeColor,
    bool? isRedeemed,
  }) {
    return RewardVoucher(
      id: id ?? this.id,
      title: title ?? this.title,
      brandName: brandName ?? this.brandName,
      brandCategory: brandCategory ?? this.brandCategory,
      discount: discount ?? this.discount,
      pointsCost: pointsCost ?? this.pointsCost,
      expiryDate: expiryDate ?? this.expiryDate,
      code: code ?? this.code,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      themeColor: themeColor ?? this.themeColor,
      isRedeemed: isRedeemed ?? this.isRedeemed,
    );
  }
}
