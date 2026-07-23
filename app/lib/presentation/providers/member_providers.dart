import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase/supabase_member_repository.dart';
import '../../domain/entities/member_profile.dart';
import '../../domain/repositories/member_repository.dart';

/// The only place that wires the domain MemberRepository port to its
/// Supabase-backed adapter. Tests override this provider with a fake instead
/// of touching Supabase at all.
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return SupabaseMemberRepository(Supabase.instance.client);
});

final memberProfileProvider =
    FutureProvider.family<MemberProfile, String>((ref, memberId) {
  return ref.watch(memberRepositoryProvider).getMemberProfile(memberId);
});
