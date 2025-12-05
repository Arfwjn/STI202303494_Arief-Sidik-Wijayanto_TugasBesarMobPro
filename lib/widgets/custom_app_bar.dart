import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CustomAppBar
enum CustomAppBarVariant {
  /// Standard app bar with title
  standard,

  /// App bar with search functionality
  search,

  /// App bar with back button
  withBack,

  /// App bar with actions only
  actionsOnly,

  /// Transparent app bar for overlay
  transparent,
}

/// Custom app bar untuk aplikasi Travvel
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text
  final String? title;

  /// Leading widget
  final Widget? leading;

  /// Action widgets
  final List<Widget>? actions;

  /// Variant of the app bar
  final CustomAppBarVariant variant;

  /// Show back button automatically
  final bool automaticallyImplyLeading;

  /// Callback for search functionality
  final ValueChanged<String>? onSearch;

  /// Initial search query
  final String? searchQuery;

  /// Center the title
  final bool centerTitle;

  /// Custom bottom widget
  final PreferredSizeWidget? bottom;

  /// Background color override
  final Color? backgroundColor;

  /// Elevation override
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.variant = CustomAppBarVariant.standard,
    this.automaticallyImplyLeading = true,
    this.onSearch,
    this.searchQuery,
    this.centerTitle = false,
    this.bottom,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    switch (variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, appBarTheme);
      case CustomAppBarVariant.transparent:
        return _buildTransparentAppBar(context, theme, appBarTheme);
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.withBack:
      case CustomAppBarVariant.actionsOnly:
        return _buildStandardAppBar(context, theme, appBarTheme);
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    AppBarTheme appBarTheme,
  ) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: appBarTheme.titleTextStyle,
            )
          : null,
      leading: leading ??
          (automaticallyImplyLeading ? _buildLeading(context) : null),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: appBarTheme.foregroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      bottom: bottom,
    );
  }

  Widget _buildSearchAppBar(
    BuildContext context,
    ThemeData theme,
    AppBarTheme appBarTheme,
  ) {
    return AppBar(
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: TextField(
          controller: TextEditingController(text: searchQuery),
          onChanged: onSearch,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search destinations...',
            hintStyle: theme.inputDecorationTheme.hintStyle,
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: searchQuery != null && searchQuery!.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      if (onSearch != null) {
                        onSearch!('');
                      }
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
      ),
      leading: leading ?? _buildLeading(context),
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: appBarTheme.foregroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      bottom: bottom,
    );
  }

  Widget _buildTransparentAppBar(
    BuildContext context,
    ThemeData theme,
    AppBarTheme appBarTheme,
  ) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: appBarTheme.titleTextStyle,
            )
          : null,
      leading: leading ?? _buildLeading(context),
      actions: actions != null
          ? [
              ...actions!.map((action) => Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: action,
                  )),
              const SizedBox(width: 8),
            ]
          : null,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      foregroundColor: appBarTheme.foregroundColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop && variant != CustomAppBarVariant.withBack) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      tooltip: 'Back',
    );
  }
}

/// Action button for app bar
class CustomAppBarAction extends StatelessWidget {
  /// Icon display
  final IconData icon;

  /// Callback
  final VoidCallback onPressed;

  /// Tooltip text
  final String? tooltip;

  /// Show badge
  final bool showBadge;

  /// Badge count
  final int? badgeCount;

  const CustomAppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.showBadge = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget iconButton = IconButton(
      icon: Icon(icon),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      tooltip: tooltip,
    );

    if (showBadge) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          iconButton,
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : badgeCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    return iconButton;
  }
}
