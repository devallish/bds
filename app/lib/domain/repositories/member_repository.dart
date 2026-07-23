import '../entities/member_profile.dart';

/// Domain-layer port for reading member data. Concrete implementations
/// (Supabase, or a fake for tests) live in the data layer — nothing outside
/// this file should know how a MemberProfile is actually fetched.
abstract class MemberRepository {
  Future<MemberProfile> getMemberProfile(String memberId);
}
