// lib/mapCarto/remarkable_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Modèle retourné par le dialog à la carte
class RemarkableInput {
  final String shortDesc;
  final String longDesc;
  final XFile photo; // maintenant obligatoire

  RemarkableInput({
    required this.shortDesc,
    required this.longDesc,
    required this.photo,
  });
}

/// Dialog plein écran (ou presque) pour créer un point remarquable
class RemarkableDialog extends StatefulWidget {
  const RemarkableDialog({super.key, required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  State<RemarkableDialog> createState() => _RemarkableDialogState();
}

class _RemarkableDialogState extends State<RemarkableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _shortCtrl = TextEditingController();
  final _longCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final _scrollController = ScrollController();

  XFile? _selectedPhoto;
  bool _saving = false;

  /// Pour afficher une erreur "photo obligatoire"
  bool _photoError = false;

  @override
  void dispose() {
    _shortCtrl.dispose();
    _longCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (img != null && mounted) {
        setState(() {
          _selectedPhoto = img;
          _photoError = false; // efface l’erreur
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise de photo : $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (img != null && mounted) {
        setState(() {
          _selectedPhoto = img;
          _photoError = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’import de la photo : $e')),
      );
    }
  }

  void _onCancel() {
    Navigator.of(context).pop<RemarkableInput?>(null);
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedPhoto == null) {
      // Active l’erreur
      setState(() => _photoError = true);

      // Scroll vers la photo
      await Future.delayed(const Duration(milliseconds: 150));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final result = RemarkableInput(
      shortDesc: _shortCtrl.text.trim(),
      longDesc: _longCtrl.text.trim(),
      photo: _selectedPhoto!, // devient obligatoire
    );

    Navigator.of(context).pop<RemarkableInput>(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppBar perso
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Nouveau point remarquable',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _onCancel,
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Coordonnées
                          Text(
                            'Position actuelle',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat : ${widget.lat.toStringAsFixed(6)}\n'
                            'Lon : ${widget.lon.toStringAsFixed(6)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),

                          // Description courte
                          TextFormField(
                            controller: _shortCtrl,
                            maxLength: 160,
                            decoration: const InputDecoration(
                              labelText: 'Description courte',
                              hintText: 'Ex. Aire de jeux inclusive',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) {
                                return 'Description courte requise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Description longue
                          TextFormField(
                            controller: _longCtrl,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Description détaillée',
                              hintText:
                                  'Ex. Parc avec balançoire adaptée, cheminements accessibles...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) {
                                return 'Description longue requise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PHOTO
                          Text(
                            'Photo (obligatoire)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _photoError
                                  ? theme.colorScheme.error
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _photoError
                                    ? theme.colorScheme.error
                                    : theme.dividerColor.withOpacity(0.7),
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: _selectedPhoto == null
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo_outlined,
                                            size: 40,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.6),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Aucune photo sélectionnée',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: _photoError
                                                      ? theme.colorScheme.error
                                                      : theme
                                                            .colorScheme
                                                            .onSurfaceVariant
                                                            .withOpacity(0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          File(_selectedPhoto!.path),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.black54,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              iconSize: 18,
                                              tooltip: 'Supprimer la photo',
                                              onPressed: () {
                                                setState(() {
                                                  _selectedPhoto = null;
                                                  _photoError = true;
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          if (_photoError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Une photo est obligatoire',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Boutons photo
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickFromCamera,
                                icon: const Icon(Icons.photo_camera),
                                label: const Text('Prendre une photo'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Importer une photo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BOUTONS ACTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving ? null : _onCancel,
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saving ? null : _onSave,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _saving ? 'Enregistrement...' : 'Enregistrer',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
