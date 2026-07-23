import 'member_role.dart';
import 'person.dart';
import 'address.dart';

/// The composed view of a member's data spanning member, person, and address —
/// what MemberRepository.getMemberProfile returns.
class MemberProfile {
  const MemberProfile({
    required this.memberId,
    required this.region,
    required this.role,
    required this.person,
    required this.addresses,
    this.membershipNumber,
    this.joinedAt,
  });

  final String memberId;
  final String region;
  final MemberRole role;
  final String? membershipNumber;
  final DateTime? joinedAt;
  final Person person;
  final List<Address> addresses;
}
