import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/coordinates_section_widget.dart';
import './widgets/form_fields_widget.dart';
import './widgets/photo_section_widget.dart';

class EditDestinationScreen extends StatefulWidget {
  final Map<String, dynamic> destination;

  const EditDestinationScreen({
    super.key,
    required this.destination,
  });

  @override
  State<EditDestinationScreen> createState() => _EditDestinationScreenState();
}

class _EditDestinationScreenState extends State<EditDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  String? _currentImagePath;
  String? _newImagePath;
  bool _hasChanges = false;
  bool _isUpdating = false;
  bool _photoRemoved = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    _nameController.text = widget.destination['name'] ?? '';
    _descriptionController.text = widget.destination['description'] ?? '';
    _latitudeController.text = widget.destination['latitude']?.toString() ?? '';
    _longitudeController.text =
        widget.destination['longitude']?.toString() ?? '';
    _currentImagePath = widget.destination['imagePath'];

    if (widget.destination['openingTime'] != null) {
      final openingParts =
          (widget.destination['openingTime'] as String).split(':');
      _openingTime = TimeOfDay(
        hour: int.parse(openingParts[0]),
        minute: int.parse(openingParts[1]),
      );
    }

    if (widget.destination['closingTime'] != null) {
      final closingParts =
          (widget.destination['closingTime'] as String).split(':');
      _closingTime = TimeOfDay(
        hour: int.parse(closingParts[0]),
        minute: int.parse(closingParts[1]),
      );
    }

    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _latitudeController.addListener(_onFormChanged);
    _longitudeController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? (_openingTime ?? TimeOfDay.now())
          : (_closingTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.colorScheme.primaryContainer,
              hourMinuteTextColor: theme.colorScheme.onPrimaryContainer,
              dialHandColor: theme.colorScheme.primary,
              dialBackgroundColor: theme.colorScheme.surface,
              hourMinuteColor: theme.colorScheme.surface,
              dayPeriodTextColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final shouldReplace = await _showReplacePhotoDialog();
        if (shouldReplace == true) {
          setState(() {
            _newImagePath = image.path;
            _photoRemoved = false;
            _hasChanges = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showReplacePhotoDialog() async {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          'Replace Photo',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Do you want to replace the existing photo?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _photoRemoved = true;
      _newImagePath = null;
      _hasChanges = true;
    });
  }

  Future<void> _updateLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _hasChanges = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location updated successfully',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get location: ${e.toString()}');
    }
  }

  Future<void> _updateDestination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedDestination = {
        'id': widget.destination['id'],
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
        'openingTime': _openingTime != null
            ? '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'closingTime': _closingTime != null
            ? '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'imagePath':
            _photoRemoved ? null : (_newImagePath ?? _currentImagePath),
      };

      if (mounted) {
        Navigator.pop(context, updatedDestination);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Destination updated successfully',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      _showErrorSnackBar('Failed to update destination: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final theme = Theme.of(context);
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          'Discard Changes?',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Edit Destination',
          variant: CustomAppBarVariant.withBack,
          actions: [
            TextButton(
              onPressed:
                  _hasChanges && !_isUpdating ? _updateDestination : null,
              child: _isUpdating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Update',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _hasChanges
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhotoSectionWidget(
                      currentImagePath: _currentImagePath,
                      newImagePath: _newImagePath,
                      photoRemoved: _photoRemoved,
                      onPickImage: _pickImage,
                      onRemovePhoto: _removePhoto,
                    ),
                    SizedBox(height: 3.h),
                    FormFieldsWidget(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      openingTime: _openingTime,
                      closingTime: _closingTime,
                      onSelectTime: _selectTime,
                    ),
                    SizedBox(height: 3.h),
                    CoordinatesSectionWidget(
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                      onUpdateLocation: _updateLocation,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
