import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../database/app_database.dart';
import '../core/utils/formatters.dart';

class PuceCard extends StatelessWidget {
  final AgentNumber puce;
  final bool canEdit;
  final VoidCallback? onTap;

  const PuceCard({
    super.key,
    required final this.puce,
    this.canEdit = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _parseColor(puce.color, puce.operateur.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: canEdit
                ? cardColor.withOpacity(0.4)
                : cardColor.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(LucideIcons.smartphone, color: cardColor, size: 22),
                Icon(
                  canEdit ? LucideIcons.unlock : LucideIcons.lock,
                  size: 14,
                  color: cardColor.withOpacity(0.5),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(puce.soldePuce),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: cardColor,
                  ),
                ),
                Text(
                  puce.numeroPuce,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cardColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? colorStr, String opName) {
    try {
      return Color(int.parse(colorStr ?? ""));
    } catch (_) {
      if (opName.contains('telma')) return Colors.yellow.shade800;
      if (opName.contains('orange')) return Colors.orange.shade700;
      return Colors.red.shade700;
    }
  }
}
