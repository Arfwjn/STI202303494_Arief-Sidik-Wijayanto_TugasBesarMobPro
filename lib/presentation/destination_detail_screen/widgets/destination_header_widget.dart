import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Hero header widget displaying destination image with gradient overlay
class DestinationHeaderWidget extends StatelessWidget {
  final String imageUrl;
  final String semanticLabel;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DestinationHeaderWidget({
    super.key,
    required this.imageUrl,
    required this.semanticLabel,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          Hero(
            tag: 'destination_image_$imageUrl',
            child: CustomImageWidget(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 40.h,
              fit: BoxFit.cover,
              semanticLabel: semanticLabel,
            ),
          ),

          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Top action buttons
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onBack();
                      },
                      tooltip: 'Back',
                    ),
                  ),

                  // Actions menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: Colors.white,
                        size: 24,
                      ),
                      color: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        HapticFeedback.lightImpact();
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'edit',
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Edit',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'delete',
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Delete',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
