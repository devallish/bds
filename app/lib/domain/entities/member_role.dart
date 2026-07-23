enum MemberRole {
  member,
  regionalCoordinator,
  nationalAdmin;

  static MemberRole fromDbValue(String value) {
    switch (value) {
      case 'member':
        return MemberRole.member;
      case 'regional_coordinator':
        return MemberRole.regionalCoordinator;
      case 'national_admin':
        return MemberRole.nationalAdmin;
      default:
        throw ArgumentError('Unknown member role: $value');
    }
  }
}
