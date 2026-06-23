/// User profile data model — matches the data shape in Profile.tsx
class UserProfile {
  final String id;
  final String fullName;
  final String initials;
  final String email;
  final int avgScore;
  final int performanceCount;
  final int achievementCount;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.email,
    required this.avgScore,
    required this.performanceCount,
    required this.achievementCount,
  });

  // ─── Mock Data (matching Profile.tsx) ───────────────────────

  static const UserProfile mockUser = UserProfile(
    id: '1',
    fullName: 'John Doe',
    initials: 'JD',
    email: 'john.doe@email.com',
    avgScore: 84,
    performanceCount: 127,
    achievementCount: 12,
  );
}
