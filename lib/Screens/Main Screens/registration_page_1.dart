import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'registration_page_2.dart';

class RegistrationScreen1 extends StatefulWidget {
  const RegistrationScreen1({super.key});

  @override
  State<RegistrationScreen1> createState() => _RegistrationScreen1State();
}

class _RegistrationScreen1State extends State<RegistrationScreen1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _provinceFocusNode = FocusNode();
  final FocusNode _districtFocusNode = FocusNode();
  final FocusNode _councilFocusNode = FocusNode();

  // Location selection variables
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCouncil;

  // Lists for dropdowns
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _localAuthorities = [];
  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeFocusListeners();
    _loadProvinces();
  }

  void _initializeFocusListeners() {
    _firstNameFocusNode.addListener(() => setState(() {}));
    _lastNameFocusNode.addListener(() => setState(() {}));
    _idFocusNode.addListener(() => setState(() {}));
    _phoneFocusNode.addListener(() => setState(() {}));
    _addressFocusNode.addListener(() => setState(() {}));
    _provinceFocusNode.addListener(() => setState(() {}));
    _districtFocusNode.addListener(() => setState(() {}));
    _councilFocusNode.addListener(() => setState(() {}));
  }

  Future<void> _loadProvinces() async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase.from('provinces').select().order('name');

      setState(() {
        _provinces = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load provinces: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('districts')
          .select()
          .eq('province_id', provinceId)
          .order('name');

      setState(() {
        _districts = List<Map<String, dynamic>>.from(response);
        _selectedDistrict = null;
        _selectedCouncil = null;
        _localAuthorities = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load districts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadLocalAuthorities(String districtId) async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('local_authorities')
          .select()
          .eq('district_id', districtId)
          .order('name');

      setState(() {
        _localAuthorities = List<Map<String, dynamic>>.from(response);
        _selectedCouncil = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load local authorities: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _idFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _provinceFocusNode.dispose();
    _districtFocusNode.dispose();
    _councilFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedCouncil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen2(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          idNumber: _idController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          province: _selectedProvince!,
          district: _selectedDistrict!,
          council: _selectedCouncil!,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required FocusNode focusNode,
    required IconData icon,
    bool isDropdown = false,
  }) {
    const primaryColor = Color(0xFF86c13c);
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isDropdown ? 16 : 18,
      ),
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? primaryColor : Colors.grey[600],
      ),
      prefixIcon: Icon(
        icon,
        color: focusNode.hasFocus ? primaryColor : Colors.grey,
      ),
      suffixIcon: isDropdown
          ? Icon(
              Icons.arrow_drop_down,
              color: focusNode.hasFocus ? primaryColor : Colors.grey,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF86c13c);
    const fieldSpacing = 20.0;
    const horizontalPadding = 24.0;
    const verticalPadding = 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration - Step 1/2'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // First Name Field
                    TextFormField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocusNode,
                      decoration: _buildInputDecoration(
                        labelText: 'First Name',
                        focusNode: _firstNameFocusNode,
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    // Last Name Field
                    TextFormField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocusNode,
                      decoration: _buildInputDecoration(
                        labelText: 'Last Name',
                        focusNode: _lastNameFocusNode,
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    // NIC/Passport Number Field
                    TextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      decoration: _buildInputDecoration(
                        labelText: 'NIC/Passport Number',
                        focusNode: _idFocusNode,
                        icon: Icons.credit_card,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration(
                        labelText: 'Phone Number',
                        focusNode: _phoneFocusNode,
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocusNode,
                      maxLines: 2,
                      decoration: _buildInputDecoration(
                        labelText: 'Address',
                        focusNode: _addressFocusNode,
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    // Province Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      focusNode: _provinceFocusNode,
                      decoration: _buildInputDecoration(
                        labelText: 'Select Province',
                        focusNode: _provinceFocusNode,
                        icon: Icons.map_outlined,
                        isDropdown: true,
                      ),
                      dropdownColor: Colors.grey[100],
                      style: const TextStyle(color: Colors.black),
                      isExpanded: true,
                      items: _provinces.map((province) {
                        return DropdownMenuItem<String>(
                          value: province['id'].toString(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(province['name']),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _loadDistricts(newValue);
                          setState(() {
                            _selectedProvince = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: fieldSpacing),
                    // District Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      focusNode: _districtFocusNode,
                      decoration: _buildInputDecoration(
                        labelText: 'Select District',
                        focusNode: _districtFocusNode,
                        icon: Icons.map_outlined,
                        isDropdown: true,
                      ),
                      dropdownColor: Colors.grey[100],
                      style: const TextStyle(color: Colors.black),
                      isExpanded: true,
                      items: _districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(district['name']),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _loadLocalAuthorities(newValue);
                          setState(() {
                            _selectedDistrict = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: fieldSpacing),
                    // Council Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCouncil,
                      focusNode: _councilFocusNode,
                      decoration: _buildInputDecoration(
                        labelText:
                            'Select Municipal Council or Pradeshiya Sabha',
                        focusNode: _councilFocusNode,
                        icon: Icons.location_city_outlined,
                        isDropdown: true,
                      ),
                      dropdownColor: Colors.grey[100],
                      style: const TextStyle(color: Colors.black),
                      isExpanded: true,
                      items: _localAuthorities.map((authority) {
                        return DropdownMenuItem<String>(
                          value: authority['id'].toString(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(authority['name']),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCouncil = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Next Button (fixed at bottom)
            Container(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                verticalPadding + 8,
              ),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _goToNextPage,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
