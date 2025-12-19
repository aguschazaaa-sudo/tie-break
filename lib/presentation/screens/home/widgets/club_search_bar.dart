import 'dart:async';
import 'package:flutter/material.dart';
import 'package:padel_punilla/presentation/widgets/custom_text_field.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

/// Barra de búsqueda para encontrar clubes por nombre.
///
/// Incluye debounce de 300ms para evitar búsquedas excesivas
/// y botón de limpiar cuando hay texto.
class ClubSearchBar extends StatefulWidget {
  const ClubSearchBar({
    required this.onSearch,
    this.initialValue = '',
    super.key,
  });

  /// Callback cuando cambia el texto de búsqueda (con debounce)
  final void Function(String query) onSearch;

  /// Valor inicial del campo de texto
  final String initialValue;

  @override
  State<ClubSearchBar> createState() => _ClubSearchBarState();
}

class _ClubSearchBarState extends State<ClubSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Maneja cambios en el texto con debounce
  void _onTextChanged(String value) {
    _debounceTimer?.cancel();

    // Si el campo está vacío, ejecutar inmediatamente
    if (value.isEmpty) {
      widget.onSearch('');
      return;
    }

    // Esperar 300ms antes de ejecutar la búsqueda
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value.trim());
    });
  }

  /// Limpia el campo de búsqueda
  void _clearSearch() {
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SurfaceCard(
        isGlass: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomTextField(
          controller: _controller,
          label: 'Buscar clubes',
          hint: 'Nombre del club...',
          prefixIcon: Icons.search_rounded,
          onChanged: _onTextChanged,
          fillColor: Colors.transparent,
          showBorders: false,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: _clearSearch,
                tooltip: 'Limpiar búsqueda',
              );
            },
          ),
        ),
      ),
    );
  }
}
