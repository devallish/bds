import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/member_profile.dart';
import '../providers/member_providers.dart';
import 'member_profile_screen.dart';
import 'placeholder_screen.dart';

class _FeatureArea {
  const _FeatureArea({
    required this.icon,
    required this.label,
    required this.description,
    this.isBacklogIdea = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isBacklogIdea;
}

const _fieldRecordAreas = [
  _FeatureArea(
    icon: Icons.grass,
    label: 'Deer survey',
    description: 'Submit a deer survey for your region, with GPS tagging and offline support.',
  ),
  _FeatureArea(
    icon: Icons.visibility,
    label: 'Observation report',
    description: 'Log a deer sighting or observation, with GPS tagging and offline support.',
  ),
  _FeatureArea(
    icon: Icons.track_changes,
    label: 'Stalking report',
    description: 'Submit a stalking report, with GPS tagging and offline support.',
  ),
];

const _newsAreas = [
  _FeatureArea(
    icon: Icons.newspaper,
    label: 'News & notifications',
    description: 'Region-tagged news articles and push notifications from BDS.',
  ),
];

const _reportingAreas = [
  _FeatureArea(
    icon: Icons.insights,
    label: 'Reporting & insights',
    description: 'Cull and deer management insight aggregated from member submissions.',
  ),
];

const _ideasBacklogAreas = [
  _FeatureArea(
    icon: Icons.school,
    label: 'Training & qualifications',
    description: 'A record of your BDS training and qualifications.',
    isBacklogIdea: true,
  ),
  _FeatureArea(
    icon: Icons.badge,
    label: 'Digital membership card',
    description: 'A wallet-pass style digital qualification/membership card.',
    isBacklogIdea: true,
  ),
  _FeatureArea(
    icon: Icons.pets,
    label: 'Deer ID guide',
    description: 'An in-app guide to identifying deer species.',
    isBacklogIdea: true,
  ),
  _FeatureArea(
    icon: Icons.health_and_safety,
    label: 'Health checks',
    description: 'Health-check checklists for deer management.',
    isBacklogIdea: true,
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/bds_stag_logo.png',
              height: 32,
              semanticLabel: 'British Deer Society logo',
            ),
            const SizedBox(width: 8),
            const Text('BDS'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            data: (profile) => _MemberSummaryCard(
              profile: profile,
              onTap: () => _openProfile(context),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Could not load member profile: $error'),
            ),
          ),
          const SizedBox(height: 24),
          _FeatureSection(
            title: 'Membership',
            areas: const [
              _FeatureArea(
                icon: Icons.person,
                label: 'My profile',
                description: 'Your member details and addresses.',
              ),
            ],
            onOpen: (area) => _openProfile(context),
          ),
          _FeatureSection(
            title: 'News',
            areas: _newsAreas,
            onOpen: (area) => _openPlaceholder(context, area),
          ),
          _FeatureSection(
            title: 'Field records',
            areas: _fieldRecordAreas,
            onOpen: (area) => _openPlaceholder(context, area),
          ),
          _FeatureSection(
            title: 'Reporting',
            areas: _reportingAreas,
            onOpen: (area) => _openPlaceholder(context, area),
          ),
          _FeatureSection(
            title: 'Ideas backlog (not yet scoped)',
            areas: _ideasBacklogAreas,
            onOpen: (area) => _openPlaceholder(context, area),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberProfileScreen(memberId: memberId),
      ),
    );
  }

  void _openPlaceholder(BuildContext context, _FeatureArea area) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          title: area.label,
          description: area.description,
          isBacklogIdea: area.isBacklogIdea,
        ),
      ),
    );
  }
}

class _MemberSummaryCard extends StatelessWidget {
  const _MemberSummaryCard({required this.profile, required this.onTap});

  final MemberProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final person = profile.person;
    final fullName = [
      if (person.title != null) person.title,
      person.firstNames,
      person.lastName,
    ].join(' ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(fullName, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              'Region: ${profile.region}',
              'Role: ${profile.role.name}',
              if (profile.membershipNumber != null)
                'Membership number: ${profile.membershipNumber}',
            ].join('\n'),
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.title,
    required this.areas,
    required this.onOpen,
  });

  final String title;
  final List<_FeatureArea> areas;
  final void Function(_FeatureArea area) onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final area in areas)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(area.icon),
                title: Text(area.label),
                trailing: area.isBacklogIdea
                    ? const Chip(label: Text('Idea'))
                    : const Icon(Icons.chevron_right),
                onTap: () => onOpen(area),
              ),
            ),
        ],
      ),
    );
  }
}
