import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32.0),
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE88219),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.award, size: 14.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sarah Johnson',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '@sarahsings',
                          style: AppTextStyles.bodySM.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push('/settings?tab=profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE88219),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text('2.4K', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Followers', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(width: 24.0),
                    Container(width: 1.0, height: 32.0, color: const Color(0xFF2E2621)),
                    const SizedBox(width: 24.0),
                    Column(
                      children: [
                        Text('186', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Following', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                const SizedBox(height: 32.0),
                Row(
                  children: [
                    _buildStatBox(LucideIcons.music, '42', 'Recordings'),
                    const SizedBox(width: 12.0),
                    _buildStatBox(LucideIcons.users, '128', 'Plays'),
                    const SizedBox(width: 12.0),
                    _buildStatBox(LucideIcons.userPlus, '89%', 'Avg Score'),
                  ],
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achievements',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/achievements'),
                      child: Text(
                        'See all',
                        style: AppTextStyles.bodySM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE88219),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildAchievementCard('Rising Star', 'Complete 10 songs', '70%', 0.7, const Color(0xFFFACC15), LucideIcons.star),
                const SizedBox(height: 12.0),
                _buildAchievementCard('Karaoke Master', 'Achieve 90% score on 5 songs', '40%', 0.4, const Color(0xFFF59E0B), LucideIcons.mic),
                const SizedBox(height: 12.0),
                _buildAchievementCard('Music Lover', 'Add 50 songs to favorites', '84%', 0.84, const Color(0xFF4ADE80), LucideIcons.heart),
                const SizedBox(height: 32.0),
                _buildMenuItem('Settings', LucideIcons.settings, onTap: () => context.push('/settings')),
                const SizedBox(height: 12.0),
                _buildMenuItem('Help & Support', LucideIcons.helpCircle, onTap: () {}),
                const SizedBox(height: 12.0),
                _buildMenuItem('Log Out', LucideIcons.logOut, isDestructive: true, onTap: () {
                  context.read<AuthProvider>().logout();
                  context.go('/welcome');
                }),
                const SizedBox(height: 180.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F0B),
          border: Border.all(color: const Color(0xFF2E2621)),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE88219), size: 24.0),
            const SizedBox(height: 12.0),
            Text(value, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4.0),
            Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(String title, String subtitle, String percentStr, double percent, Color percentColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2621),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A0F0B),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4.0),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                  ],
                ),
              ),
              Text(
                percentStr,
                style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w700, color: percentColor),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 6.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A0F0B),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC41E30), Color(0xFFE88219)],
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {bool isDestructive = false, required VoidCallback onTap}) {
    final color = isDestructive ? const Color(0xFFFA233B) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F0B),
          border: Border.all(color: const Color(0xFF2E2621)),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600, color: color),
              ),
            ),
            if (!isDestructive) const Icon(LucideIcons.chevronRight, color: Colors.white54, size: 20.0),
          ],
        ),
      ),
    );
  }
}
