import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../l10n/app_localizations.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _busNumberController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Service';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Service',
    'Cleanliness',
    'Staff Behavior',
    'Safety',
    'Route Issues',
    'Fare Issues',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _busNumberController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.report_problem,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.submitComplaintTitle ?? 'Submit a Complaint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)?.helpImproveServices ?? 'Help us improve our services by reporting issues',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Complaint Form
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection
                      Text(
                        AppLocalizations.of(context)?.category ?? 'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      Text(
                        AppLocalizations.of(context)?.yourName ?? 'Your Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.enterFullName ?? 'Enter your full name',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            size: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number Field
                      Text(
                        AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.enter10DigitMobile ?? 'Enter 10-digit mobile number',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.phone,
                            size: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bus Number
                      Text(
                        AppLocalizations.of(context)?.busNumber ?? 'Bus Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _busNumberController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.busNumberExample ?? 'e.g., 101, 205A',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.directions_bus,
                            size: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the bus number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject
                      Text(
                        AppLocalizations.of(context)?.subject ?? 'Subject',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.briefDescription ?? 'Brief description of the issue',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        AppLocalizations.of(context)?.description ?? 'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.provideDetailedInfo ?? 'Provide detailed information about the issue...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a description';
                          }
                          if (value.length < 10) {
                            return 'Description must be at least 10 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)?.submitComplaint ?? 'Submit Complaint',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();
      final complaintData = {
        'category': _selectedCategory,
        'busNumber': _busNumberController.text.trim(),
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'Pending',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await apiService.post(ApiConfig.complaints, data: complaintData);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _busNumberController.clear();
        _subjectController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = 'Service';
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to submit complaint');
      }
    } catch (e) {
      print('Error submitting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit complaint: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}