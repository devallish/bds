import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/member_profile.dart';
import '../../domain/entities/member_role.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/member_repository.dart';

/// Supabase-backed adapter for MemberRepository. This is the only place in
/// the app that should reference `member`/`person`/`address` table or column
/// names directly — everything above the data layer works with MemberProfile.
class SupabaseMemberRepository implements MemberRepository {
  SupabaseMemberRepository(this._client);

  final SupabaseClient _client;

  static const _selectQuery = '''
    id,
    membership_number,
    joined_at,
    role,
    region ( label ),
    person (
      title,
      first_names,
      last_name,
      date_of_birth,
      address (
        line_1, line_2, line_3, line_4, town, county, postcode,
        address_type ( label )
      )
    )
  ''';

  @override
  Future<MemberProfile> getMemberProfile(String memberId) async {
    final row = await _client
        .from('member')
        .select(_selectQuery)
        .eq('id', memberId)
        .single();

    return _toMemberProfile(memberId, row);
  }

  MemberProfile _toMemberProfile(String memberId, Map<String, dynamic> row) {
    final personRow = row['person'] as Map<String, dynamic>;
    final addressRows = (personRow['address'] as List<dynamic>?) ?? const [];

    return MemberProfile(
      memberId: memberId,
      region: (row['region'] as Map<String, dynamic>)['label'] as String,
      role: MemberRole.fromDbValue(row['role'] as String),
      membershipNumber: row['membership_number'] as String?,
      joinedAt: _parseDate(row['joined_at'] as String?),
      person: Person(
        title: personRow['title'] as String?,
        firstNames: personRow['first_names'] as String,
        lastName: personRow['last_name'] as String,
        dateOfBirth: _parseDate(personRow['date_of_birth'] as String?),
      ),
      addresses: addressRows
          .cast<Map<String, dynamic>>()
          .map(_toAddress)
          .toList(growable: false),
    );
  }

  Address _toAddress(Map<String, dynamic> row) {
    return Address(
      addressType: (row['address_type'] as Map<String, dynamic>)['label'] as String,
      line1: row['line_1'] as String,
      line2: row['line_2'] as String?,
      line3: row['line_3'] as String?,
      line4: row['line_4'] as String?,
      town: row['town'] as String,
      county: row['county'] as String?,
      postcode: row['postcode'] as String,
    );
  }

  DateTime? _parseDate(String? value) => value == null ? null : DateTime.parse(value);
}
