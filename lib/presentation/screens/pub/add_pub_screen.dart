import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:alfa_scout/data/pub_api_data_source.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';

const List<String> alfaModels = [
  'Giulia',
  'Giulietta',
  'Stelvio',
  'Tonale',
  '147',
  '156',
  '159',
  'GT',
  'Brera',
  'Spider',
];

class AddPubScreen extends StatefulWidget {
  final Pub? initialPub;

  const AddPubScreen({super.key, this.initialPub});

  @override
  State<AddPubScreen> createState() => _AddPubScreenState();
}

class _AddPubScreenState extends State<AddPubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.initialPub != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final pub = widget.initialPub!;
      _titleController.text = pub.title;
      _modelController.text = pub.model;
      _priceController.text = pub.price.toString();
      _kmController.text = pub.km.toString();
      _descController.text = pub.description;
      _images.addAll(pub.imagePaths);
    }
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;

    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scatta foto'),
              onTap: () async {
                final file = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 100,
                );
                if (!mounted) return;
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Scegli dalla galleria'),
              onTap: () async {
                final file = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 100,
                );
                if (!mounted) return;
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        quality: 40,
      );

      if (compressed == null || compressed.length > 900 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Immagine troppo grande anche dopo la compressione!')),
        );
        return;
      }

      final base64Image = base64Encode(compressed);
      setState(() => _images.add(base64Image));
    }
  }

  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utente non autenticato')),
      );
      return;
    }

    final pub = Pub(
      id: widget.initialPub?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      model: _modelController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      km: int.tryParse(_kmController.text.trim()) ?? 0,
      description: _descController.text.trim(),
      imagePaths: _images,
      ownerId: user.uid,
    );

    if (isEdit) {
      await PubApiDataSource.instance.updatePub(pub);
    } else {
      await PubApiDataSource.instance.addPub(pub);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        title: Row(
          children: [
            FaIcon(isEdit ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.plus),
            const SizedBox(width: 8),
            Text(isEdit ? 'Modifica Annuncio' : 'Nuovo Annuncio'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildValidatedField(_titleController, 'Titolo'),
              const SizedBox(height: 12),
              _buildDropdownModel(),
              const SizedBox(height: 12),
              _buildValidatedField(_priceController, 'Prezzo in €', isNumber: true),
              const SizedBox(height: 12),
              _buildValidatedField(_kmController, 'Chilometraggio', isNumber: true),
              const SizedBox(height: 12),
              GFTextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descrizione'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _images.map((img) {
                  try {
                    final bytes = base64Decode(img);
                    final imageWidget = Image.memory(
                      bytes,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageWidget,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.remove(img)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withAlpha((0.8 * 255).toInt()), // 🔧 no deprecated
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  } catch (_) {
                    return const Icon(Icons.broken_image, size: 80);
                  }
                }).toList(),
              ),
              const SizedBox(height: 16),
              GFButton(
                onPressed: _pickImages,
                icon: const FaIcon(FontAwesomeIcons.camera, color: Colors.white),
                text: 'Aggiungi foto',
                shape: GFButtonShape.pills,
                color: GFColors.WARNING,
                blockButton: true,
              ),
              const SizedBox(height: 24),
              GFButton(
                onPressed: _saveAd,
                icon: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white),
                text: isEdit ? 'Salva modifiche' : 'Pubblica',
                shape: GFButtonShape.pills,
                color: GFColors.SUCCESS,
                blockButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedField(TextEditingController controller, String label, {bool isNumber = false}) {
    return FormField<String>(
      validator: (_) => controller.text.isEmpty ? 'Campo obbligatorio' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GFTextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12),
              child: Text(
                state.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownModel() {
    return DropdownButtonFormField<String>(
      value: alfaModels.contains(_modelController.text) ? _modelController.text : null,
      items: alfaModels.map((model) {
        return DropdownMenuItem(value: model, child: Text(model));
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _modelController.text = value);
      },
      decoration: InputDecoration(
        labelText: 'Modello',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obbligatorio' : null,
    );
  }
}
