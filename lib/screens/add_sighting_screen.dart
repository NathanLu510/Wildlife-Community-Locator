// Add sighting screen form for users to fill in details of their animal sighting
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../models/species.dart';
import '../models/sighting.dart';

import '../data/sample_species.dart';
import '../utils/category_style.dart';
import 'location_picker.dart';
import '../services/taiwan_regions.dart';

import 'dart:io';



class AddSightingScreen extends StatefulWidget {

  final ValueChanged<Sighting> onSightingAdded;

  const AddSightingScreen({
    super.key,
    required this.onSightingAdded,
    });

  @override
  State<AddSightingScreen> createState() => _AddSightingScreenState();
}

// Stateful widget to store user inputs from form
class _AddSightingScreenState extends State<AddSightingScreen> {
  final _formKey = GlobalKey<FormState>();

  Species? selectedSpecies;

  final descriptionController = TextEditingController();

  DateTime observedAt = DateTime.now();

  LatLng? selectedLocation;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? selectedImage;
  bool isPickingImage = false;

  bool isSubmitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // Helpers
  Future<void> _chooseLocation() async {
    final location = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: selectedLocation,
        ),
      ),
    );

    if (!mounted || location == null) return;

    setState(() {
      selectedLocation = location;
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: observedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(observedAt),
    );

    if (time == null || !mounted) return;

    setState(() {
      observedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  
  Future<void> _submitSighting() async {
    if (isSubmitting) return;

    // 1. Validate form fields.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedSpecies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a species.'),
        ),
      );
      return;
    }

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sighting location.'),
        ),
      );
      return;
    }

    if (observedAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Observation date cannot be in the future.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // 2. Determine the Taiwan county.
      final regionId =
          await TaiwanRegions.findRegionForLocation(
        selectedLocation!,
      );

      if (!mounted) return;

      if (regionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a location within Taiwan.',
            ),
          ),
        );
        return;
      }

      // 3. Save the optional photograph.
      final imagePath = await _saveSelectedImage();

      if (!mounted) return;

      // 4. Construct the new sighting.
      final newSighting = Sighting(
        id: 'sighting_${DateTime.now().microsecondsSinceEpoch}',
        speciesName: selectedSpecies!.commonName,
        latitude: selectedLocation!.latitude,
        longitude: selectedLocation!.longitude,
        regionId: regionId,
        observedAt: observedAt,
        description: descriptionController.text.trim(),
        imagePath: imagePath,
      );

      // 5. Send the sighting to MainScreen.
      widget.onSightingAdded(newSighting);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit sighting: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isPickingImage) return;

    setState(() => isPickingImage = true);

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => isPickingImage = false);
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  // Copies the image from the temporary picker location into  app's private storage.
  Future<String?> _saveSelectedImage() async {
    if (selectedImage == null) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}sighting_images',
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final imageId = DateTime.now().microsecondsSinceEpoch;

    final originalPath = selectedImage!.path;

    final extension = originalPath.contains('.')
        ? originalPath.substring(originalPath.lastIndexOf('.')).toLowerCase()
        : '.jpg';

    final savedPath =
        '${imagesDirectory.path}${Platform.pathSeparator}$imageId$extension';

    final savedImage = await File(
      selectedImage!.path,
    ).copy(savedPath);

    return savedImage.path;
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Add Wildlife Sighting',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            const Text(
              'Share a wildlife observation with the community.',
            ),

            const SizedBox(height: 24),

            // Species selection, change to smart selection or add new species
            DropdownButtonFormField<Species>(
              initialValue: selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
              items: sampleSpecies.map((species) {
                return DropdownMenuItem(
                  value: species,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CategoryStyle.icon(species.category),
                        color: CategoryStyle.color(species.category),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(species.commonName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (species) {
                setState(() {
                  selectedSpecies = species;
                });
              },
              validator: (species) =>
                  species == null ? 'Please select a species' : null,
            ),

            const SizedBox(height: 16),

            // Location Selector with flutter_map
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  selectedLocation == null
                      ? 'Select Sighting Location'
                      : 'Location Selected',
                ),
                subtitle: Text(
                  selectedLocation == null
                      ? 'Use GPS or choose a point on the map'
                      : '${selectedLocation!.latitude.toStringAsFixed(5)}, '
                        '${selectedLocation!.longitude.toStringAsFixed(5)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _chooseLocation,
              ),
            ),

            const SizedBox(height: 16),

            // Wildlife photograph
            Text(
              'Wildlife Photograph (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            if (selectedImage == null)
              OutlinedButton.icon(
                onPressed: isPickingImage ? null : _showImageOptions,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Attach Photograph'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImage!.path),
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              isPickingImage ? null : _showImageOptions,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Replace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove photograph',
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Observation date and time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Observation date and time'),
              subtitle: Text(
                '${observedAt.day}/${observedAt.month}/${observedAt.year} '
                '${TimeOfDay.fromDateTime(observedAt).format(context)}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: _selectDateTime,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe what you observed...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: isSubmitting ? null : _submitSighting,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_location_alt),
              label: Text(
                isSubmitting ? 'Submitting...' : 'Submit Sighting',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
