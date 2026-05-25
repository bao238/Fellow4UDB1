import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../core/auth/auth_session.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _onLogout(BuildContext context) {
    AuthSession.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final username = AuthSession.username ?? '';
    final email    = AuthSession.email    ?? '';
    final fullName = AuthSession.fullName ?? 'Traveler';
    final initial  = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.authHeaderTeal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _onLogout(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                initial: initial,
                fullName: fullName,
                username: username,
                email: email,
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info cards
                  _InfoSection(username: username, email: email, fullName: fullName),
                  const SizedBox(height: 24),

                  // Session status
                  _SessionStatusCard(),
                  const SizedBox(height: 24),

                  // Settings list
                  _SettingsList(),
                  const SizedBox(height: 32),

                  // Logout button
                  _LogoutButton(onLogout: () => _onLogout(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header widget ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initial,
    required this.fullName,
    required this.username,
    required this.email,
  });

  final String initial;
  final String fullName;
  final String username;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D7A60), Color(0xFF2FC49F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(color: Colors.white, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@$username',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Info section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.username,
    required this.email,
    required this.fullName,
  });

  final String username;
  final String email;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: fullName.isEmpty ? '—' : fullName,
            isFirst: true,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Username',
            value: username.isEmpty ? '—' : '@$username',
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email.isEmpty ? '—' : email,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(20) : Radius.zero,
      bottom: isLast ? const Radius.circular(20) : Radius.zero,
    );

    return ClipRRect(
      borderRadius: radius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppTheme.authHeaderTeal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLightGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 68, endIndent: 0, color: Color(0xFFF0F5F3));
  }
}

// ── Session status card ───────────────────────────────────────────────────────

class _SessionStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthSession.isLoggedIn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isLoggedIn ? const Color(0xFFEAF7F1) : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLoggedIn ? const Color(0xFFB8E4D0) : const Color(0xFFFFCDD2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLoggedIn ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: isLoggedIn ? AppTheme.authHeaderTeal : Colors.red,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Session Active' : 'Not Logged In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLoggedIn ? AppTheme.authHeaderTeal : Colors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoggedIn
                      ? 'Connected to SQL Server API'
                      : 'Please sign in again',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLoggedIn ? AppTheme.authHeaderTeal : Colors.red,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isLoggedIn ? 'Online' : 'Offline',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings list ─────────────────────────────────────────────────────────────

class _SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            isFirst: true,
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          _SettingsDivider(),
          _SettingsItem(
            icon: Icons.explore_outlined,
            label: 'Explore',
            onTap: () => Navigator.of(context).pushNamed('/explore'),
          ),
          _SettingsDivider(),
          _SettingsItem(
            icon: Icons.info_outline_rounded,
            label: 'About Fellow4U',
            isLast: true,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Fellow4U', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'Ứng dụng du lịch Fellow4U\nFlutter + Node.js + SQL Server\nVersion 1.0.0',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: AppTheme.authHeaderTeal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(20) : Radius.zero,
      bottom: isLast ? const Radius.circular(20) : Radius.zero,
    );

    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: AppTheme.authHeaderTeal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textLightGray, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 68, color: Color(0xFFF0F5F3));
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade400,
          side: BorderSide(color: Colors.red.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
