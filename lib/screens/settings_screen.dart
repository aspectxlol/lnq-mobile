import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../components/info_row.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.tr(context, 'connectionSuccessful')}\nDB: ${health['db']}, MinIO: ${health['minio']}',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.tr(context, 'connectionFailed')}: $e'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr(context, 'settingsSavedSuccessfully')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.tr(context, 'failedToSaveSettings')}: $e',
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr(context, 'resetToDefaultTitle')),
        content: Text(AppStrings.tr(context, 'resetToDefaultConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.tr(context, 'reset')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr(context, 'settingsResetToDefault')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.tr(context, 'failedToResetSettings')}: $e',
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.trWatch(context, 'settings'))),
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
                      AppStrings.trWatch(context, 'backendConfiguration'),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.trWatch(context, 'backendConfigurationDesc'),
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
                          AppStrings.trWatch(context, 'serverUrl'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _baseUrlController,
                          decoration: InputDecoration(
                            labelText: AppStrings.trWatch(
                              context,
                              'backendUrl',
                            ),
                            hintText: AppStrings.trWatch(
                              context,
                              'backendUrlHint',
                            ),
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
                              return AppStrings.trWatch(
                                context,
                                'pleaseEnterBackendUrl',
                              );
                            }
                            if (!value.startsWith('http://') &&
                                !value.startsWith('https://')) {
                              return AppStrings.trWatch(
                                context,
                                'urlMustStartWithHttp',
                              );
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
                                      ? AppStrings.trWatch(context, 'testing')
                                      : AppStrings.trWatch(
                                          context,
                                          'testConnection',
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveSettings,
                                icon: const Icon(Icons.save),
                                label: Text(
                                  AppStrings.trWatch(context, 'save'),
                                ),
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
                          AppStrings.trWatch(context, 'quickActions'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(
                            Icons.restore,
                            color: AppColors.secondary,
                          ),
                          title: Text(
                            AppStrings.trWatch(context, 'resetToDefault'),
                          ),
                          subtitle: Text(
                            AppStrings.trWatch(context, 'backendUrlHint'),
                          ),
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
                          AppStrings.trWatch(context, 'language'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, _) {
                            return Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text(
                                    AppStrings.trWatch(context, 'indonesian'),
                                  ),
                                  value: 'id',
                                  groupValue:
                                      settingsProvider.locale.languageCode,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await settingsProvider.setLocale(
                                        const Locale('id', 'ID'),
                                      );
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                RadioListTile<String>(
                                  title: Text(
                                    AppStrings.trWatch(context, 'english'),
                                  ),
                                  value: 'en',
                                  groupValue:
                                      settingsProvider.locale.languageCode,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await settingsProvider.setLocale(
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
                          AppStrings.trWatch(context, 'about'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        InfoRow(
                          label: AppStrings.trWatch(context, 'appName'),
                          value: 'LNQ',
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          label: AppStrings.trWatch(context, 'version'),
                          value: '1.0.0',
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          label: AppStrings.trWatch(context, 'currentUrl'),
                          value: settings.baseUrl,
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

