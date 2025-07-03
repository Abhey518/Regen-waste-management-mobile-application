import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ReportDumpingWindow extends StatefulWidget {
  const ReportDumpingWindow({super.key});

  @override
  State<ReportDumpingWindow> createState() => _ReportDumpingScreenState();
}

class _ReportDumpingScreenState extends State<ReportDumpingWindow> {
  File? _image;
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  Map<String, double>? _analysisResult;
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      await _processPickedImage(File(picked.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _processPickedImage(File(picked.path));
    }
  }

  Future<void> _processPickedImage(File image) async {
    setState(() {
      _image = image;
      _isAnalyzing = true;
      _analysisResult = null;
    });
    await _analyzeImage(image);
  }

  Future<void> _analyzeImage(File image) async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analysisResult = {
        "Shopping Bags": 0.7,
        "Plastic Bottles": 0.15,
        "Cardboard": 0.08,
        "Organic Waste": 0.05,
        "Other": 0.02,
      };
      _isAnalyzing = false;
    });
  }

  Future<void> _submitReport() async {
    if (_image == null ||
        _analysisResult == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide location information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Report submitted for location: ${_locationController.text}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "AI Analysis Result:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._analysisResult!.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: LinearPercentIndicator(
                lineHeight: 20,
                percent: entry.value,
                center: Text("${(entry.value * 100).toStringAsFixed(1)}%"),
                leading: Text(entry.key),
                barRadius: const Radius.circular(10),
                progressColor: Colors.green,
                backgroundColor: Colors.grey[300],
              ),
            )),
        const SizedBox(height: 24),
        TextFormField(
          controller: _locationController,
          focusNode: _locationFocusNode,
          decoration: InputDecoration(
            labelText: 'Dumping Location',
            hintText: 'Enter exact address or landmarks',
            prefixIcon: const Icon(Icons.location_on, color: Colors.green),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the location';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 14, 124, 4),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                : const Text(
                    'SUBMIT REPORT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Report Illegal Dumping', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Illegal Dumping Analyzer",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 36, 149, 5),
              ),
            ),
            const SizedBox(height: 16),
            _image == null
                ? Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Center(
                        child: Text(
                      "No image selected.\nTake or upload a photo of dumped garbage.",
                      textAlign: TextAlign.center,
                    )),
                  )
                : Image.file(_image!, height: 220, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt,
                      color: Color.fromARGB(255, 14, 124, 4)),
                  label: const Text(
                    "Take Photo",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library,
                      color: Color.fromARGB(255, 14, 124, 4)),
                  label: const Text(
                    "Upload from Gallery",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }
}
