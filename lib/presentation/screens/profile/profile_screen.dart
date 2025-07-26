import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getwidget/getwidget.dart';

import 'package:alfa_scout/data/user_api_data_source.dart';
import 'package:alfa_scout/domain/models/user_profile.dart';
import 'package:alfa_scout/data/pub_api_data_source.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';
import 'package:alfa_scout/l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  String? _photoBase64;
  bool _loading = false;
  List<Pub> _userPubs = [];

  final _auth = FirebaseAuth.instance;
  final _userService = UserApiDataSource.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserPubs();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final profile = await _userService.getUserProfile(user.uid);
      setState(() {
        _photoBase64 = profile?.photoBase64;
        _plateController.text = profile?.plate ?? '';
        _phoneController.text = profile?.phone ?? '';
      });
    }
  }

  Future<void> _loadUserPubs() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final pubs = await PubApiDataSource.instance.getUserPubs(user.uid);
    setState(() => _userPubs = pubs);
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selezione immagine non supportata su Web')),
      );
      return;
    }

    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Scatta foto'),
            onTap: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
              //ignore: use_build_context_synchronously
              Navigator.pop(context, file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Scegli dalla galleria'),
            onTap: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
              //ignore: use_build_context_synchronously
              Navigator.pop(context, file);
            },
          ),
        ],
      ),
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      String? encodedImage = _photoBase64;

      if (_selectedImage != null && !kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        encodedImage = base64Encode(bytes);
      }

      final email = user.email;
      final username = (email != null && email.contains('@')) ? email.split('@')[0] : 'Alfista';

      final profile = UserProfile(
        uid: user.uid,
        name: username,
        surname: 'N/A',
        plate: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
        photoBase64: encodedImage,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      await _userService.saveUserProfile(profile);
      await _auth.currentUser?.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.profileSaved ?? 'Profilo salvato')),
      );
    } catch (e, st) {
      debugPrint('Errore nel salvataggio profilo: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il salvataggio')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.profile ?? 'Profilo';
    final plateLabel = l10n?.plate ?? 'Targa';
    final saveLabel = l10n?.save ?? 'Salva';

    final email = user?.email;
    final username = (email != null && email.contains('@')) ? email.split('@')[0] : 'Alfista';

    final ImageProvider profileImageProvider;
    if (!kIsWeb && _selectedImage != null) {
      profileImageProvider = FileImage(_selectedImage!);
    } else if (_photoBase64 != null) {
      final decoded = base64Decode(_photoBase64!);
      profileImageProvider = MemoryImage(decoded);
    } else {
      profileImageProvider = const AssetImage('assets/images/default_avatar.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              //ignore: use_build_context_synchronously
              context.go('/login');
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.05 * 255).round()),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: profileImageProvider,
                                backgroundColor: Colors.grey.shade300,
                                child: (_photoBase64 == null && _selectedImage == null)
                                    ? const Icon(Icons.camera_alt, color: Colors.white70)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(username, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _plateController,
                              decoration: InputDecoration(
                                labelText: plateLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.directions_car),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Numero di telefono',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GFButton(
                              onPressed: _saveProfile,
                              text: saveLabel,
                              icon: const Icon(Icons.save, color: Colors.white),
                              shape: GFButtonShape.pills,
                              size: GFSize.LARGE,
                              color: GFColors.SUCCESS,
                              blockButton: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('I tuoi annunci:', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 10),
                      if (_userPubs.isEmpty)
                        const Text('Nessun annuncio pubblicato')
                      else
                        ..._userPubs.map((pub) => Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(pub.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${pub.model} - ${pub.price} €'),
                                onTap: () => context.push('/details/${pub.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Modifica',
                                      onPressed: () => context.push('/pub/edit', extra: pub),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Elimina',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: const Text('Conferma eliminazione'),
                                              content: const Text('Vuoi eliminare questo annuncio?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                  child: const Text('Annulla'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                                  child: const Text('Elimina'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirm == true) {
                                          await PubApiDataSource.instance.deletePub(pub.id);
                                          _loadUserPubs();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
