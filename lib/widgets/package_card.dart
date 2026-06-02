import 'package:flutter/material.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/models/package.dart';
import 'package:moscow_store/models/account.dart';

class PackageCard extends StatelessWidget {
  final dynamic item;
  final bool isAccount;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.item,
    this.isAccount = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double price = isAccount
        ? (item as GameAccount).price
        : (item as GamePackage).price;
    final double? originalPrice = isAccount
        ? (item as GameAccount).originalPrice
        : (item as GamePackage).originalPrice;
    final bool hasDiscount = originalPrice != null && originalPrice > price;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAccount
                        ? (item as GameAccount).title
                        : (item as GamePackage).name,
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isAccount && (item as GamePackage).amount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        (item as GamePackage).amount!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (isAccount && (item as GameAccount).rank != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        (item as GameAccount).rank!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount)
                  Text(
                    '$originalPrice ج',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '$price ج',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'اطلب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
