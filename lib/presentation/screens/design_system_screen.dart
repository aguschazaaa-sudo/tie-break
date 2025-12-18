import 'package:flutter/material.dart';
import 'package:padel_punilla/config/theme/app_colors.dart';
import 'package:padel_punilla/presentation/widgets/custom_text_field.dart';
import 'package:padel_punilla/presentation/widgets/primary_button.dart';
import 'package:padel_punilla/presentation/widgets/secondary_button.dart';
import 'package:padel_punilla/presentation/widgets/status_badge.dart';
import 'package:padel_punilla/presentation/widgets/surface_card.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({required this.onToggleTheme, super.key});
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(context, 'Typography'),
          _buildTypographyShowcase(context),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'Colors'),
          _buildColorPalette(context),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'Buttons'),
          _buildButtonsShowcase(context),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'Inputs'),
          _buildInputsShowcase(context),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'New Components'),
          _buildComponentsShowcase(context),
        ],
      ),
    );
  }

  Widget _buildComponentsShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Surface Cards (Standard/Colored)'),
        const SizedBox(height: 8),
        const SurfaceCard(child: Text('Default Surface Card')),
        const SizedBox(height: 16),
        SurfaceCard(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          child: Column(
            children: [
              Text(
                'Colored Surface Card',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 8),
              const Text('Useful for highlighting varied content sectors.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: SurfaceCard(
              isGlass: true,
              child: Text('Glass Surface Card (Overlaying Content)'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Status Badges'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(
              label: 'Primary Badge',
              color: Theme.of(context).colorScheme.primary,
              icon: Icons.check,
            ),
            StatusBadge(
              label: 'Secondary Badge',
              color: Theme.of(context).colorScheme.secondary,
              icon: Icons.star,
            ),
            StatusBadge(
              label: 'Tertiary Badge',
              color: Theme.of(context).colorScheme.tertiary,
              icon: Icons.notifications,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.displayMedium?.copyWith(fontSize: 24),
      ),
    );
  }

  Widget _buildTypographyShowcase(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Large',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Display Medium',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Body Large - The quick brown fox jumps over the lazy dog.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Body Medium - The quick brown fox jumps over the lazy dog.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildColorBox(
          context,
          'Primary',
          Theme.of(context).colorScheme.primary,
        ),
        _buildColorBox(
          context,
          'OnPrimary',
          Theme.of(context).colorScheme.onPrimary,
        ),
        _buildColorBox(
          context,
          'Secondary',
          Theme.of(context).colorScheme.secondary,
        ),
        _buildColorBox(
          context,
          'OnSecondary',
          Theme.of(context).colorScheme.onSecondary,
        ),
        _buildColorBox(
          context,
          'Tertiary',
          Theme.of(context).colorScheme.tertiary,
        ),
        _buildColorBox(
          context,
          'OnTertiary',
          Theme.of(context).colorScheme.onTertiary,
        ),
        _buildColorBox(context, 'Error', Theme.of(context).colorScheme.error),
        _buildColorBox(context, 'Success', AppColors.success),
        _buildColorBox(
          context,
          'Surface',
          Theme.of(context).colorScheme.surface,
        ),
        _buildColorBox(
          context,
          'Background',
          Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildColorBox(BuildContext context, String name, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildButtonsShowcase(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        PrimaryButton(text: 'Primary Button', onPressed: () {}),
        PrimaryButton(text: 'Loading', onPressed: () {}, isLoading: true),
        SecondaryButton(text: 'Secondary Button', onPressed: () {}),
        SecondaryButton(text: 'With Icon', icon: Icons.star, onPressed: () {}),
      ],
    );
  }

  Widget _buildInputsShowcase(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: TextEditingController(),
          label: 'Label Text',
          hint: 'Hint Text',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: TextEditingController(),
          label: 'With Icon',
          prefixIcon: Icons.email,
        ),
      ],
    );
  }
}
