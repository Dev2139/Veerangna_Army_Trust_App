import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glassy_background.dart';
import '../../core/widgets/glassy_container.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';

class BillingInfoScreen extends StatefulWidget {
  final UserModel user;

  const BillingInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<BillingInfoScreen> createState() => _BillingInfoScreenState();
}

class _BillingInfoScreenState extends State<BillingInfoScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _street1Controller;
  late TextEditingController _street2Controller;
  late TextEditingController _street3Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _panController;

  late String _howHeard;
  late bool _keepUpdated;
  late bool _donateAnonymously;

  @override
  void initState() {
    super.initState();
    final info = widget.user.billingInfo;
    
    // Split full name if billing name is empty as fallback
    String initFirst = info.firstName;
    String initLast = info.lastName;
    if (initFirst.isEmpty && initLast.isEmpty && widget.user.name.isNotEmpty) {
      final parts = widget.user.name.split(' ');
      initFirst = parts.first;
      if (parts.length > 1) {
        initLast = parts.sublist(1).join(' ');
      }
    }

    _firstNameController = TextEditingController(text: initFirst);
    _lastNameController = TextEditingController(text: initLast);
    _street1Controller = TextEditingController(text: info.street1);
    _street2Controller = TextEditingController(text: info.street2);
    _street3Controller = TextEditingController(text: info.street3);
    _cityController = TextEditingController(text: info.city);
    _stateController = TextEditingController(text: info.state);
    _zipController = TextEditingController(text: info.zipCode);
    _countryController = TextEditingController(text: info.country.isEmpty ? 'United States' : info.country);
    _panController = TextEditingController(text: info.panCard);

    _howHeard = info.howHeard.isEmpty ? 'Please select one' : info.howHeard;
    _keepUpdated = info.keepUpdated;
    _donateAnonymously = info.donateAnonymously;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _street1Controller.dispose();
    _street2Controller.dispose();
    _street3Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _street1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _zipController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields (*)')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    final billingInfo = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'street1': _street1Controller.text.trim(),
      'street2': _street2Controller.text.trim(),
      'street3': _street3Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipController.text.trim(),
      'country': _countryController.text.trim(),
      'panCard': _panController.text.trim(),
      'howHeard': _howHeard == 'Please select one' ? '' : _howHeard,
      'keepUpdated': _keepUpdated,
      'donateAnonymously': _donateAnonymously,
    };

    // Update name to reflect changes in billing first/last name
    final newFullName = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

    final updated = await _apiService.updateProfile(
      name: newFullName,
      billingInfo: billingInfo,
    );

    setState(() { _isSaving = false; });

    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Billing information updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update billing info. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: AppColors.textDarkBlue, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Billing Information', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: GlassyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                
                // Form Card
                GlassyContainer(
                  padding: const EdgeInsets.all(20.0),
                  opacity: 0.12,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Edit Billing Address',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 16),

                      // First & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person_outline,
                              required: true,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person_outline,
                              required: true,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 14),

                      // Street 1
                      _buildTextField(
                        controller: _street1Controller,
                        label: 'Street 1',
                        icon: Icons.home_outlined,
                        required: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // Street 2
                      _buildTextField(
                        controller: _street2Controller,
                        label: 'Street 2',
                        icon: Icons.home_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // Street 3
                      _buildTextField(
                        controller: _street3Controller,
                        label: 'Street 3',
                        icon: Icons.home_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // City
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        required: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // State/Province
                      _buildTextField(
                        controller: _stateController,
                        label: 'State/Province',
                        icon: Icons.map_outlined,
                        required: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // ZIP Code
                      _buildTextField(
                        controller: _zipController,
                        label: 'ZIP/Postal Code',
                        icon: Icons.pin_drop_outlined,
                        required: true,
                      ),
                      
                      const SizedBox(height: 14),

                      // Country
                      _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        icon: Icons.public_outlined,
                        required: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                      
                      const SizedBox(height: 14),

                      // PAN Card
                      _buildTextField(
                        controller: _panController,
                        label: 'PAN Card (For Indian 80G tax benefit)',
                        icon: Icons.badge_outlined,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      
                      const SizedBox(height: 14),

                      // How did you hear about Seva Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _howHeard,
                            decoration: const InputDecoration(
                              labelText: 'How did you hear about Seva?',
                              labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.question_answer_outlined, color: AppColors.primaryBlue),
                            ),
                            style: const TextStyle(color: AppColors.textDarkBlue, fontWeight: FontWeight.w600, fontSize: 14),
                            items: <String>[
                              'Please select one',
                              'Friend/Family',
                              'Social Media',
                              'Search Engine',
                              'Advertisement',
                              'Other'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _howHeard = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),

                      // Keep me updated checkbox
                      CheckboxListTile(
                        title: const Text(
                          'Please keep me updated on how my donation is helping to make a difference',
                          style: TextStyle(fontSize: 12, color: AppColors.textDarkBlue, fontWeight: FontWeight.w500),
                        ),
                        value: _keepUpdated,
                        activeColor: AppColors.primaryBlue,
                        checkColor: Colors.white,
                        onChanged: (val) {
                          setState(() {
                            _keepUpdated = val ?? true;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // Donate anonymously checkbox
                      CheckboxListTile(
                        title: const Text(
                          'Yes, I would like to make this donation anonymously',
                          style: TextStyle(fontSize: 12, color: AppColors.textDarkBlue, fontWeight: FontWeight.w500),
                        ),
                        value: _donateAnonymously,
                        activeColor: AppColors.primaryBlue,
                        checkColor: Colors.white,
                        onChanged: (val) {
                          setState(() {
                            _donateAnonymously = val ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Changes Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffron,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: AppColors.saffron.withOpacity(0.3),
                        ),
                        child: _isSaving 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ) 
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
