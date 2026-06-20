import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/highlight/code_themes.dart';
import '../../../core/highlight/language_visuals.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/data/auth_service.dart';
import '../../snippets/application/snippet_providers.dart';
import '../../snippets/domain/value_objects.dart';
import '../../sync/application/sync_providers.dart';
import '../application/settings_providers.dart';

/// App settings: appearance, export defaults and editor defaults (persisted).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final languages = ref.watch(languagesProvider).value ?? const <Language>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ref.watch(authServiceProvider) != null) ...[
                const _SectionHeader('Sync'),
                const _SyncSection(),
              ],
              const _SectionHeader('Appearance'),
              Card(
                child: ListTile(
                  title: const Text('Theme'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => controller.setThemeMode(s.first),
                  ),
                ),
              ),
              const _SectionHeader('Export defaults'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Default image theme'),
                      trailing: DropdownButton<String>(
                        value: CodeThemes.exportThemeNames
                                .contains(settings.exportTheme)
                            ? settings.exportTheme
                            : CodeThemes.exportThemeNames.first,
                        items: [
                          for (final name in CodeThemes.exportThemeNames)
                            DropdownMenuItem(value: name, child: Text(name)),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.setExportTheme(v);
                        },
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Show watermark on image exports'),
                      value: settings.exportWatermark,
                      onChanged: (v) =>
                          controller.setExportWatermark(value: v),
                    ),
                  ],
                ),
              ),
              const _SectionHeader('Editor defaults'),
              Card(
                child: ListTile(
                  title: const Text('Default language for new snippets'),
                  trailing: DropdownButton<String?>(
                    value: languages.any((l) => l.id == settings.defaultLanguageId)
                        ? settings.defaultLanguageId
                        : null,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final l in languages)
                        DropdownMenuItem(
                          value: l.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LanguageBadge(languageId: l.id, size: 18),
                              const SizedBox(width: 8),
                              Text(l.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: controller.setDefaultLanguage,
                  ),
                ),
              ),
              const _SectionHeader('About'),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.bookmarks_outlined),
                  title: Text('Snippet Manager'),
                  subtitle: Text('Local-first • sync-ready • all your platforms'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Cloud sync / account card. Renders the signed-out form (email + password,
/// sign in / create account) or the signed-in panel (email, sync now,
/// last-synced time, sign out) depending on [currentUserProvider].
class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild on every auth transition.
    ref.watch(authStateProvider);
    final user = ref.watch(currentUserProvider);
    return Card(
      child: user == null
          ? const _SignedOutForm()
          : _SignedInPanel(user: user),
    );
  }
}

/// Email/password form with sign-in and create-account actions. Holds its own
/// pending + inline message state.
class _SignedOutForm extends ConsumerStatefulWidget {
  const _SignedOutForm();

  @override
  ConsumerState<_SignedOutForm> createState() => _SignedOutFormState();
}

class _SignedOutFormState extends ConsumerState<_SignedOutForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _pending = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(AuthService auth) action) async {
    final auth = ref.read(authServiceProvider);
    if (auth == null || _pending) return;
    setState(() {
      _pending = true;
      _error = null;
      _info = null;
    });
    try {
      await action(auth);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  Future<void> _signIn() => _run(
        (auth) => auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        ),
      );

  Future<void> _signUp() => _run((auth) async {
        await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        // Supabase requires email confirmation by default; the user won't be
        // signed in immediately, so guide them to their inbox.
        if (mounted) {
          setState(() => _info = 'Check your email to confirm your account.');
        }
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign in to sync your snippets across devices.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            enabled: !_pending,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_pending,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _signIn(),
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          if (_info != null) ...[
            const SizedBox(height: 12),
            Text(
              _info!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _pending ? null : _signIn,
                  child: _pending
                      ? const _ButtonSpinner()
                      : const Text('Sign in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pending ? null : _signUp,
                  child: const Text('Create account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Signed-in panel: account email, manual sync trigger, last-synced relative
/// time, and sign out.
class _SignedInPanel extends ConsumerStatefulWidget {
  const _SignedInPanel({required this.user});

  final User user;

  @override
  ConsumerState<_SignedInPanel> createState() => _SignedInPanelState();
}

class _SignedInPanelState extends ConsumerState<_SignedInPanel> {
  bool _syncing = false;
  bool _signingOut = false;

  Future<void> _syncNow() async {
    final service = ref.read(syncServiceProvider);
    if (service == null || _syncing) return;
    setState(() => _syncing = true);
    try {
      await service.syncOnce();
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _signOut() async {
    final auth = ref.read(authServiceProvider);
    if (auth == null || _signingOut) return;
    setState(() => _signingOut = true);
    try {
      await auth.signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  /// Reads the per-user `lastSyncedAt` epoch (ms) persisted by the sync service.
  DateTime? _lastSyncedAt() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final ms = prefs.getInt('sync.lastSyncedAt.${widget.user.id}');
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.user.email ?? 'Signed in';
    final lastSynced = _lastSyncedAt();
    final busy = _syncing || _signingOut;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_done_outlined),
          title: Text(email),
          subtitle: Text(
            lastSynced == null
                ? 'Not synced yet'
                : 'Last synced ${_relativeTime(lastSynced)}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : _syncNow,
                  icon: _syncing
                      ? const _ButtonSpinner()
                      : const Icon(Icons.sync),
                  label: const Text('Sync now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : _signOut,
                  child: _signingOut
                      ? const _ButtonSpinner()
                      : const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small spinner sized to sit inside a button without resizing it.
class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// Compact relative time like "just now", "5m ago", "3h ago", "2d ago".
String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
