import 'package:bds_app/domain/entities/member_profile.dart';
import 'package:bds_app/domain/repositories/member_repository.dart';

class FakeMemberRepository implements MemberRepository {
  FakeMemberRepository(this.profile);

  final MemberProfile profile;

  @override
  Future<MemberProfile> getMemberProfile(String memberId) async => profile;
}
