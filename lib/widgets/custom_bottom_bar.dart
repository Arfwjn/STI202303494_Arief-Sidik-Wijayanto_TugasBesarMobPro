import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom bottom navigation bar for Travvel app
/// Implements bottom-heavy design strategy with three primary navigation items
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int> onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      // Haptic feedback for navigation
      HapticFeedback.lightImpact();
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return Container(
      decoration: BoxDecoration(
        color: bottomNavTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.add_circle_outline,
                activeIcon: Icons.add_circle,
                label: 'Add',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final bottomNavTheme = theme.bottomNavigationBarTheme;
    final isSelected = widget.currentIndex == index;
    final color = isSelected
        ? bottomNavTheme.selectedItemColor
        : bottomNavTheme.unselectedItemColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(index),
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = isSelected && _previousIndex == index
                  ? _scaleAnimation.value
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey<bool>(isSelected),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: (isSelected
                            ? bottomNavTheme.selectedLabelStyle
                            : bottomNavTheme.unselectedLabelStyle)!
                        .copyWith(
                      color: color,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to provide navigation functionality
extension CustomBottomBarNavigation on CustomBottomBar {
  /// Navigate to the appropriate screen based on index
  /// FIXED: Gunakan pushNamed alih-alih pushReplacementNamed untuk menjaga navigation stack
  static void navigateToIndex(BuildContext context, int index) {
    // Check if already on the target screen
    final currentRoute = ModalRoute.of(context)?.settings.name;

    String targetRoute;
    switch (index) {
      case 0:
        targetRoute = '/home-screen';
        break;
      case 1:
        targetRoute = '/add-destination-screen';
        break;
      case 2:
        targetRoute = '/map-view-screen';
        break;
      default:
        return;
    }

    // Only navigate if not already on the target screen
    if (currentRoute != targetRoute) {
      // For Add Destination, use regular push to maintain stack
      if (index == 1) {
        Navigator.pushNamed(context, targetRoute);
      } else {
        // For Home and Map, use pushReplacementNamed to avoid stack buildup
        Navigator.pushReplacementNamed(context, targetRoute);
      }
    }
  }
}
