import 'package:flutter/widgets.dart';

import '../design/tokens.dart';
import 'icons.dart';

/// SearchField — 364 × 48, card fill, 1px border, 12 radius, icon + hint.
class DsSearchField extends StatelessWidget {
  const DsSearchField({
    super.key,
    required this.colors,
    this.hint = 'Search customers…',
    this.width = 364,
    this.onTap,
  });

  final DsColors colors;
  final String hint;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(DsRadius.md)),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.md), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            DsGlyph('search', color: colors.mutedFg, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: DsType.body.copyWith(color: colors.mutedFg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One filter chip — 34 high, 14 horizontal padding, 16 radius.
class DsFilterChip extends StatelessWidget {
  const DsFilterChip({
    super.key,
    required this.colors,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final DsColors colors;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.card,
          border: selected ? null : Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: DsType.captionStrong.copyWith(
            color: selected ? colors.onPrimary : colors.mutedFg,
          ),
        ),
      ),
    );
  }
}

/// FilterChips group — 8px gap between chips.
class DsFilterChipBar extends StatelessWidget {
  const DsFilterChipBar({
    super.key,
    required this.colors,
    required this.labels,
    required this.selectedIndex,
    this.onSelect,
  });

  final DsColors colors;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          DsFilterChip(
            colors: colors,
            label: labels[i],
            selected: i == selectedIndex,
            onTap: onSelect == null ? null : () => onSelect!(i),
          ),
        ],
      ],
    );
  }
}

/// TextField — label (12/600 muted) + 48 input, 8 gap.
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.colors,
    required this.label,
    this.value = '',
    this.hint = '请输入',
    this.error,
    this.width = 328,
    this.focused = false,
  });

  final DsColors colors;
  final String label;
  final String value;
  final String hint;
  final String? error;
  final double width;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DsType.captionStrong.copyWith(color: colors.mutedFg)),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(DsRadius.md),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DsRadius.md),
              border: Border.all(
                color: hasError
                    ? colors.destructive
                    : (focused ? colors.primary : colors.border),
              ),
            ),
            child: Text(
              value.isEmpty ? hint : value,
              style: DsType.body.copyWith(
                color: value.isEmpty ? colors.mutedFg : colors.fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum DsButtonVariant { primary, secondary, danger }

/// Button — min height 48, 20/12 padding, 12 radius, 14/600 label.
class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.colors,
    required this.label,
    this.variant = DsButtonVariant.primary,
    this.width,
    this.onTap,
  });

  final DsColors colors;
  final String label;
  final DsButtonVariant variant;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (variant) {
      DsButtonVariant.primary => (colors.primary, null, colors.onPrimary),
      DsButtonVariant.secondary => (colors.card, colors.border, colors.fg),
      DsButtonVariant.danger => (colors.destructive, null, colors.onPrimary),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: border == null ? null : Border.all(color: border),
          borderRadius: BorderRadius.circular(DsRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: DsType.body.copyWith(
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
