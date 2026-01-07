import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  bool _isTesting = false;
  String? _healthStatus;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _baseUrlController.text = settings.baseUrl;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _healthStatus = null;
    });

    try {
      final url = _baseUrlController.text;
      final apiService = ApiService(url);
      final health = await apiService.healthCheck();

      if (mounted) {
        setState(() {
          _healthStatus = 'success';
        });
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.connectionSuccessful(
                health['db'].toString(),
                health['minio'].toString(),
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _healthStatus = 'error';
        });
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectionFailed(e.toString())),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final settings = context.read<SettingsProvider>();
      await settings.setBaseUrl(_baseUrlController.text);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSavedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSaveSettings(e.toString())),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetToDefaultTitle),
        content: Text(l10n.resetToDefaultConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final settings = context.read<SettingsProvider>();
      await settings.resetToDefault();
      setState(() {
        _baseUrlController.text = settings.baseUrl;
        _healthStatus = null;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsResetToDefault),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToResetSettings(e.toString())),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInSlide(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.backendConfiguration,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.backendConfigurationDesc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.serverUrl,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _baseUrlController,
                          decoration: InputDecoration(
                            labelText: l10n.backendUrl,
                            hintText: l10n.backendUrlHint,
                            prefixIcon: const Icon(Icons.link),
                            suffixIcon: _healthStatus != null
                                ? Icon(
                                    _healthStatus == 'success'
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _healthStatus == 'success'
                                        ? AppColors.success
                                        : AppColors.destructive,
                                  )
                                : null,
                          ),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterBackendUrl;
                            }
                            if (!value.startsWith('http://') &&
                                !value.startsWith('https://')) {
                              return l10n.urlMustStartWithHttp;
                            }
                            return null;
                          },
                          onChanged: (_) {
                            setState(() {
                              _healthStatus = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isTesting ? null : _testConnection,
                                icon: _isTesting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.wifi_find),
                                label: Text(
                                  _isTesting
                                      ? l10n.testing
                                      : l10n.testConnection,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveSettings,
                                icon: const Icon(Icons.save),
                                label: Text(l10n.save),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.quickActions,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(
                            Icons.restore,
                            color: AppColors.secondary,
                          ),
                          title: Text(l10n.resetToDefault),
                          subtitle: Text(l10n.backendUrlHint),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: _resetToDefault,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: const Duration(milliseconds: 250),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            return Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text(l10n.indonesian),
                                  value: 'id',
                                  groupValue: settings.locale.languageCode,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await settings.setLocale(
                                        const Locale('id', 'ID'),
                                      );
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                RadioListTile<String>(
                                  title: Text(l10n.english),
                                  value: 'en',
                                  groupValue: settings.locale.languageCode,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await settings.setLocale(
                                        const Locale('en', 'US'),
                                      );
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.about,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(label: l10n.appName, value: 'LNQ'),
                        const Divider(height: 24),
                        _InfoRow(label: l10n.version, value: '1.0.0'),
                        const Divider(height: 24),
                        _InfoRow(
                          label: l10n.currentUrl,
                          value: context.watch<SettingsProvider>().baseUrl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
