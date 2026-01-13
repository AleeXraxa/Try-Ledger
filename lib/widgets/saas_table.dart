import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'custom_card.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../utils/screen_utils.dart';

class SaaSTable extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> columns;
  final List<String> columnTypes; // 'text', 'numeric', 'currency', 'balance'
  final List<Map<String, String>> rows;
  final VoidCallback? onAddPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onExportPressed;
  final Function(int)? onRowTap;
  final Function(int, String)? onActionPressed; // index, action
  final bool isLoading;
  final Function(String, bool)? onSort; // column, ascending

  const SaaSTable({
    Key? key,
    required this.title,
    this.subtitle,
    required this.columns,
    required this.columnTypes,
    required this.rows,
    this.onAddPressed,
    this.onFilterPressed,
    this.onExportPressed,
    this.onRowTap,
    this.onActionPressed,
    this.isLoading = false,
    this.onSort,
  }) : super(key: key);

  @override
  _SaaSTableState createState() => _SaaSTableState();
}

class _SaaSTableState extends State<SaaSTable> {
  int? hoveredIndex;
  String? sortColumn;
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppStyles.headingStyle.copyWith(fontSize: 24),
                ),
                if (widget.subtitle != null)
                  Text(widget.subtitle!, style: AppStyles.bodyStyle),
              ],
            ),
            Row(
              children: [
                if (widget.onFilterPressed != null)
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: widget.onFilterPressed,
                  ),
                if (widget.onExportPressed != null)
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: widget.onExportPressed,
                  ),
                if (widget.onAddPressed != null)
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add'),
                    onPressed: widget.onAddPressed,
                    style: AppStyles.primaryButtonStyle,
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),

        // Table
        Expanded(
          child: CustomCard(
            child: widget.isLoading
                ? _buildSkeleton()
                : _buildScrollableTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: List.generate(5, (index) => _buildSkeletonRow()),
        ),
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: widget.columns
            .map(
              (_) => Expanded(
                child: Container(
                  height: 16,
                  color: AppColors.neutral.withOpacity(0.2),
                  margin: EdgeInsets.only(right: 8),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
    widget.onSort?.call(column, sortAscending);
  }

  Widget _buildTableRow(int index, Map<String, String> row) {
    bool isHovered = hoveredIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: InkWell(
        onTap: () => widget.onRowTap?.call(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: AppColors.neutral.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: widget.columns.asMap().entries.map((entry) {
              int colIndex = entry.key;
              String colName = entry.value;
              String value = row[colName] ?? '';
              String type = widget.columnTypes[colIndex];
              bool isNumeric =
                  type == 'numeric' || type == 'currency' || type == 'balance';
              bool isActions = type == 'actions';
              return Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    if (!isActions)
                      Align(
                        alignment: isNumeric
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _buildCellContent(value, type),
                      ),
                    if (isActions && isHovered)
                      Positioned(
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 16),
                              onPressed: () =>
                                  widget.onActionPressed?.call(index, 'edit'),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  widget.onActionPressed?.call(index, 'delete'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(String value, String type) {
    switch (type) {
      case 'currency':
        return Text(
          value,
          style: AppStyles.bodyStyle,
          textAlign: TextAlign.right,
        );
      case 'balance':
        // Assume value is like "1000 Dr" or "500 Cr"
        List<String> parts = value.split(' ');
        String amount = parts[0];
        String label = parts.length > 1 ? parts[1] : '';
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              amount,
              style: AppStyles.bodyStyle.copyWith(
                color: label == 'Dr' ? Colors.red : Colors.green,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: AppStyles.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: label == 'Dr' ? Colors.red : Colors.green,
              ),
            ),
          ],
        );
      default:
        return Text(
          value,
          style: AppStyles.bodyStyle,
          textAlign: type == 'numeric' ? TextAlign.right : TextAlign.left,
        );
    }
  }

  Widget _buildScrollableTable() {
    if (widget.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: AppColors.neutral),
              SizedBox(height: 16),
              Text('No data available', style: AppStyles.bodyStyle),
              if (widget.onAddPressed != null) ...[
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add First Item'),
                  onPressed: widget.onAddPressed,
                  style: AppStyles.primaryButtonStyle,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _TableHeaderDelegate(
            columns: widget.columns,
            columnTypes: widget.columnTypes,
            onSort: _onSort,
            sortColumn: sortColumn,
            sortAscending: sortAscending,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            Map<String, String> row = widget.rows[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: _buildTableRow(index, row)),
              ),
            );
          }, childCount: widget.rows.length),
        ),
      ],
    );
  }

  bool _isNumeric(String s) {
    return double.tryParse(s.replaceAll(RegExp(r'[^\d.]'), '')) != null;
  }
}

class _TableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> columns;
  final List<String> columnTypes;
  final Function(String) onSort;
  final String? sortColumn;
  final bool sortAscending;

  _TableHeaderDelegate({
    required this.columns,
    required this.columnTypes,
    required this.onSort,
    required this.sortColumn,
    required this.sortAscending,
  });

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: columns.asMap().entries.map((entry) {
            int colIndex = entry.key;
            String col = entry.value;
            bool isSortable = columnTypes[colIndex] != 'actions';
            return Expanded(
              child: InkWell(
                onTap: isSortable ? () => onSort(col) : null,
                child: Row(
                  children: [
                    Text(
                      col,
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSortable) ...[
                      SizedBox(width: 4),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: sortColumn == col
                            ? Icon(
                                sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                key: ValueKey(sortAscending),
                              )
                            : Icon(
                                Icons.sort,
                                size: 16,
                                color: AppColors.neutral,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
