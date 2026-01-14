import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A consistent scaffold wrapper for all screens in the app
class ScreenScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final List<Widget>? appBarActions;
  final Widget? bottomNavigationBar;
  final EdgeInsets bodyPadding;

  const ScreenScaffold({
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.appBar,
    this.appBarActions,
    this.bottomNavigationBar,
    this.bodyPadding = const EdgeInsets.all(16),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ??
          AppBar(
            title: Text(title),
            centerTitle: false,
            elevation: 0,
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.foreground,
            actions: appBarActions,
          ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Consistent form container with padding
class FormContainer extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final bool scrollable;

  const FormContainer({
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.scrollable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(
        padding: padding,
        child: content,
      );
    }
    return Padding(
      padding: padding,
      child: content,
    );
  }
}

/// Consistent action button styling
class FormActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double? width;

  const FormActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final button = isSecondary
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}

/// Consistent spacing between form fields
class FormFieldSpacing extends StatelessWidget {
  final double height;

  const FormFieldSpacing({
    this.height = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Consistent form header text
class FormSectionHeader extends StatelessWidget {
  final String title;

  const FormSectionHeader({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Consistent list item card styling
class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets padding;
  final double? minHeight;

  const ListItemCard({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(12),
    this.minHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: padding,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        minTileHeight: minHeight,
      ),
    );
  }
}

/// Consistent empty state with consistent styling
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Consistent confirmation dialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.destructive : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
