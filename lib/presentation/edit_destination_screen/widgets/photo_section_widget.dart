import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoSectionWidget extends StatelessWidget {
  final String? currentImagePath;
  final String? newImagePath;
  final bool photoRemoved;
  final Function(ImageSource) onPickImage;
  final VoidCallback onRemovePhoto;

  const PhotoSectionWidget({
    super.key,
    this.currentImagePath,
    this.newImagePath,
    required this.photoRemoved,
    required this.onPickImage,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        !photoRemoved && (newImagePath != null || currentImagePath != null);
    final displayImagePath = newImagePath ?? currentImagePath;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'photo_camera',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Destination Photo',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                hasImage
                    ? _buildImagePreview(context, theme, displayImagePath!)
                    : _buildNoImagePlaceholder(context, theme),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onPickImage(ImageSource.camera),
                        icon: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Camera',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onPickImage(ImageSource.gallery),
                        icon: CustomIconWidget(
                          iconName: 'photo_library',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Gallery',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasImage) ...[
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRemovePhoto,
                      icon: CustomIconWidget(
                        iconName: 'delete_outline',
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      label: Text(
                        'Remove Photo',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.error,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
      BuildContext context, ThemeData theme, String imagePath) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imagePath.startsWith('http')
            ? CustomImageWidget(
                imageUrl: imagePath,
                width: double.infinity,
                height: 30.h,
                fit: BoxFit.cover,
                semanticLabel: 'Current destination photo showing the location',
              )
            : Image.file(
                File(imagePath),
                width: double.infinity,
                height: 30.h,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'add_photo_alternate',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No photo selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
