import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/member_profile.dart';
import '../providers/member_providers.dart';

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider(memberId));

    return Scaffold(
      appBar: AppBar(title: const Text('Member profile')),
      body: profileAsync.when(
        data: (profile) => _MemberProfileView(profile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Could not load member profile: $error'),
        ),
      ),
    );
  }
}

class _MemberProfileView extends StatelessWidget {
  const _MemberProfileView({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final person = profile.person;
    final fullName = [
      if (person.title != null) person.title,
      person.firstNames,
      person.lastName,
    ].join(' ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(fullName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Region: ${profile.region}'),
        Text('Role: ${profile.role.name}'),
        if (profile.membershipNumber != null)
          Text('Membership number: ${profile.membershipNumber}'),
        const SizedBox(height: 24),
        Text('Addresses', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final address in profile.addresses) _AddressTile(address: address),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final lines = [
      address.line1,
      if (address.line2 != null) address.line2,
      if (address.line3 != null) address.line3,
      if (address.line4 != null) address.line4,
      address.town,
      if (address.county != null) address.county,
      address.postcode,
    ].join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(address.addressType),
        subtitle: Text(lines),
      ),
    );
  }
}
